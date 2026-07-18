#!/bin/bash
#SBATCH --account=ag_iei_abdullah
#SBATCH --partition=intelsr_medium
#SBATCH --cpus-per-task=24
#SBATCH --mem=128G
#SBATCH --time=20:00:00
#SBATCH --job-name=sn25_star
#SBATCH --output=%x_%j.log
set -euo pipefail
module load STAR/2.7.11b-GCC-12.3.0 OpenSSL/1.1 SAMtools/1.21-GCC-13.3.0
# ensure the OpenSSL 1.1 libs are on the loader path for all subshells
export LD_LIBRARY_PATH="/opt/software/easybuild-INTEL/software/OpenSSL/1.1/lib:${LD_LIBRARY_PATH:-}"
STAR --version   # fail fast if libcrypto still missing
WS=$(ws_find sn25_20_rnaseq)
IDX=$WS/star_index; TRIM=$WS/trimmed; OUT=$WS/align_star; mkdir -p $OUT
START=$SECONDS
export WS IDX TRIM OUT LD_LIBRARY_PATH
align_one() {
  set -euo pipefail
  DEID=$1
  R1=$TRIM/${DEID}_1.trimmed.fq.gz; R2=$TRIM/${DEID}_2.trimmed.fq.gz
  D=$OUT/$DEID; mkdir -p $D
  BAM=$D/${DEID}.Aligned.sortedByCoord.out.bam
  if [ -s "$BAM" ]; then echo "skip $DEID (bam exists)"; return 0; fi
  STAR --runMode alignReads \
    --genomeDir $IDX \
    --readFilesIn $R1 $R2 --readFilesCommand zcat \
    --runThreadN 12 \
    --twopassMode Basic \
    --outSAMtype BAM SortedByCoordinate \
    --quantMode GeneCounts \
    --outSAMstrandField intronMotif \
    --limitBAMsortRAM 15000000000 \
    --outFileNamePrefix $D/${DEID}. \
    > $D/star.log 2>&1
  test -s "$BAM"          # hard fail if BAM absent
  samtools index -@ 4 "$BAM"
  echo "done $DEID ($(date +%T))"
}
export -f align_one
# 2 concurrent STAR, each 12 threads; --halt so a failure surfaces
tail -n +2 $WS/scripts/samples.tsv | cut -f2 | xargs -P2 -I{} bash -c 'align_one "$@"' _ {}
NBAM=$(ls $OUT/*/*.Aligned.sortedByCoord.out.bam 2>/dev/null | wc -l)
echo "all STAR done in $((SECONDS-START))s ; bams=$NBAM"
[ "$NBAM" -eq 30 ] && echo "STAR_ALIGN_OK" || { echo "STAR_ALIGN_INCOMPLETE ($NBAM/30)"; exit 1; }
