# SN25_20 — Library prep & strandedness report

**Project:** P2026-217-RNA (Life & Brain genomics core, Bonn)
**Organism / reference:** *Mus musculus*, GRCm39, Ensembl release 116
**Samples:** 30 paired-end (3 NK-cell donors × 10 co-culture conditions)

## Strandedness — determined empirically

Strandedness was **not assumed**; it was inferred from the data using Salmon's automatic
library-type detection (`salmon quant -l A`) on three samples (one per donor). All three
independently returned:

| Sample | Detected library type |
|--------|-----------------------|
| DE04NGSUKBR157047 (NK3) | **ISR** |
| DE09NGSUKBR157054 (NK4) | **ISR** |
| DE10NGSUKBR157036 (NK2) | **ISR** |

**Conclusion: the library is reverse-stranded (ISR).**

`ISR` = **I**nward orientation, **S**tranded, **R**everse — i.e. read 2 corresponds to the
sense (transcript) strand. This is the signature of a **dUTP-based stranded mRNA-seq protocol**
(Illumina TruSeq Stranded mRNA and equivalents), the current standard for poly-A selected
stranded RNA-seq.

### Strandedness → tool flags (applied throughout)

| Tool | Setting used |
|------|--------------|
| featureCounts | `-s 2` (reverse) |
| Salmon | `-l ISR` |
| STAR ReadsPerGene | column 4 (reverse-strand counts) |
| RSeQC / HTSeq | "reverse" / `fr-firststrand` |
| rMATS | `--libType fr-firststrand` |
| regtools (LeafCutter) | `-s RF` |

The strong, uniform read-assignment rates below independently confirm `-s 2` is correct — a
wrong strand setting would leave most reads unassigned.

## Library / sequencing characteristics

- **Read layout:** paired-end, **2 × 100 bp** (mean read length 100 bp after trimming).
- **Depth:** mean **51.1 M read pairs/sample** (range 45.1–66.4 M) — well above the ~20–30 M
  typically sufficient for gene-level DE, and adequate for isoform/splice analysis.
- **Base quality:** Q30 rate 96.9–97.2 % after trimming (uniformly high).
- **Adapter/quality trimming (fastp):** 98.71 % of reads retained — minimal adapter contamination.

## Alignment / quantification QC (all 30 samples)

| Metric | Range | Mean |
|--------|-------|------|
| STAR uniquely mapped | 78.6 – 91.4 % | **85.2 %** |
| STAR multi-mapped | 4.6 – 5.3 % | 4.9 % |
| Salmon mapping rate | 73.9 – 89.7 % | **81.5 %** |

All samples are healthy and consistent; no outliers flagged. Per-sample values are in
`qc_per_sample.csv`.

## Provenance

- Strandedness probe: `workflows/strandedness.sh` (Salmon `-l A`, GRCm39 decoy-aware index).
- QC metrics aggregated from fastp JSON, STAR `Log.final.out`, and Salmon `meta_info.json`.
- Full interactive QC: MultiQC reports on the cluster (`qc/multiqc/multiqc_{raw,fastp,featurecounts,salmon}.html`).
