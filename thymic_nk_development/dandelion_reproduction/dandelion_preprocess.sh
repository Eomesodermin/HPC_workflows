#!/bin/bash
#SBATCH --job-name=ddl_preprocess
#SBATCH --account=ag_iei_abdullah
#SBATCH --partition=intelsr_medium
#SBATCH --nodes=1 --ntasks=1 --cpus-per-task=16 --mem=48G --time=08:00:00
#SBATCH --output=%x_%j.log
# sc-dandelion IgBLAST reannotation of the Suo abTCR cellranger outputs.
# Runs the container's dandelion-preprocess over ALL library folders at once
# (cross-sample allele reassignment). --file_prefix all keeps NON-productive contigs
# (the whole point: aborted/partial TCR relics). --chain TR, human.
# Does NOT pass --filter_to_high_confidence (would drop the non-productive relics).
set -euo pipefail
WS=/lustre/scratch/data/dcorvino_hpc-thymic_nk_development
SIF=$HOME/software/sc-dandelion_latest.sif
PP=$WS/processed/dandelion_reproduction
mkdir -p $PP
cd $PP

# Stage each cellranger library's all_contig files into its own folder named by lane,
# as the container expects: <lane>/all_contig_annotations.csv + <lane>/all_contig.fasta
for D in $WS/work/suovdj_*/outs; do
  LANE=$(basename $(dirname $D) | sed 's/^suovdj_//')
  [ "$LANE" = "smoke" ] && continue
  mkdir -p $PP/$LANE
  # symlink (container reads them); prefer copy for portability
  cp -f $D/all_contig_annotations.csv $PP/$LANE/all_contig_annotations.csv
  cp -f $D/all_contig.fasta            $PP/$LANE/all_contig.fasta
done
ls -d $PP/*/ | wc -l | xargs echo "staged library folders:"

# Build the meta list of sample folders for the container
ls -d $PP/*/ | xargs -n1 basename > $PP/sample_list.txt
wc -l $PP/sample_list.txt

# Run dandelion-preprocess. It walks the sample folders in CWD.
apptainer run -B $PP:$PP --pwd $PP $SIF \
  dandelion-preprocess \
    --chain TR \
    --org human \
    --file_prefix all \
    --keep_trailing_hyphen_number

echo "=== dandelion-preprocess DONE ==="
# collect the per-lib AIRR tsvs
mkdir -p $PP/dandelion_tsv
find $PP -path '*/dandelion/all_contig_dandelion.tsv' -exec sh -c '
  L=$(echo "$1" | sed -E "s#.*/([^/]+)/dandelion/.*#\1#"); cp "$1" '"$PP"'/dandelion_tsv/${L}_all_contig_dandelion.tsv' _ {} \;
ls $PP/dandelion_tsv/ | wc -l | xargs echo "AIRR tsvs collected:"
