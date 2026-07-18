#!/bin/bash
#SBATCH --account=ag_iei_abdullah
#SBATCH --partition=intelsr_short
#SBATCH --cpus-per-task=16
#SBATCH --mem=32G
#SBATCH --time=03:00:00
#SBATCH --job-name=sn25_fc
#SBATCH --output=%x_%j.log
set -euo pipefail
source /opt/software/easybuild-INTEL/software/Miniforge3/24.1.2-0/etc/profile.d/conda.sh
conda activate rnaseq_quant
WS=$(ws_find sn25_20_rnaseq)
GTF=$WS/reference/Mus_musculus.GRCm39.116.gtf.gz
BAMDIR=$WS/align_star
OUT=$WS/counts; mkdir -p $OUT
# BAMs in samples.tsv order (stable columns)
BAMS=""
for deid in $(tail -n +2 $WS/scripts/samples.tsv | cut -f2); do
  BAMS+="$BAMDIR/$deid/$deid.Aligned.sortedByCoord.out.bam "
done
NBAM=$(echo $BAMS | wc -w); echo "bams: $NBAM"
# reverse-stranded (-s 2), paired (-p --countReadPairs)
featureCounts -T 16 -p --countReadPairs -s 2 \
  -a $GTF -F GTF -t exon -g gene_id \
  -o $OUT/featurecounts.txt $BAMS
# clean sample_id header: replace full bam paths with deids
head -2 $OUT/featurecounts.txt | tail -1 | tr '\t' '\n' | grep -c Aligned | xargs echo 'bam cols in header:'
echo "FEATURECOUNTS_OK"
multiqc -f -o $WS/qc/multiqc -n multiqc_featurecounts $OUT
