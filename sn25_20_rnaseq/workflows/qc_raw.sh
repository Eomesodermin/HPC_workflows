#!/bin/bash
#SBATCH --account=ag_iei_abdullah
#SBATCH --partition=intelsr_short
#SBATCH --cpus-per-task=8
#SBATCH --mem=32G
#SBATCH --time=04:00:00
#SBATCH --job-name=sn25_qcraw
#SBATCH --output=%x_%j.log
set -euo pipefail
source /opt/software/easybuild-INTEL/software/Miniforge3/24.1.2-0/etc/profile.d/conda.sh
conda activate rnaseq_quant
# install fastqc into the env if not present (uses env's own freetype -> no libfreetype crash)
if ! command -v fastqc >/dev/null 2>&1; then
  echo "installing fastqc into rnaseq_quant..."
  conda install -y -n rnaseq_quant -c conda-forge -c bioconda fastqc=0.12.1 2>&1 | tail -3
fi
which fastqc; fastqc --version
WS=$(ws_find sn25_20_rnaseq)
OUT=$WS/qc/fastqc_raw; mkdir -p $OUT
START=$SECONDS
# process only files lacking a zip
for fq in $WS/raw/*.fq.gz; do
  b=$(basename $fq .fq.gz)
  [ -s "$OUT/${b}_fastqc.zip" ] && continue
  echo "$fq"
done > $OUT/todo.txt
echo "todo: $(wc -l < $OUT/todo.txt)"
if [ -s $OUT/todo.txt ]; then
  cat $OUT/todo.txt | xargs -P4 -I{} fastqc -o $OUT {}
fi
echo "FastQC done in $((SECONDS-START))s"
multiqc -f -o $WS/qc/multiqc -n multiqc_raw $OUT
NZ=$(ls $OUT/*_fastqc.zip 2>/dev/null | wc -l)
echo "zips: $NZ"
[ "$NZ" -eq 60 ] && echo "RAW_QC_OK" || { echo "RAW_QC_INCOMPLETE ($NZ/60)"; exit 1; }
