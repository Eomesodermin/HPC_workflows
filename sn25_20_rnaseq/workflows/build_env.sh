#!/bin/bash
#SBATCH --account=ag_iei_abdullah
#SBATCH --partition=intelsr_short
#SBATCH --cpus-per-task=8
#SBATCH --mem=32G
#SBATCH --time=02:00:00
#SBATCH --job-name=sn25_env
#SBATCH --output=%x_%j.log
set -euo pipefail
source /opt/software/easybuild-INTEL/software/Miniforge3/24.1.2-0/etc/profile.d/conda.sh
ENV=rnaseq_quant
conda env list | grep -q "/$ENV\$" && { echo "env $ENV exists"; } || \
conda create -y -n $ENV -c conda-forge -c bioconda \
  salmon=1.10.3 subread=2.0.6 fastp=0.23.4 multiqc=1.25 \
  rseqc=5.0.3 gffread=0.12.7 samtools=1.21 pigz
echo "=== smoke tests ==="
conda run -n $ENV salmon --version
conda run -n $ENV featureCounts -v 2>&1 | head -1
conda run -n $ENV fastp --version 2>&1
conda run -n $ENV multiqc --version
conda run -n $ENV gffread --version
conda run -n $ENV infer_experiment.py --version 2>&1 | head -1
echo "ENV_BUILD_OK"
