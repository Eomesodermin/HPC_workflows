#!/bin/bash
#SBATCH --account=ag_iei_abdullah
#SBATCH --partition=intelsr_short
#SBATCH --cpus-per-task=12
#SBATCH --mem=24G
#SBATCH --time=02:00:00
#SBATCH --job-name=sn25_strand
#SBATCH --output=%x_%j.log
set -euo pipefail
source /opt/software/easybuild-INTEL/software/Miniforge3/24.1.2-0/etc/profile.d/conda.sh
conda activate rnaseq_quant
WS=$(ws_find sn25_20_rnaseq)
IDX=$WS/salmon_index
OUT=$WS/qc/strandedness; mkdir -p $OUT
# Pick 3 samples (one per donor) for a quick libType=A auto-detect on a read subset.
# Salmon --libType A reports the auto-detected library type in lib_format_counts.json / logs.
SAMPLES=$(tail -n +2 $WS/scripts/samples.tsv | awk -F'\t' '!seen[$3]++ {print $2}' | head -3)
echo "probe samples: $SAMPLES"
for DEID in $SAMPLES; do
  R1=$WS/raw/${DEID}_1.fq.gz; R2=$WS/raw/${DEID}_2.fq.gz
  echo "=== $DEID ==="
  salmon quant -i $IDX -l A -1 $R1 -2 $R2 -p 12 \
     --validateMappings -o $OUT/$DEID 2>&1 | tail -3
  echo "--- detected libtype ($DEID) ---"
  grep -E 'expected_format|compatible_fragment_ratio|strand_mapping_bias' $OUT/$DEID/lib_format_counts.json 2>/dev/null
done
echo "STRAND_PROBE_OK"
