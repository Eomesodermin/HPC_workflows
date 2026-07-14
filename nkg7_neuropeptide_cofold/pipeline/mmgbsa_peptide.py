#!/usr/bin/env python3
"""Single-trajectory MM/GBSA binding free-energy estimate for Boltz protein-PEPTIDE complexes.

Fork of the small-molecule reference (mmgbsa_reference_smallmol.py). Key differences:
  * The ligand (chain B) is a STANDARD-amino-acid PEPTIDE, not a HETATM small molecule.
    So NO RDKit / GAFF2 / AM1-BCC. The WHOLE complex is parametrized with ff14SB
    (amber/protein.ff14SB.xml) + GBn2 implicit solvent (implicit/gbn2.xml).
  * PDBFixer is run on the FULL complex (add H at pH 7.4, keep BOTH chains).
  * Atom indices are split by CHAIN identifier read from the actual topology: the
    receptor is the chain with the most residues (NKG7, 165 res), the ligand is the
    other chain (peptide). Sub-systems (receptor-alone, ligand-alone) are derived from
    the SAME fixed complex via Modeller.delete so H atoms / atom order stay consistent.
  * Single-trajectory MM/GBSA: minimise + short GB Langevin MD; over N snapshots
    dG = mean(E_complex - E_receptor - E_ligand), SEM reported. CUDA platform, CPU fallback.

The script LOOPS over all NKG7_*.pdb in --structures-dir and catches per-complex failures
(e.g. PROK2 disulfides / H-addition), writing an NA row rather than aborting the batch.

CAVEAT: single-trajectory MM/GBSA has NO configurational-entropy (-TdS) term. It is a
RELATIVE ranking tool, meaningful WITHIN this run and vs the scrambled CTRL, NOT an
absolute Kd. Reported dG values are systematically over-attractive.
"""
import argparse, glob, os, sys, traceback
import numpy as np
from openmm import app, unit, Platform, LangevinMiddleIntegrator, VerletIntegrator, Context
import openmm as mm
from pdbfixer import PDBFixer


def get_platform():
    try:
        return Platform.getPlatformByName("CUDA")
    except Exception:
        return Platform.getPlatformByName("CPU")


def fix_complex(complex_pdb):
    """PDBFixer on the FULL complex: keep both chains, add missing atoms + H at pH 7.4."""
    fixer = PDBFixer(filename=complex_pdb)
    fixer.findMissingResidues(); fixer.missingResidues = {}
    fixer.findNonstandardResidues(); fixer.replaceNonstandardResidues()
    fixer.removeHeterogens(keepWater=False)   # drop waters/ions; peptide is standard AA in chains
    fixer.findMissingAtoms(); fixer.addMissingAtoms()
    fixer.addMissingHydrogens(7.4)
    return fixer.topology, fixer.positions


def chain_split(topology):
    """Return (receptor_chain_id, ligand_chain_id). Receptor = most residues."""
    chains = list(topology.chains())
    counts = [(c.id, sum(1 for _ in c.residues())) for c in chains]
    counts.sort(key=lambda x: x[1], reverse=True)
    rec_id = counts[0][0]
    # ligand = the largest of the remaining chains (there should be exactly 2)
    others = [c for c in counts[1:] if c[1] > 0]
    if not others:
        raise RuntimeError(f"Only one non-empty chain found: {counts}")
    lig_id = others[0][0]
    return rec_id, lig_id, dict(counts)


def submodel(full_top, full_pos, keep_chain_id):
    """Copy the fixed complex and delete every chain except keep_chain_id.
    Modeller.delete preserves atom order, so positions sliced from the full complex by
    the kept chain's atom indices align with this sub-topology."""
    m = app.Modeller(full_top, full_pos)
    to_del = [c for c in m.topology.chains() if c.id != keep_chain_id]
    m.delete(to_del)
    return m.topology, m.positions


def energy(ctx, positions):
    ctx.setPositions(positions)
    return ctx.getState(getEnergy=True).getPotentialEnergy().value_in_unit(unit.kilocalorie_per_mole)


def run_one(complex_pdb, ff, plat, nsnap, eq_ps, prod_ps):
    top, pos = fix_complex(complex_pdb)
    rec_id, lig_id, counts = chain_split(top)

    # atom indices in the FULL complex, by chain
    rec_idx = [a.index for a in top.atoms() if a.residue.chain.id == rec_id]
    lig_idx = [a.index for a in top.atoms() if a.residue.chain.id == lig_id]

    ff_kwargs = dict(nonbondedMethod=app.NoCutoff, constraints=app.HBonds,
                     rigidWater=True, removeCMMotion=False, hydrogenMass=3.0 * unit.amu)

    # full complex
    complex_system = ff.createSystem(top, **ff_kwargs)
    integ = LangevinMiddleIntegrator(300 * unit.kelvin, 1 / unit.picosecond, 0.002 * unit.picoseconds)
    sim = app.Simulation(top, complex_system, integ, plat)
    sim.context.setPositions(pos)
    sim.minimizeEnergy(maxIterations=2000)
    sim.context.setVelocitiesToTemperature(300 * unit.kelvin)
    sim.step(int(eq_ps * unit.picoseconds / (0.002 * unit.picoseconds)))  # equilibration

    # receptor-only + ligand-only systems from the SAME fixed complex (consistent atoms)
    rec_top, _ = submodel(top, pos, rec_id)
    lig_top, _ = submodel(top, pos, lig_id)
    rec_system = ff.createSystem(rec_top, **ff_kwargs)
    lig_system = ff.createSystem(lig_top, **ff_kwargs)
    rec_ctx = Context(rec_system, VerletIntegrator(0.001), plat)
    lig_ctx = Context(lig_system, VerletIntegrator(0.001), plat)

    nbetween = max(int(prod_ps * unit.picoseconds / (0.002 * unit.picoseconds) / nsnap), 1)
    dGs = []
    for _ in range(nsnap):
        sim.step(nbetween)
        st = sim.context.getState(getPositions=True, getEnergy=True)
        p = st.getPositions(asNumpy=True)
        Ec = st.getPotentialEnergy().value_in_unit(unit.kilocalorie_per_mole)
        Er = energy(rec_ctx, p[rec_idx])
        El = energy(lig_ctx, p[lig_idx])
        dGs.append(Ec - Er - El)
    dGs = np.array(dGs)
    return dict(dG=float(dGs.mean()), sem=float(dGs.std(ddof=1) / np.sqrt(len(dGs))),
                n_snap=len(dGs), rec_res=counts[rec_id], lig_res=counts[lig_id],
                rec_id=rec_id, lig_id=lig_id, all=dGs)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--structures-dir", required=True, help="dir with NKG7_<pid>.pdb")
    ap.add_argument("--out", required=True, help="output CSV")
    ap.add_argument("--pattern", default="NKG7_*.pdb")
    ap.add_argument("--nsnap", type=int, default=25)
    ap.add_argument("--eq-ps", type=float, default=50.0)
    ap.add_argument("--prod-ps", type=float, default=50.0)
    args = ap.parse_args()

    plat = get_platform()
    ff = app.ForceField("amber/protein.ff14SB.xml", "implicit/gbn2.xml")
    pdbs = sorted(glob.glob(os.path.join(args.structures_dir, args.pattern)))
    print(f"platform={plat.getName()} n_complexes={len(pdbs)}", flush=True)

    rows = []
    for pdb in pdbs:
        base = os.path.basename(pdb)
        pid = base.replace("NKG7_", "").replace(".pdb", "")
        try:
            r = run_one(pdb, ff, plat, args.nsnap, args.eq_ps, args.prod_ps)
            print(f"{pid}: dG={r['dG']:.2f} +/- {r['sem']:.2f} kcal/mol "
                  f"(n={r['n_snap']}, rec={r['rec_res']}res/{r['rec_id']}, "
                  f"lig={r['lig_res']}res/{r['lig_id']})", flush=True)
            rows.append((pid, f"{r['dG']:.3f}", f"{r['sem']:.3f}", r['n_snap'],
                         ';'.join(f"{x:.2f}" for x in r['all'])))
        except Exception as e:
            print(f"{pid}: FAILED -> {type(e).__name__}: {e}", flush=True)
            traceback.print_exc()
            rows.append((pid, "NA", "NA", 0, f"ERROR:{type(e).__name__}:{str(e)[:200]}"))

    with open(args.out, "w") as fh:
        fh.write("pep_id,dG_mmgbsa_kcal_mol,sem,n_snap,detail\n")
        for pid, dg, sem, n, detail in rows:
            fh.write(f"{pid},{dg},{sem},{n},{detail}\n")
    print(f"wrote {args.out} ({len(rows)} rows)", flush=True)


if __name__ == "__main__":
    main()
