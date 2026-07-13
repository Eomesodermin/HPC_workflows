#!/bin/bash
#SBATCH --job-name=crvdj_smoke
#SBATCH --account=ag_iei_abdullah
#SBATCH --partition=intelsr_short
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16
#SBATCH --mem=64G
#SBATCH --time=04:00:00
#SBATCH --output=%x_%j.log
set -euo pipefail
export PATH=$HOME/software/cellranger-9.0.1:$PATH
WS=/lustre/scratch/data/dcorvino_hpc-thymic_nk_development
REF=$HOME/software/refdata-cellranger-vdj-GRCh38-alts-ensembl-7.1.0
cd $WS/work
rm -rf smoke_TCR_Pan_T7935501
START=$SECONDS
cellranger vdj \
  --id=smoke_TCR_Pan_T7935501 \
  --reference=$REF \
  --fastqs=$WS/raw/E-MTAB-11536_vdj/ERR9249341 \
  --sample=TCR_Pan_T7935501 \
  --localcores=16 --localmem=60
echo "=== CELLRANGER EXIT $? ; ELAPSED $((SECONDS-START))s ==="
echo "=== all_contig_annotations ==="
head -1 smoke_TCR_Pan_T7935501/outs/all_contig_annotations.csv
echo "rows: $(wc -l < smoke_TCR_Pan_T7935501/outs/all_contig_annotations.csv)"
echo "=== metrics ==="
cat smoke_TCR_Pan_T7935501/outs/metrics_summary.csv 2>/dev/null | head -5
