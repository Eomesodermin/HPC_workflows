# SN25_20 — bulk RNA-seq (NK-cell co-culture)

Bulk RNA-seq alignment and quantification on the **marvin** CPU cluster, producing
outputs for gene-level differential expression **and** isoform/splice-variant analysis.

- **Project:** P2026-217-RNA (Life & Brain genomics core, Bonn)
- **Organism / reference:** *Mus musculus*, GRCm39, Ensembl release 116
- **Design:** 30 paired-end samples = **3 NK-cell donors (NK2, NK3, NK4) × 10 co-culture conditions**
- **Library:** reverse-stranded (ISR / dUTP), 2×100 bp, mean 51 M read pairs/sample
- **Reusable skill:** `bulk-rnaseq-star-salmon` (captures this pipeline + the three marvin gotchas)

## Directory layout

- `workflows/` — SLURM job scripts (final working versions) + `samples.tsv` manifest
- `scripts/` — downstream analysis: R (tximport → DESeq2, DTU, QC/PCA), rMATS/LeafCutter, python helpers
- `results/` — library-prep/strandedness report, per-sample QC table, pipeline metrics
- `docs/` — `PIPELINE.md` (full method + rationale)

Large outputs (BAMs, count matrices, quant.sf, MultiQC HTML) live on marvin at
`/lustre/scratch/data/dcorvino_hpc-sn25_20_rnaseq/` and are not tracked here.

## Sample design

Balanced: every treatment has exactly one sample per donor (3 donors × 10 treatments = 30).
Cell IDs below are the facility DE-IDs (== `sample_id` in `workflows/samples.tsv`).

| Treatment | NK2 | NK3 | NK4 |
|---|---|---|---|
| `direct` | DE21NGSUKBR157032 | DE42NGSUKBR157042 | DE63NGSUKBR157052 |
| `stickers_direct` | DE91NGSUKBR157033 | DE15NGSUKBR157043 | DE36NGSUKBR157053 |
| `floaters_direct` | DE64NGSUKBR157034 | DE85NGSUKBR157044 | DE09NGSUKBR157054 |
| `stickers_direct_tumor` | DE37NGSUKBR157035 | DE58NGSUKBR157045 | DE79NGSUKBR157055 |
| `floaters_direct_tumor` | DE10NGSUKBR157036 | DE31NGSUKBR157046 | DE52NGSUKBR157056 |
| `transwell` | DE80NGSUKBR157037 | DE04NGSUKBR157047 | DE25NGSUKBR157057 |
| `stickers_transwell` | DE53NGSUKBR157038 | DE74NGSUKBR157048 | DE95NGSUKBR157058 |
| `floaters_transwell` | DE26NGSUKBR157039 | DE47NGSUKBR157049 | DE68NGSUKBR157059 |
| `stickers_transwell_bottom` | DE96NGSUKBR157040 | DE20NGSUKBR157050 | DE41NGSUKBR157060 |
| `floaters_transwell_bottom` | DE69NGSUKBR157041 | DE90NGSUKBR157051 | DE14NGSUKBR157061 |

### The 10 conditions

Two co-culture formats, each with sub-populations:

- **`direct`** — NK cells in direct contact with the co-cultured cells.
  - `stickers_direct` / `floaters_direct` — adherent vs non-adherent NK fractions.
  - `stickers_direct_tumor` / `floaters_direct_tumor` — the same fractions in the **tumor** direct co-culture.
- **`transwell`** — NK cells separated by a transwell membrane (no direct contact).
  - `stickers_transwell` / `floaters_transwell` — adherent vs non-adherent fractions.
  - `stickers_transwell_bottom` / `floaters_transwell_bottom` — fractions from the transwell **bottom** chamber.

> Note: the condition labels are read verbatim from the facility sample sheet
> (`Sample_Allocation_P2026-217-RNA.txt`). Confirm the biological meaning of
> "stickers/floaters", "tumor", and "bottom" against the wet-lab design before
> finalizing contrasts.

## Analysis status

Alignment, quantification, and QC are **complete** for all 30 samples. The
DE / DTU / splice-event scripts are ready but the **contrasts are not yet
defined** — donor is handled as a blocking factor (`~ donor + treatment`); the
specific condition comparisons are chosen per the biological question. Edit the
marked blocks in `scripts/02_DESeq2_gene.R`, `scripts/03_DTU_analysis.R`,
`scripts/04_rmats_splice.sh`, and `scripts/05_leafcutter_splice.sh`.

## Companion repo

Analysis-facing mirror: `Eomesodermin/SN25_20_analysis` (GitHub).
