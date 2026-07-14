# nkg7_neuropeptide_cofold — NKG7 × neuropeptide binding cross-check

Orthogonal structural validation of the neuropeptides the **Alex Loukas lab**
(Connor McHugh) nominated as candidate **NKG7** binders from an AlphaFold-Multimer
secretome screen. We re-model each nominated neuropeptide against full-length human
NKG7 with an independent predictor (**Boltz-2**), map the binding interface, and
stress-test specificity with composition-matched scrambled controls and
**MM/GBSA** binding-energy rescoring.

## Start here
- **`docs/REPORT.md`** — full integrated report for a non-structural audience:
  introduces every method/term, the workflow, inputs, decisions, results,
  interpretation, and wet-lab recommendations.

## Reproduce the figures/tables (no cluster needed)
```
python pipeline/interface_analysis.py    # contacts + loop assignment from structures/
python pipeline/render_complexes.py       # PyMOL renders (needs pymol)
```
(Figures and the ranked table are also committed under `figures/` and `results/`.)

## Layout
| dir | contents |
|---|---|
| `pipeline/` | compute scripts: Boltz YAML render, interface analysis, PyMOL render, peptide MM/GBSA |
| `inputs/` | NKG7 target sequence + neuropeptide panel (mature bioactive forms) |
| `results/` | numeric outputs (ranked confidence + contacts, null ipTM distributions, MM/GBSA dG) |
| `figures/` | rendered complex galleries + specificity summary panels |
| `structures/` | Boltz-2 co-fold coordinates (chain A = NKG7, chain B = peptide) |
| `envs/` | conda/pip environment specs + build gotchas (boltz, mmgbsa) |
| `docs/` | full report |

## Top result
All seven nominated neuropeptides co-fold confidently onto NKG7's **extracellular
loop 1 (ECL1, res 30–60)** — but so does a **scrambled negative control**
(ipTM 0.92), which out-scores five of the seven. **NKG7 ECL1 is a promiscuous
peptide-docking groove; interface confidence alone does not establish
specificity.** Only **MCH** and **PDYN** clearly beat the composition-matched
control. See `docs/REPORT.md` and `results/nkg7_neuropeptide_ranked.csv`.

## Compute
Ran on the marvin HPC cluster (SLURM, NVIDIA A40). Software: Boltz-2 v2.2.1
(co-folding, MSA server), OpenMM 8.2 + AmberTools 24 (ff14SB, GBn2 implicit
solvent) for peptide MM/GBSA. See `docs/REPORT.md` and `envs/`.
