#!/bin/bash
# CPU job template — Marvin HPC (University of Bonn)
# Copy into <project>/scripts/hpc_jobs/, rename, and edit the marked sections.
# See ../../marvin_hpc_reference.md for full partition/queue/resource docs.

#SBATCH --job-name=CHANGEME
#SBATCH --account=ag_iei_abdullah              # required on Marvin
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
source activate CHANGEME_ENV_NAME              # e.g. tcrbert, nextflow

# --- workload ---
srun python CHANGEME_SCRIPT.py \
    --input  "$1" \
    --output "$2"
