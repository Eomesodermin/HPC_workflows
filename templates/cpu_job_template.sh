#!/bin/bash
# CPU job template — Marvin HPC (University of Bonn)
# Copy into <project>/scripts/hpc_jobs/, rename, and edit the marked sections.
# See ../docs/marvin_reference.md for partition/queue/resource docs.
# Account: export SBATCH_ACCOUNT=<your_group_account> once per shell (see docs/marvin_reference.md).

#SBATCH --job-name=CHANGEME
#SBATCH --partition=intelsr_short              # devel/short/medium/long — pick the shortest that fits
#SBATCH --time=02:00:00                        # give 1.5-2x expected runtime
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=32G                              # set explicitly; don't rely on the core-proportional default
#SBATCH --output=logs/%x-%j.out
#SBATCH --error=logs/%x-%j.err

set -euo pipefail
mkdir -p logs

# --- environment ---
module purge
module load Miniforge3
source activate CHANGEME_ENV_NAME

# --- workload ---
srun python CHANGEME_SCRIPT.py \
    --input  "$1" \
    --output "$2"
