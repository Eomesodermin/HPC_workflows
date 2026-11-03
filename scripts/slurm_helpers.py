"""Build and submit SLURM job scripts for the Marvin cluster.

Small, dependency-free helpers for generating an ``sbatch`` script from keyword arguments so that
sweeps and pipelines do not hand-edit shell templates. The account is never hard-coded: it is taken
from ``SBATCH_ACCOUNT`` (which SLURM reads itself) unless passed explicitly.

Example:
    from slurm_helpers import marvin_job_script, submit

    script = marvin_job_script(
        partition="mlgpu_short", gpus=1, time="04:00:00", mem="64G",
        conda_env="boltz", body="python predict.py --input in.fasta --out out/",
    )
    job_id = submit(script)        # runs `sbatch` and returns the job id
"""
from __future__ import annotations

import os
import re
import subprocess


def marvin_job_script(
    *,
    partition: str,
    body: str,
    time: str = "01:00:00",
    job_name: str = "job",
    account: str | None = None,
    ntasks: int = 1,
    cpus_per_task: int | None = None,
    mem: str | None = None,
    gpus: int | None = None,
    conda_env: str | None = None,
    modules: list[str] | None = None,
    log_dir: str = "logs",
) -> str:
    """Return the text of a SLURM job script.

    ``partition`` follows Marvin's ``<node_type>_<queue_type>`` naming, e.g. ``intelsr_short`` or
    ``mlgpu_medium``. ``body`` is one or more shell lines run after the environment is set up.
    """
    lines = [
        "#!/bin/bash",
        f"#SBATCH --job-name={job_name}",
        f"#SBATCH --partition={partition}",
        f"#SBATCH --time={time}",
        f"#SBATCH --ntasks={ntasks}",
        f"#SBATCH --output={log_dir}/%x-%j.out",
        f"#SBATCH --error={log_dir}/%x-%j.err",
    ]
    if account:
        lines.append(f"#SBATCH --account={account}")
    if cpus_per_task:
        lines.append(f"#SBATCH --cpus-per-task={cpus_per_task}")
    if mem:
        lines.append(f"#SBATCH --mem={mem}")
    if gpus:
        lines.append(f"#SBATCH --gpus={gpus}")
    lines += ["", "set -euo pipefail", f"mkdir -p {log_dir}", "", "module purge"]
    if conda_env:
        lines += ["module load Miniforge3", f"source activate {conda_env}"]
    lines += [f"module load {m}" for m in modules or []]
    lines += ["", body]
    return "\n".join(lines) + "\n"


def submit(script: str, *, dry_run: bool = False) -> str | None:
    """Submit ``script`` with ``sbatch`` and return the job id.

    Fails fast if no account is configured, because Marvin rejects jobs without one. With
    ``dry_run=True`` nothing is submitted and ``None`` is returned.
    """
    if "--account=" not in script and not os.environ.get("SBATCH_ACCOUNT"):
        raise RuntimeError("No SLURM account: set SBATCH_ACCOUNT or pass account= to marvin_job_script")
    if dry_run:
        return None
    result = subprocess.run(["sbatch", "--parsable"], input=script, text=True, capture_output=True, check=True)
    match = re.match(r"(\d+)", result.stdout.strip())
    if not match:
        raise RuntimeError(f"unexpected sbatch output: {result.stdout!r}")
    return match.group(1)
