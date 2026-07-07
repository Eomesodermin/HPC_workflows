# HPC_workflows

General-purpose scaffolding for running jobs on the Marvin HPC cluster (University of Bonn),
reusable across projects (not tied to any single analysis).

## Contents

- [`marvin_hpc_reference.md`](marvin_hpc_reference.md) — full operating manual: access, partitions,
  queues, resource defaults, filesystems, module/conda conventions, and verified account details.
- `templates/` — ready-to-copy SLURM job scripts (CPU, GPU, array jobs). Copy into a project's
  `scripts/hpc_jobs/` and edit the command; don't edit these in place per-project.
- `envs/` — declarative conda/module environment specs shared across projects.
- `scripts/` — shared Python helper functions for job submission / result harvesting.

## Conventions

- **Code here is version-controlled; data is not.** Large files, HPC outputs, and raw/processed
  data never belong in this repo — they go in `~/Documents/HPC_data/<project>/`.
- **Project-specific job scripts** (that call these templates with real parameters) live in each
  project's own repo, e.g. `../Thymic_NK_development/scripts/hpc_jobs/`.
- Every job on Marvin must set `--account=ag_iei_abdullah` (see reference doc §4).
- Harvested compute outputs should be moved from the session workspace into
  `~/Documents/HPC_data/<project>/hpc_runs/<date>_<description>/` and/or saved as
  Claude Science artifacts for provenance.

## Remote

`git remote add origin https://github.com/Eomesodermin/HPC_workflows.git` (create the repo on
GitHub first — see project setup notes).
