# MM/GBSA + DiffDock envs (marvin)

## diffdock (conda env, python 3.10)
- torch==2.1.0+cu121 (PINNED via pip constraints file on every install)
- torch_geometric, torch-scatter, torch-sparse, torch-cluster (PyG binaries from https://data.pyg.org/whl/torch-2.1.0+cu121.html, installed LAST)
- e3nn, fair-esm, rdkit, biopython, networkx, pandas, scipy, prody, spyrmsd, pot
- DiffDock-L repo: software/DiffDock; weights download on first inference
- GOTCHA: e3nn silently upgrades torch -> breaks PyG binaries. Constraints file mandatory.
- GOTCHA: batch.csv protein_path must be ABSOLUTE (DiffDock cd's to repo dir).

## mmgbsa (conda env, python 3.10, conda-forge)
- openmm 8.2, openff-toolkit, openmmforcefields, ambertools, pdbfixer, mdtraj, parmed
- pipeline/mmgbsa.py: single-trajectory MM/GBSA (ff14SB + GAFF2/AM1-BCC, GBn2 implicit solvent)
- GOTCHA: after AddHs, clear per-atom PDB residue info (SetMonomerInfo(None)) or ligand splits into
  2 residues [LIG,UNK] -> SystemGenerator "No template found for residue LIG".
- Runtime: ~50s/target (GPCR, 25 snapshots/50ps, 1 A40).
