#!/bin/bash
# 04_rmats_splice.sh — event-level alternative splicing (rMATS-turbo) for SN25_20
# Detects exon skipping (SE), alt 5'/3' SS (A5SS/A3SS), mutually-exclusive exons (MXE),
# and intron retention (RI) BETWEEN TWO CONDITIONS from the STAR genome BAMs.
#
# rMATS is pairwise (group b1 vs b2). EDIT the two sample groups below.
# rMATS-turbo is not an EasyBuild module here — install into a conda env once:
#   conda create -y -n rmats -c conda-forge -c bioconda rmats=4.3.0
#
#SBATCH --account=ag_iei_abdullah
#SBATCH --partition=intelsr_short
#SBATCH --cpus-per-task=12
#SBATCH --mem=32G
#SBATCH --time=04:00:00
#SBATCH --job-name=sn25_rmats
#SBATCH --output=%x_%j.log
set -euo pipefail
source /opt/software/easybuild-INTEL/software/Miniforge3/24.1.2-0/etc/profile.d/conda.sh
conda activate rmats
WS=$(ws_find sn25_20_rnaseq)
GTF=$WS/reference/Mus_musculus.GRCm39.116.gtf.gz
BAMDIR=$WS/align_star
OUT=$WS/results/splice_rmats; mkdir -p $OUT
# read length for rMATS (trimmed reads vary; use nominal 150, rMATS handles variable with --variable-read-length)
READLEN=150

# ---- EDIT: define the two groups to compare (comma-separated BAM paths) -----
# Example: transwell vs direct, all three donors (paired design captured post-hoc)
group_bams () {  # $1 = space-separated DEIDs -> comma-joined bam paths
  local out=""
  for d in $1; do out+="$BAMDIR/$d/$d.Aligned.sortedByCoord.out.bam,"; done
  echo "${out%,}"
}
# Fill these from scripts/samples.tsv (deid column) for the treatments you want:
B1_DEIDS=""   # e.g. "DE80NGSUKBR157037 DE53NGSUKBR157038 DE26NGSUKBR157039"  (transwell)
B2_DEIDS=""   # e.g. "DE21NGSUKBR157032 DE42NGSUKBR157042 DE63NGSUKBR157052"  (direct)

if [ -z "$B1_DEIDS" ] || [ -z "$B2_DEIDS" ]; then
  echo "EDIT B1_DEIDS/B2_DEIDS to the two condition groups before running." >&2
  echo "Available samples:" >&2; tail -n +2 $WS/scripts/samples.tsv | cut -f2,5 >&2
  exit 1
fi
group_bams "$B1_DEIDS" > $OUT/b1.txt
group_bams "$B2_DEIDS" > $OUT/b2.txt
zcat $GTF > $OUT/genes.gtf   # rMATS wants uncompressed GTF

rmats.py --b1 $OUT/b1.txt --b2 $OUT/b2.txt \
  --gtf $OUT/genes.gtf -t paired --readLength $READLEN --variable-read-length \
  --nthread 12 --od $OUT --tmp $OUT/tmp \
  --libType fr-firststrand      # ISR / reverse-stranded
echo "rMATS done. Event tables (*.MATS.JC.txt / JCEC) in $OUT"
