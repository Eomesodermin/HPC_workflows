#!/usr/bin/env Rscript
# 03_DTU_analysis.R — Differential Transcript Usage (SN25_20)
# Answers: "between conditions, does the PROPORTION of isoforms used shift?"
# Uses DRIMSeq for the DTU model + stageR for two-stage (gene->transcript) FDR control.
# (satuRn is a faster modern alternative; a satuRn block is included, commented.)
#
# Input : results/txi_tx.rds (transcript-level scaledTPM from 01_tximport.R)
# Usage : Rscript 03_DTU_analysis.R <workspace_root>
suppressPackageStartupMessages({
  library(DRIMSeq); library(stageR); library(readr); library(dplyr)
})

args <- commandArgs(trailingOnly = TRUE)
WS  <- if (length(args) >= 1) args[1] else "/lustre/scratch/data/dcorvino_hpc-sn25_20_rnaseq"
OUT <- file.path(WS, "results"); dir.create(file.path(OUT, "dtu"), showWarnings = FALSE, recursive = TRUE)

t <- readRDS(file.path(OUT, "txi_tx.rds"))
cts <- t$txi$counts; samples <- t$samples; tx2gene <- t$tx2gene

# ---- EDIT: subset to the two conditions to compare -------------------------
# DTU is pairwise; pick two treatment levels. Example:
#   grp <- samples$treatment %in% c("transwell","direct")
# For now default to ALL samples with treatment as the grouping (edit for a real contrast).
message("treatment levels: ", paste(sort(unique(samples$treatment)), collapse = " | "))
# ---- build DRIMSeq object ---------------------------------------------------
# strip tx version to match tx2gene
rownames(cts) <- sub("\\..*$", "", rownames(cts))
tx2gene$TXNAME <- sub("\\..*$", "", tx2gene$TXNAME)
counts_df <- data.frame(
  gene_id       = tx2gene$GENEID[match(rownames(cts), tx2gene$TXNAME)],
  feature_id    = rownames(cts),
  cts, check.names = FALSE
)
counts_df <- counts_df[!is.na(counts_df$gene_id), ]

sdf <- data.frame(sample_id = samples$sample_id,
                  condition = factor(samples$treatment),
                  donor     = factor(samples$donor))

d <- dmDSdata(counts = counts_df, samples = sdf)
# filter: transcript expressed in >=n samples, gene-level expression, etc.
n <- nrow(sdf); n.small <- min(table(sdf$condition))
d <- dmFilter(d, min_samps_gene_expr = n, min_samps_feature_expr = n.small,
              min_gene_expr = 10, min_feature_expr = 10)
message("genes after filter: ", length(d))

# design: block on donor, test condition
design <- model.matrix(~ donor + condition, data = DRIMSeq::samples(d))
set.seed(1)
d <- dmPrecision(d, design = design)
d <- dmFit(d, design = design)
# test the LAST condition coefficient (edit `coef` for a specific contrast)
coef_name <- tail(colnames(design), 1)
d <- dmTest(d, coef = coef_name)
saveRDS(d, file.path(OUT, "dtu", "drimseq_d.rds"))

res_gene <- DRIMSeq::results(d)                     # gene-level
res_txp  <- DRIMSeq::results(d, level = "feature")  # transcript-level
write_tsv(res_gene, file.path(OUT, "dtu", "drimseq_gene.tsv"))
write_tsv(res_txp,  file.path(OUT, "dtu", "drimseq_transcript.tsv"))

# ---- stageR two-stage FDR (screen genes, confirm transcripts) ---------------
pScreen <- res_gene$pvalue; names(pScreen) <- res_gene$gene_id
pConf   <- matrix(res_txp$pvalue, ncol = 1)
rownames(pConf) <- res_txp$feature_id
tx2gene_sg <- res_txp[, c("feature_id","gene_id")]
pScreen[is.na(pScreen)] <- 1; pConf[is.na(pConf)] <- 1
stageRObj <- stageRTx(pScreen = pScreen, pConfirmation = pConf,
                      pScreenAdjusted = FALSE, tx2gene = tx2gene_sg)
stageRObj <- stageWiseAdjustment(stageRObj, method = "dtu", alpha = 0.05)
padj <- getAdjustedPValues(stageRObj, order = TRUE, onlySignificantGenes = FALSE)
write_tsv(padj, file.path(OUT, "dtu", "stageR_dtu_padj.tsv"))
message("DTU (DRIMSeq+stageR) done. See ", file.path(OUT, "dtu"))

# ---- Alternative: satuRn (faster, handles many samples) ---------------------
# suppressPackageStartupMessages(library(satuRn))
# See https://bioconductor.org/packages/satuRn for the SummarizedExperiment workflow.
