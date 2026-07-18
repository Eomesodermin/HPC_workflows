#!/bin/bash
#SBATCH --account=ag_iei_abdullah
#SBATCH --partition=intelsr_short
#SBATCH --cpus-per-task=16
#SBATCH --mem=32G
#SBATCH --time=03:00:00
#SBATCH --job-name=sn25_salmonidx
#SBATCH --output=%x_%j.log
set -euo pipefail
source /opt/software/easybuild-INTEL/software/Miniforge3/24.1.2-0/etc/profile.d/conda.sh
conda activate rnaseq_quant
WS=$(ws_find sn25_20_rnaseq); REF=$WS/reference
cd $REF
# transcriptome = cDNA + ncRNA ; decoys = genome contig names (gentrome approach)
[ -f gentrome.fa.gz ] || cat Mus_musculus.GRCm39.cdna.all.fa.gz Mus_musculus.GRCm39.ncrna.fa.gz \
     Mus_musculus.GRCm39.dna.primary_assembly.fa.gz > gentrome.fa.gz
[ -f decoys.txt ] || { grep '^>' <(zcat Mus_musculus.GRCm39.dna.primary_assembly.fa.gz) | sed 's/^>//; s/ .*//' > decoys.txt; }
echo "n decoys: $(wc -l < decoys.txt)"
START=$SECONDS
salmon index -t gentrome.fa.gz -d decoys.txt -i $WS/salmon_index \
     -k 31 -p 16 --gencode 2>/dev/null || \
salmon index -t gentrome.fa.gz -d decoys.txt -i $WS/salmon_index -k 31 -p 16
echo "Salmon index built in $((SECONDS-START))s"
ls -lh $WS/salmon_index | head
echo SALMON_INDEX_OK
