#!/bin/bash
#SBATCH --account=ag_iei_abdullah
#SBATCH --partition=intelsr_short
#SBATCH --cpus-per-task=16
#SBATCH --mem=64G
#SBATCH --time=03:00:00
#SBATCH --job-name=sn25_staridx
#SBATCH --output=%x_%j.log
set -euo pipefail
module load STAR/2.7.11b-GCC-12.3.0
WS=$(ws_find sn25_20_rnaseq); REF=$WS/reference
cd $REF
# decompress genome + GTF for STAR (needs uncompressed)
[ -f genome.fa ]  || zcat Mus_musculus.GRCm39.dna.primary_assembly.fa.gz > genome.fa
[ -f genes.gtf ]  || zcat Mus_musculus.GRCm39.116.gtf.gz > genes.gtf
mkdir -p $WS/star_index
START=$SECONDS
STAR --runMode genomeGenerate \
     --genomeDir $WS/star_index \
     --genomeFastaFiles $REF/genome.fa \
     --sjdbGTFfile $REF/genes.gtf \
     --sjdbOverhang 100 \
     --runThreadN 16
echo "STAR index built in $((SECONDS-START))s"
ls -lh $WS/star_index | head
echo STAR_INDEX_OK
