#!/bin/bash
#SBATCH --job-name=suovdjfix
#SBATCH --account=ag_iei_abdullah
#SBATCH --partition=intelsr_medium
#SBATCH --nodes=1 --ntasks=1 --cpus-per-task=16 --mem=48G --time=06:00:00
#SBATCH --output=%x_%j.log
set -euo pipefail
export PATH=$HOME/software/cellranger-9.0.1:$PATH
WS=/lustre/scratch/data/dcorvino_hpc-thymic_nk_development
REF=$HOME/software/refdata-cellranger-vdj-GRCh38-alts-ensembl-7.1.0
LANE=$1; RUN=$2; URL1=$3; URL2=$4
FQDIR=$WS/raw/E-MTAB-11388_vdj/$RUN
mkdir -p $FQDIR; cd $FQDIR
dl_verified () {
  local URL="$1"; local FN=$(basename "$URL")
  local EXP=$(curl -sI "$URL" | grep -i '^content-length' | tr -d '\r' | awk '{print $2}')
  for attempt in 1 2 3 4 5; do
    local DISK=$(stat -c%s "$FN" 2>/dev/null || echo 0)
    if [ -n "$EXP" ] && [ "$DISK" = "$EXP" ]; then echo "  $FN complete ($DISK)"; return 0; fi
    echo "  $FN attempt $attempt: disk=$DISK exp=$EXP -> resume"
    curl -s -L -C - --retry 8 --retry-delay 20 --retry-connrefused -f -o "$FN" "$URL" || true
  done
  local DISK=$(stat -c%s "$FN" 2>/dev/null || echo 0)
  [ "$DISK" = "$EXP" ] || { echo "FAILED to complete $FN ($DISK/$EXP)"; return 1; }
}
dl_verified "$URL1"
dl_verified "$URL2"
cd $WS/work
OUT=suovdj_$LANE
if [ -s $OUT/outs/all_contig_annotations.csv ]; then echo "ALREADY DONE $OUT"; exit 0; fi
rm -rf $OUT
START=$SECONDS
cellranger vdj --id=$OUT --reference=$REF --fastqs=$FQDIR --sample=$LANE \
  --chain TR --localcores=16 --localmem=44
echo "=== DONE $LANE EXIT $? ELAPSED $((SECONDS-START))s ==="
wc -l $OUT/outs/all_contig_annotations.csv
