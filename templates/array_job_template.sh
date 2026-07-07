#!/bin/bash
# Array job template — Marvin HPC (University of Bonn)
# Use for parameter sweeps / per-sample jobs instead of many individual sbatch submits.
# Marvin's `remote-compute-ssh` connector submit_job() does NOT support --array directly
# (submit one job per task via the SDK); this template is for direct `sbatch` use on the
# login node/CLI, or as the body of a loop that calls submit_job() once per index.

#SBATCH --job-name=CHANGEME
#SBATCH --account=ag_iei_abdullah
#SBATCH --partition=intelsr_short
#SBATCH --time=01:00:00
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=16G
#SBATCH --array=0-99                           # edit range to match your sample/param count
#SBATCH --output=logs/%x-%A_%a.out             # %A=array job id, %a=array task id
#SBATCH --error=logs/%x-%A_%a.err

set -euo pipefail
mkdir -p logs

module purge
module load Miniforge3
source activate CHANGEME_ENV_NAME

# map array index -> input (e.g. one line of a sample sheet per task)
SAMPLESHEET="CHANGEME_samples.txt"
SAMPLE=$(sed -n "$((SLURM_ARRAY_TASK_ID + 1))p" "$SAMPLESHEET")

srun python CHANGEME_SCRIPT.py --sample "$SAMPLE" --output "out/${SLURM_ARRAY_TASK_ID}.result"
