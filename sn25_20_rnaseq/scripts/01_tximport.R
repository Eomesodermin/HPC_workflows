#!/usr/bin/env Rscript
# 01_tximport.R — import Salmon quantifications for SN25_20
# Produces:
#   - txi.gene  : gene-level counts/abundance (for DESeq2 gene DE)      -> results/txi_gene.rds
#   - txi.tx    : transcript-level (scaledTPM) for DTU                   -> results/txi_tx.rds
#   - tx2gene   : transcript->gene map from the Ensembl GRCm39 GTF       -> results/tx2gene.tsv
#
# Strandedness: library is ISR (reverse-stranded); Salmon was run with -l ISR.
# Usage:  Rscript 01_tximport.R <workspace_root>
#   default workspace_root = /lustre/scratch/data/dcorvino_hpc-sn25_20_rnaseq
suppressPackageStartupMessages({
  library(tximport); library(txdbmaker); library(readr); library(AnnotationDbi)
})

args <- commandArgs(trailingOnly = TRUE)
WS  <- if (length(args) >= 1) args[1] else "/lustre/scratch/data/dcorvino_hpc-sn25_20_rnaseq"
GTF <- file.path(WS, "reference", "Mus_musculus.GRCm39.116.gtf.gz")
QDIR <- file.path(WS, "quant_salmon")
OUT  <- file.path(WS, "results"); dir.create(OUT, showWarnings = FALSE, recursive = TRUE)

# ---- sample table -----------------------------------------------------------
samples <- read_tsv(file.path(WS, "scripts", "samples.tsv"), show_col_types = FALSE)
samples$files <- file.path(QDIR, samples$deid, "quant.sf")
stopifnot(all(file.exists(samples$files)))
# factors: donor (blocking), treatment (of interest)
samples$donor     <- factor(samples$donor)
samples$treatment <- factor(samples$treatment)
message("Samples: ", nrow(samples), " | donors: ", paste(levels(samples$donor), collapse=","))

# ---- tx2gene from GTF -------------------------------------------------------
t2g_path <- file.path(OUT, "tx2gene.tsv")
if (!file.exists(t2g_path)) {
  txdb <- txdbmaker::makeTxDbFromGFF(GTF, format = "gtf")
  k    <- keys(txdb, keytype = "TXNAME")
  tx2gene <- AnnotationDbi::select(txdb, k, "GENEID", "TXNAME")
  write_tsv(tx2gene, t2g_path)
} else {
  tx2gene <- read_tsv(t2g_path, show_col_types = FALSE)
}
# Salmon tx IDs carry Ensembl version suffixes (ENSMUST....N); tximport ignoreTxVersion handles it.

# ---- gene-level (for DESeq2) ------------------------------------------------
txi.gene <- tximport(samples$files, type = "salmon", tx2gene = tx2gene,
                     ignoreTxVersion = TRUE)
colnames(txi.gene$counts) <- samples$sample_id
saveRDS(list(txi = txi.gene, samples = samples), file.path(OUT, "txi_gene.rds"))

# ---- transcript-level (for DTU): scaledTPM keeps counts on transcript scale --
txi.tx <- tximport(samples$files, type = "salmon", txOut = TRUE,
                   countsFromAbundance = "scaledTPM", ignoreTxVersion = TRUE)
colnames(txi.tx$counts) <- samples$sample_id
saveRDS(list(txi = txi.tx, samples = samples, tx2gene = tx2gene),
        file.path(OUT, "txi_tx.rds"))

message("tximport done. Wrote txi_gene.rds, txi_tx.rds, tx2gene.tsv to ", OUT)
