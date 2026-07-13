# Domínguez Conde cross-tissue atlas — VDJ realignment (Workstream 1)

HPC (Marvin) scripts that realigned the TCR V(D)J libraries of the Domínguez Conde
cross-tissue immune atlas (E-MTAB-11536, ENA PRJEB51634) to produce the NK TCR-footprint
results in `Thymic_NK_development/scripts/analysis/` and `results/`.

Only the **77 VDJ-enrichment libraries** were realigned (220.6 GB FASTQ); GEX was not
realigned — published CellTypist NK annotations were reused and joined by barcode. See
`Thymic_NK_development/domconde_alignment_scope.md` for the full scope + join logic.

| script | what |
|---|---|
| `cr_vdj_smoke.sh` | single-library smoke test (`cellranger vdj --chain TR` on `all_contig`) |
| `cr_vdj_one.sh` | per-library alignment template (ENA download + cellranger, `--chain TR`) |
| `submit_all.sh` | submit all 77 libraries as separate SLURM jobs |
| `resubmit.sh` | resubmit libraries that failed (γδ chain-detection fix: `--chain TR` on every job) |
| `resubmit15.sh` | resubmit the 15 that failed on truncated/empty FASTQ downloads (retry-hardened curl) |

Ran on Marvin under `/lustre/scratch/data/dcorvino_hpc-thymic_nk_development/`
(account `ag_iei_abdullah`, cellranger 9.0.1, VDJ ref refdata-cellranger-vdj-GRCh38-alts-ensembl-7.1.0).
Harvest + footprint analysis: `Thymic_NK_development/scripts/analysis/{harvest_footprint.py,footprint_pipeline.py}`.
