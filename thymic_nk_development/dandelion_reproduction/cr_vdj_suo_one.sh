#!/bin/bash
#SBATCH --job-name=suovdj
#SBATCH --account=ag_iei_abdullah
#SBATCH --partition=intelsr_medium
#SBATCH --nodes=1 --ntasks=1 --cpus-per-task=16 --mem=48G --time=04:00:00
#SBATCH --output=%x_%j.log
set -euo pipefail
export PATH=$HOME/software/cellranger-9.0.1:$PATH
WS=/lustre/scratch/data/dcorvino_hpc-thymic_nk_development
REF=$HOME/software/refdata-cellranger-vdj-GRCh38-alts-ensembl-7.1.0
LANE=$1; RUN=$2; URL1=$3; URL2=$4
FQDIR=$WS/raw/E-MTAB-11388_vdj/$RUN
mkdir -p $FQDIR; cd $FQDIR
for U in "$URL1" "$URL2"; do
  FN=$(basename "$U")
  if [ ! -s "$FN" ]; then curl -s -L --retry 8 --retry-delay 15 --retry-connrefused -f -O "$U"; fi
done
cd $WS/work
OUT=suovdj_$LANE
if [ -s $OUT/outs/all_contig_annotations.csv ]; then echo "ALREADY DONE $OUT"; exit 0; fi
rm -rf $OUT
START=$SECONDS
cellranger vdj --id=$OUT --reference=$REF --fastqs=$FQDIR --sample=$LANE \
  --chain TR --localcores=16 --localmem=44
echo "=== DONE $LANE EXIT $? ELAPSED $((SECONDS-START))s ==="
wc -l $OUT/outs/all_contig_annotations.csv
