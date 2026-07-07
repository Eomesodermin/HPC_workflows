#!/bin/bash
# GPU job template — Marvin HPC (University of Bonn)
# Node types: mlgpu = A40 (ML workloads), sgpu = A100 (large multi-GPU jobs)
# Copy into <project>/scripts/hpc_jobs/, rename, and edit the marked sections.

#SBATCH --job-name=CHANGEME
#SBATCH --account=ag_iei_abdullah
#SBATCH --partition=mlgpu_short                # or sgpu_short / *_devel / *_medium / *_long
#SBATCH --time=04:00:00
#SBATCH --gpus=1
#SBATCH --ntasks=1
#SBATCH --mem=64G                              # GPUs auto-scale cores/RAM proportionally; set explicitly to be safe
#SBATCH --output=logs/%x-%j.out
#SBATCH --error=logs/%x-%j.err

set -euo pipefail
mkdir -p logs

# --- environment ---
module purge
module load Miniforge3
source activate CHANGEME_ENV_NAME
# module load CUDA/12.6.0                      # if the tool needs an explicit CUDA module

# sanity check: confirm the job actually sees a GPU before running anything expensive
nvidia-smi -L

# --- workload ---
srun python CHANGEME_SCRIPT.py \
    --input  "$1" \
    --output "$2"
