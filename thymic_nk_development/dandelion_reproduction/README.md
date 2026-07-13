# Dandelion NK/ILC-from-DN reproduction — HPC (Marvin) alignment

Reproduces the VDJ alignment for the Suo et al. fetal-immune atlas (E-MTAB-11388,
scVDJ-seq), used to rebuild the TCR feature space for the Dandelion Fig 5b/c trajectory.

## Files
- `cr_vdj_suo_one.sh`   sbatch script, one abTCR library per job. Downloads R1/R2 from
                        ENA, runs `cellranger vdj --chain TR` (TCR ref, retains
                        non-productive contigs in all_contig_annotations.csv).
                        Resources: intelsr_medium, 16 cpu, 48G, 4h. Idempotent.
- `submit_suo_all.sh`   submits all 64 recipe-carrying abTCR libraries.
- `../../../Thymic_NK_development/data/dandelion_reproduction/suo_abTCR_vdj_manifest.{csv,json}`
                        lane -> GEX_id -> ENA run -> FASTQ URI mapping (64 libs).

## Scope
64 abTCR libraries (E-MTAB-11388) carrying the 10 recipe cell types
(DN/DP T, ILC2/3, CYCLING_ILC, NK, CYCLING_NK). 44,451 recipe cells have paired abTCR.
gd libraries not needed (trajectory feature space uses TRBJ = beta chain).

## Downstream
After alignment: sc-dandelion container `dandelion-preprocess --file_prefix all --chain TR`
(keeps non-productive), then local trajectory pipeline (ddl.tl.setup_vdj_pseudobulk ->
Milo -> vdj_pseudobulk -> Palantir).

Marvin workspace: /lustre/scratch/data/dcorvino_hpc-thymic_nk_development/work/suovdj_<lane>/
