# HPC workflows

[![CI](https://github.com/Eomesodermin/HPC_workflows/actions/workflows/ci.yml/badge.svg)](https://github.com/Eomesodermin/HPC_workflows/actions/workflows/ci.yml)
[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.23950808.svg)](https://doi.org/10.5281/zenodo.23950808)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

Reusable scaffolding for running bioinformatics and GPU protein-design jobs on a SLURM cluster,
written for the Marvin cluster at the University of Bonn but easy to adapt. It holds the pieces
every project on the cluster needs and that are easy to get wrong: job templates, an operating
reference, environment specs and a small tested job-script builder.

This repository contains no project code or data. Projects that use these conventions:
[`nkg7-binder-design`](https://github.com/Eomesodermin/nkg7-binder-design) (GPU design campaign
rendered as a SLURM DAG), [`nkg7-structural-analysis`](https://github.com/Eomesodermin/nkg7-structural-analysis)
and [`Thymic_NK_development`](https://github.com/Eomesodermin/Thymic_NK_development) (CPU alignment of
10x V(D)J libraries).

## Contents

| Path | What it is |
|------|------------|
| [`docs/marvin_reference.md`](docs/marvin_reference.md) | Operating manual: access, partitions and queues, resource defaults, filesystems and workspaces, modules and conda, Lustre etiquette |
| [`templates/`](templates) | Copy-and-edit `sbatch` scripts for CPU, GPU and array jobs |
| [`scripts/slurm_helpers.py`](scripts/slurm_helpers.py) | Build a job script from keyword arguments and submit it; tested in [`tests/`](tests) |
| [`envs/`](envs) | Declarative conda environment specs shared across projects |

## Quick start

```bash
export SBATCH_ACCOUNT=<your_group_account>      # SLURM reads this; no script hard-codes an account
cp templates/gpu_job_template.sh my_project/scripts/hpc_jobs/predict.sh
# edit the CHANGEME fields, then
sbatch my_project/scripts/hpc_jobs/predict.sh input.fasta out/
```

Or generate the script programmatically, for example to sweep a parameter:

```python
from slurm_helpers import marvin_job_script, submit

script = marvin_job_script(
    partition="mlgpu_short", gpus=1, time="04:00:00", mem="64G",
    conda_env="boltz", body="python predict.py --input in.fasta --out out/",
)
job_id = submit(script)
```

## Conventions

- **Code is version-controlled, data is not.** Large inputs, run outputs and trajectories live in
  a cluster workspace (`ws_allocate`) or a local data directory, never in a repository.
- **The account is configuration, not code.** Set `SBATCH_ACCOUNT` once per shell.
- **Right-size every job.** Use the shortest queue that fits, request memory explicitly, and
  check efficiency afterwards with `seff <jobid>`.
- **Pack small files.** Millions of tiny outputs degrade the shared Lustre filesystem; tar them.

## Development

```bash
pip install pytest ruff
ruff check scripts tests && pytest
```

Released under the [MIT License](LICENSE).
