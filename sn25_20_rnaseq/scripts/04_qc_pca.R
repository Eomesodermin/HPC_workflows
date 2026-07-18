#!/usr/bin/env Rscript
# 04_qc_pca.R — sample-level QC: PCA + sample-distance heatmap from VST counts
# Run after 02_DESeq2_gene.R (needs de_gene/dds.rds).
suppressPackageStartupMessages({ library(DESeq2); library(ggplot2); library(pheatmap) })
args <- commandArgs(trailingOnly = TRUE)
WS  <- if (length(args) >= 1) args[1] else "/lustre/scratch/data/dcorvino_hpc-sn25_20_rnaseq"
OUT <- file.path(WS, "results", "de_gene")
FIG <- file.path(WS, "results", "figures"); dir.create(FIG, showWarnings = FALSE, recursive = TRUE)

dds <- readRDS(file.path(OUT, "dds.rds"))
vsd <- vst(dds, blind = TRUE)

# PCA coloured by treatment, shaped by donor
p <- plotPCA(vsd, intgroup = c("treatment","donor"), returnData = TRUE)
pv <- round(100 * attr(p, "percentVar"))
gg <- ggplot(p, aes(PC1, PC2, colour = treatment, shape = donor)) +
  geom_point(size = 3) +
  labs(x = paste0("PC1 (", pv[1], "%)"), y = paste0("PC2 (", pv[2], "%)"),
       title = "SN25_20 — VST PCA") + theme_bw()
ggsave(file.path(FIG, "pca.pdf"), gg, width = 8, height = 6)

# sample-distance heatmap
sampleDists <- dist(t(assay(vsd)))
m <- as.matrix(sampleDists)
pheatmap(m, clustering_distance_rows = sampleDists,
         clustering_distance_cols = sampleDists,
         filename = file.path(FIG, "sample_distance_heatmap.pdf"),
         width = 9, height = 8)
message("QC figures written to ", FIG)
