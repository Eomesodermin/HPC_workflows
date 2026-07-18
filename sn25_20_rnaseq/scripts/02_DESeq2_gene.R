#!/usr/bin/env Rscript
# 02_DESeq2_gene.R — gene-level differential expression (SN25_20)
# Imports the gene-level tximport object and fits a DESeq2 model blocking on donor.
#
# Design: ~ donor + treatment   (donor = paired biological replicate; treatment = condition)
# EDIT the `contrasts` list below to match the comparisons you care about.
#
# Usage:  Rscript 02_DESeq2_gene.R <workspace_root>
suppressPackageStartupMessages({ library(DESeq2); library(readr); library(dplyr) })

args <- commandArgs(trailingOnly = TRUE)
WS  <- if (length(args) >= 1) args[1] else "/lustre/scratch/data/dcorvino_hpc-sn25_20_rnaseq"
OUT <- file.path(WS, "results"); dir.create(file.path(OUT,"de_gene"), showWarnings = FALSE, recursive = TRUE)

g <- readRDS(file.path(OUT, "txi_gene.rds"))
txi <- g$txi; samples <- g$samples
samples$treatment <- factor(samples$treatment)
samples$donor     <- factor(samples$donor)

dds <- DESeqDataSetFromTximport(txi, colData = samples, design = ~ donor + treatment)
# pre-filter low-count genes
keep <- rowSums(counts(dds) >= 10) >= 3
dds  <- dds[keep, ]
dds  <- DESeq(dds)
saveRDS(dds, file.path(OUT, "de_gene", "dds.rds"))

# normalized counts + VST (for PCA / heatmaps / QC)
vsd <- vst(dds, blind = FALSE)
write_tsv(as.data.frame(assay(vsd)) |> tibble::rownames_to_column("gene_id"),
          file.path(OUT, "de_gene", "vst_counts.tsv"))
write_tsv(as.data.frame(counts(dds, normalized = TRUE)) |> tibble::rownames_to_column("gene_id"),
          file.path(OUT, "de_gene", "normalized_counts.tsv"))

# ---- EDIT: define contrasts of interest -------------------------------------
# Treatment levels present:
message("treatment levels: ", paste(levels(samples$treatment), collapse = " | "))
# Example contrasts (adjust names to real levels). Each is c("treatment", A, B) => A vs B.
contrasts <- list(
  # transwell_vs_direct = c("treatment", "transwell", "direct")
)
for (nm in names(contrasts)) {
  res <- results(dds, contrast = contrasts[[nm]], alpha = 0.05)
  res <- lfcShrink(dds, contrast = contrasts[[nm]], res = res, type = "ashr")
  df  <- as.data.frame(res) |> tibble::rownames_to_column("gene_id") |> arrange(padj)
  write_tsv(df, file.path(OUT, "de_gene", paste0("DE_", nm, ".tsv")))
  message("wrote DE_", nm, ".tsv  (", sum(df$padj < 0.05, na.rm = TRUE), " sig at padj<0.05)")
}
message("DESeq2 gene-level done. See ", file.path(OUT, "de_gene"))
