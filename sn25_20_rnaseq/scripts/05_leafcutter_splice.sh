#!/bin/bash
# 05_leafcutter_splice.sh — annotation-free intron-based differential splicing (LeafCutter)
# Complements rMATS: LeafCutter clusters split reads into intron-excision events de novo,
# good for discovering novel / unannotated splicing shifts between conditions.
#
# Install once:  conda create -y -n leafcutter -c conda-forge -c bioconda leafcutter regtools samtools
# LeafCutter's differential step needs its R package (leafcutter) + the scripts from the repo.
#
#SBATCH --account=ag_iei_abdullah
#SBATCH --partition=intelsr_short
#SBATCH --cpus-per-task=8
#SBATCH --mem=24G
#SBATCH --time=04:00:00
#SBATCH --job-name=sn25_leaf
#SBATCH --output=%x_%j.log
set -euo pipefail
source /opt/software/easybuild-INTEL/software/Miniforge3/24.1.2-0/etc/profile.d/conda.sh
conda activate leafcutter
WS=$(ws_find sn25_20_rnaseq)
BAMDIR=$WS/align_star
OUT=$WS/results/splice_leafcutter; mkdir -p $OUT/juncs
cd $OUT

# 1. Extract junctions from each BAM with regtools (strand 1 = reverse/ISR: use -s 2 for regtools >=1.0)
: > juncfiles.txt
for d in $(tail -n +2 $WS/scripts/samples.tsv | cut -f2); do
  BAM=$BAMDIR/$d/$d.Aligned.sortedByCoord.out.bam
  J=$OUT/juncs/$d.junc
  [ -s "$J" ] || regtools junctions extract -a 8 -m 50 -M 500000 -s RF "$BAM" -o "$J"
  echo "$J" >> juncfiles.txt
done

# 2. Cluster introns (leafcutter_cluster_regtools.py from the LeafCutter repo)
#    python leafcutter_cluster_regtools.py -j juncfiles.txt -m 50 -o sn25 -l 500000
echo "Junctions extracted for all samples -> $OUT/juncs"
echo "NEXT (edit): run leafcutter_cluster_regtools.py then leafcutter_ds.R with a two-group"
echo "  design file (donor as confounder). See github.com/davidaknowles/leafcutter."
echo "  groups come from scripts/samples.tsv (condition column)."
