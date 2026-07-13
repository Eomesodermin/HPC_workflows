#!/bin/bash
#SBATCH --job-name=ddl_pp_all
#SBATCH --account=ag_iei_abdullah
#SBATCH --partition=intelsr_medium
#SBATCH --nodes=1 --ntasks=1 --cpus-per-task=16 --mem=48G --time=06:00:00
#SBATCH --output=%x_%j.log
set -euo pipefail
WS=/lustre/scratch/data/dcorvino_hpc-thymic_nk_development
SIF=$HOME/software/sc-dandelion_latest.sif
PP=$WS/processed/dandelion_reproduction/preprocess
mkdir -p $PP; cd $PP
STAGED=0
for D in $WS/work/suovdj_*/outs; do
  LANE=$(basename $(dirname $D) | sed 's/^suovdj_//')
  [ "$LANE" = "smoke" ] && continue
  [ -s $D/all_contig_annotations.csv ] || continue
  [ -s $PP/$LANE/dandelion/all_contig_dandelion.tsv ] && continue
  mkdir -p $PP/$LANE
  cp -f $D/all_contig_annotations.csv $PP/$LANE/all_contig_annotations.csv
  cp -f $D/all_contig.fasta            $PP/$LANE/all_contig.fasta
  STAGED=$((STAGED+1))
done
echo "newly staged: $STAGED"
ls -d $PP/*/ 2>/dev/null | wc -l | xargs echo "total library folders:"
START=$SECONDS
apptainer run -B $PP:$PP --pwd $PP $SIF \
  dandelion-preprocess --chain TR --org human --file_prefix all --keep_trailing_hyphen_number 2>&1 | tail -30
echo "=== PREPROCESS DONE ELAPSED $((SECONDS-START))s ==="
mkdir -p $WS/processed/dandelion_reproduction/dandelion_tsv
for T in $PP/*/dandelion/all_contig_dandelion.tsv; do
  L=$(echo "$T" | sed -E "s#.*/([^/]+)/dandelion/.*#\1#")
  cp -f "$T" $WS/processed/dandelion_reproduction/dandelion_tsv/${L}_all_contig_dandelion.tsv
done
ls $WS/processed/dandelion_reproduction/dandelion_tsv/ | wc -l | xargs echo "AIRR tsvs collected:"
