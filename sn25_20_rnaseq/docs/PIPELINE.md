# SN25_20 — bulk RNA-seq pipeline (mouse GRCm39)

Dual-quantification bulk RNA-seq processing on the **marvin** HPC cluster (University of Bonn),
supporting both **gene-level differential expression** and **isoform / splice-variant analysis**.

## Experiment

- **30 paired-end samples** — Life & Brain genomics core (Bonn), project P2026-217-RNA.
- **3 NK-cell donors** (NK2, NK3, NK4) × **10 co-culture conditions**:
  `direct`, `stickers direct`, `floaters direct`, `stickers direct tumor`, `floaters direct tumor`,
  `transwell`, `stickers transwell`, `floaters transwell`, `stickers transwell bottom`, `floaters transwell bottom`.
- Balanced design (10 per donor) → **block on donor** in all DE/DTU models.
- Library: **reverse-stranded (ISR / dUTP)**, empirically confirmed (Salmon `-l A` auto-detect,
  all probes → `ISR`; mapping rates 75–90 %). featureCounts uses `-s 2`.

Sample→condition map: `hpc_scripts/samples.tsv` (authoritative manifest for every job).

## Reference

- Ensembl **release 116**, **GRCm39** — primary-assembly genome, cDNA, ncRNA, and GTF.
- STAR genome index built with the GTF (`--sjdbOverhang 100`).
- Salmon **decoy-aware** index (gentrome = cDNA + ncRNA transcripts + genome decoys, k=31).

## Design rationale — why two quantifiers

| Goal | Tool | Output |
|------|------|--------|
| Gene-level DE | **STAR** genome alignment → featureCounts | `counts/featurecounts.txt` → DESeq2/edgeR |
| Transcript expression / usage (DTE/DTU) | **Salmon** transcriptome quant | `quant_salmon/*/quant.sf` → tximport → DESeq2 / DRIMSeq |
| Event-level splicing (SE/RI/A5SS/A3SS/MXE) | **STAR BAMs** → rMATS / LeafCutter | `results/splice_*` |

STAR is run **2-pass** (`--twopassMode Basic`) to improve novel-junction discovery for the
splice-event analysis. Salmon is run with `--gcBias --seqBias --numGibbsSamples 20` so that
DTU tools can propagate quantification uncertainty.

## Workspace layout (on marvin Lustre)

```
/lustre/scratch/data/dcorvino_hpc-sn25_20_rnaseq/
├── raw/            # 60 FASTQs + md5sum.txt + sample sheet (md5-verified)
├── trimmed/        # fastp-trimmed reads
├── reference/      # GRCm39 genome/cDNA/ncRNA/GTF + STAR/Salmon build inputs
├── star_index/     # STAR genome index
├── salmon_index/   # Salmon decoy-aware index
├── align_star/     # per-sample STAR BAMs (coord-sorted + .bai) + ReadsPerGene
├── quant_salmon/   # per-sample Salmon quant.sf
├── counts/         # featureCounts gene matrix
├── qc/             # FastQC (raw), fastp reports, MultiQC
├── results/        # tximport objects, DE/DTU/splice outputs, figures
└── scripts/        # SLURM job scripts + samples.tsv
```

## Pipeline stages & job scripts

Run order (each is a SLURM job; `--account=ag_iei_abdullah`, CPU `intelsr_*` partitions):

1. `hpc_scripts/build_env.sh` — conda env `rnaseq_quant` (salmon, subread, fastp, multiqc, rseqc, gffread, samtools).
2. `hpc_scripts/download_fastqs.sh` — rclone WebDAV pull of FASTQs (resumable, md5-verified). *No secret in-script; the share password is passed via `sbatch --export` at submit time.*
3. `hpc_scripts/build_star_index.sh`, `hpc_scripts/build_salmon_index.sh` — indexes.
4. `hpc_scripts/qc_raw.sh` — FastQC + MultiQC on raw reads.
5. `hpc_scripts/trim_fastp.sh` — fastp adapter/quality trimming (30 samples, bounded parallelism).
6. `hpc_scripts/strandedness.sh` — Salmon `-l A` library-type auto-detect (→ ISR).
7. `hpc_scripts/align_star.sh` — STAR 2-pass → coord-sorted BAMs + gene counts. **Loads `OpenSSL/1.1` and exports `LD_LIBRARY_PATH`** (STAR 2.7.11b needs `libcrypto.so.1.1`, which is not inherited by forked subshells otherwise).
8. `scripts/06_featurecounts.sh` — gene count matrix (`-s 2`) → DESeq2 input.
9. `hpc_scripts/quant_salmon.sh` — Salmon per-transcript quant.

### Downstream analysis (R, run locally or on marvin)

- `R/01_tximport.R` — Salmon → gene- and transcript-level objects + `tx2gene`.
- `R/02_DESeq2_gene.R` — gene DE, design `~ donor + treatment` (**edit contrasts**).
- `R/03_DTU_analysis.R` — differential transcript **usage** (DRIMSeq + stageR two-stage FDR; satuRn alt noted). *This answers "do conditions use different isoforms?"*
- `R/04_qc_pca.R` — VST PCA + sample-distance heatmap.
- `scripts/04_rmats_splice.sh` — rMATS-turbo event-level splicing (**edit the two groups**).
- `scripts/05_leafcutter_splice.sh` — LeafCutter annotation-free intron splicing (**edit groups**).

## What still needs your input

The DE/DTU/splice comparisons are **pairwise between conditions** — the exact contrasts depend on
your biological questions. Edit the marked `contrasts` / `B1_DEIDS`/`B2_DEIDS` / group blocks in
scripts 02, 03, 04, 05 to define which of the 10 conditions to compare (donor is already handled as
a blocking factor). rMATS and LeafCutter are scaffolded but not yet installed as envs — see the
header of each script for the one-line conda create.

## Reproducibility notes

- All tool versions pinned in `build_env.sh`; STAR/SAMtools/FastQC from EasyBuild modules
  (`STAR/2.7.11b-GCC-12.3.0`, `SAMtools/1.21-GCC-13.3.0`, `FastQC/0.12.1-Java-11`).
- FASTQs verified against the facility `md5sum.txt` (60/60 OK) before processing.
