import os
import sys

import pytest

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "scripts"))

import slurm_helpers as sh


def test_script_has_required_directives():
    script = sh.marvin_job_script(partition="intelsr_short", body="echo hi", cpus_per_task=8, mem="32G")
    assert script.startswith("#!/bin/bash")
    for expected in ("--partition=intelsr_short", "--cpus-per-task=8", "--mem=32G", "set -euo pipefail"):
        assert expected in script
    assert "--account" not in script
    assert script.rstrip().endswith("echo hi")


def test_gpu_conda_and_modules_are_emitted_in_order():
    script = sh.marvin_job_script(
        partition="mlgpu_short", body="python run.py", gpus=1, conda_env="boltz", modules=["CUDA/12.6.0"]
    )
    assert "--gpus=1" in script
    order = [script.index(x) for x in ("module purge", "source activate boltz", "module load CUDA/12.6.0")]
    assert order == sorted(order)


def test_explicit_account_is_used():
    assert "--account=my_group" in sh.marvin_job_script(partition="intelsr_short", body="true", account="my_group")


def test_submit_requires_an_account(monkeypatch):
    monkeypatch.delenv("SBATCH_ACCOUNT", raising=False)
    script = sh.marvin_job_script(partition="intelsr_short", body="true")
    with pytest.raises(RuntimeError, match="No SLURM account"):
        sh.submit(script)


def test_dry_run_submits_nothing(monkeypatch):
    monkeypatch.setenv("SBATCH_ACCOUNT", "my_group")
    assert sh.submit(sh.marvin_job_script(partition="intelsr_short", body="true"), dry_run=True) is None
