#!/bin/bash
#SBATCH --account=ag_iei_abdullah
#SBATCH --partition=intelsr_medium
#SBATCH --cpus-per-task=16
#SBATCH --mem=32G
#SBATCH --time=08:00:00
#SBATCH --job-name=sn25_trim
#SBATCH --output=%x_%j.log
set -euo pipefail
source /opt/software/easybuild-INTEL/software/Miniforge3/24.1.2-0/etc/profile.d/conda.sh
conda activate rnaseq_quant
WS=$(ws_find sn25_20_rnaseq)
IN=$WS/raw; OUT=$WS/trimmed; REP=$WS/qc/fastp; mkdir -p $OUT $REP
START=$SECONDS
# Process samples with bounded parallelism: 4 concurrent, each fastp uses 4 threads (=16 cpus).
export WS OUT IN REP
run_one() {
  DEID=$1
  R1=$IN/${DEID}_1.fq.gz; R2=$IN/${DEID}_2.fq.gz
  O1=$OUT/${DEID}_1.trimmed.fq.gz; O2=$OUT/${DEID}_2.trimmed.fq.gz
  [ -s "$O1" ] && [ -s "$O2" ] && { echo "skip $DEID (exists)"; return 0; }
  fastp -i $R1 -I $R2 -o $O1 -O $O2 \
    --detect_adapter_for_pe \
    --qualified_quality_phred 20 --length_required 25 \
    --thread 4 \
    --json $REP/${DEID}.fastp.json --html $REP/${DEID}.fastp.html \
    2> $REP/${DEID}.fastp.stderr
  echo "done $DEID"
}
export -f run_one
tail -n +2 $WS/scripts/samples.tsv | cut -f2 | xargs -P4 -I{} bash -c 'run_one "$@"' _ {}
echo "all fastp done in $((SECONDS-START))s"
# aggregate fastp + post-trim fastqc later; MultiQC on fastp json now
cd $WS/qc
multiqc -f -o $WS/qc/multiqc -n multiqc_fastp $REP
echo "TRIM_OK"
ls $OUT/*.trimmed.fq.gz | wc -l | xargs echo 'trimmed files:'
