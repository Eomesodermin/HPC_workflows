#!/bin/bash
#SBATCH --account=ag_iei_abdullah
#SBATCH --partition=intelsr_medium
#SBATCH --cpus-per-task=16
#SBATCH --mem=64G
#SBATCH --time=08:00:00
#SBATCH --job-name=sn25_salmon
#SBATCH --output=%x_%j.log
set -euo pipefail
source /opt/software/easybuild-INTEL/software/Miniforge3/24.1.2-0/etc/profile.d/conda.sh
conda activate rnaseq_quant
WS=$(ws_find sn25_20_rnaseq)
IDX=$WS/salmon_index; TRIM=$WS/trimmed; OUT=$WS/quant_salmon; mkdir -p $OUT
START=$SECONDS
# ONE sample at a time, 16 threads each (avoids the OOM from 2 concurrent + Gibbs)
while IFS=$'\t' read -r DEID; do
  R1=$TRIM/${DEID}_1.trimmed.fq.gz; R2=$TRIM/${DEID}_2.trimmed.fq.gz
  D=$OUT/$DEID
  [ -s "$D/quant.sf" ] && { echo "skip $DEID"; continue; }
  salmon quant -i $IDX -l ISR -1 $R1 -2 $R2 -p 16 \
    --validateMappings --gcBias --seqBias \
    --numGibbsSamples 20 \
    -o $D > $D.salmon.log 2>&1
  echo "done $DEID ($(date +%T))"
done < <(tail -n +2 $WS/scripts/samples.tsv | cut -f2)
NQ=$(ls $OUT/*/quant.sf 2>/dev/null | wc -l)
echo "all salmon done in $((SECONDS-START))s ; quant.sf=$NQ"
cd $WS/qc && multiqc -f -o $WS/qc/multiqc -n multiqc_salmon $OUT
[ "$NQ" -eq 30 ] && echo "SALMON_QUANT_OK" || { echo "SALMON_INCOMPLETE ($NQ/30)"; exit 1; }
