"""
Shared helpers for submitting jobs to Marvin HPC and harvesting results.

These are written for the `repl` tool control-plane kernel (host.compute.*),
NOT the python/r analysis kernels — host.compute is only attached there.
See ../marvin_hpc_reference.md for the full account/partition/queue reference.

Usage (in a `repl` cell):
    from pathlib import Path
    import sys
    sys.path.insert(0, "<path to this HPC_workflows/scripts dir>")
    from submit_helpers import marvin_job_script, DEFAULT_ACCOUNT

    c = host.compute.create("ssh:marvin")
    job = c.submit_job(
        intent="my analysis on Marvin",
        command=marvin_job_script(
            partition="mlgpu_short", gpus=1, time="04:00:00", mem="64G",
            conda_env="tcrbert",
            body="python myscript.py --input ./in.dat --output ./out",
        ),
        inputs=[{"src": "in.dat", "dst_filename": "in.dat"}],
        outputs=["*.result"],
    )
"""

DEFAULT_ACCOUNT = "ag_iei_abdullah"


def marvin_job_script(
    *,
    partition: str,
    body: str,
    time: str = "01:00:00",
    account: str = DEFAULT_ACCOUNT,
    ntasks: int = 1,
    cpus_per_task: int | None = None,
    mem: str | None = None,
    gpus: int | None = None,
    conda_env: str | None = None,
    modules: list[str] | None = None,
) -> str:
    """Build a Marvin SLURM job script string for host.compute submit_job(command=...).

    Directives are hoisted by the connector; write them as you would for `sbatch`.
    `body` is the actual workload — one or more shell lines run after env setup.
    """
    lines = [
        f"#SBATCH --account={account}",
        f"#SBATCH --partition={partition}",
        f"#SBATCH --time={time}",
        f"#SBATCH --ntasks={ntasks}",
    ]
    if cpus_per_task:
        lines.append(f"#SBATCH --cpus-per-task={cpus_per_task}")
    if mem:
        lines.append(f"#SBATCH --mem={mem}")
    if gpus:
        lines.append(f"#SBATCH --gpus={gpus}")

    lines.append("")
    lines.append("module purge")
    if conda_env:
        lines.append("module load Miniforge3")
        lines.append(f"source activate {conda_env}")
    for m in modules or []:
        lines.append(f"module load {m}")

    lines.append("")
    lines.append(body)

    return "\n".join(lines)


def project_hpc_run_dir(project: str, description: str, base: str = "~/Documents/HPC_data") -> str:
    """Return the conventional local path for harvested outputs of a given run.

    e.g. project_hpc_run_dir("Thymic_NK_development", "boltz_screen")
      -> ~/Documents/HPC_data/Thymic_NK_development/hpc_runs/<YYYY-MM-DD>_boltz_screen
    """
    import datetime
    import os

    date = datetime.date.today().isoformat()
    return os.path.expanduser(f"{base}/{project}/hpc_runs/{date}_{description}")
