# Marvin HPC (University of Bonn): usage reference

A working reference for running jobs on the Marvin SLURM cluster, compiled from the
[official wiki](https://wiki.hpc.uni-bonn.de/) and from running bioinformatics and GPU protein-design
workloads there. Facts that change (partitions, module versions, quotas) are marked as such; confirm
them on the cluster with the commands in the last section.

Golden rule: **login nodes orchestrate, compute nodes compute.** Never run analysis on a login node.

Set your SLURM account once per shell (or in `~/.bashrc`) so that no script needs to hard-code it:

```bash
export SBATCH_ACCOUNT=<your_group_account>   # find it with: sacctmgr show assoc user=$USER format=Account
```

SLURM reads `SBATCH_ACCOUNT` as the default for `sbatch --account`, so the templates in this repo
omit the `--account` line.

## 1. Access & connection

- **Login node:** `ssh <user>@marvin.hpc.uni-bonn.de`
- **GPU login node:** `ssh <user>@gpu.marvin.hpc.uni-bonn.de` (internally `login03`; AMD CPUs, no GPU itself). Use it when building/installing GPU software so pip/conda detect the right hardware variant.
- **Reachable only from inside the University of Bonn network or its VPN.** Confirmed: a banner-exchange timeout during connection means wrong network, not a key/firewall problem.
- **SSH key must be uploaded to FreeIPA** (required since 2024-09-25). Password login is not sufficient.
- Home directory is shared across all Marvin nodes (login + compute + GPU login), so one key works everywhere.

## 2. Node types (Marvin is heterogeneous)

Partition names take the form **`<node_type>_<queue_type>`** — e.g. `intelsr_short`, `sgpu_medium`.

| Node type | Purpose | Hardware notes |
|-----------|---------|----------------|
| `intelsr` | Default CPU (MPP) nodes | 96 cores, ~1000 GB RAM per node |
| `lm`      | Large-memory nodes | 1 node/job max |
| `vlm`     | Very-large-memory nodes | 1 node/job max |
| `sgpu`    | Scalable GPU (A100) — large multi-GPU jobs | 32 nodes × 4 A100, 128 cores/node |
| `mlgpu`   | Machine-learning GPU (A40) — ML workloads | 24 nodes × 8 A40 |

## 3. Queue types (time limits)

| Queue | Time limit | Restrictions |
|-------|-----------|--------------|
| `devel`  | 1 hour  | debugging/test runs |
| `short`  | 8 hours | — |
| `medium` | 1 day   | **1 concurrent job/user**; max 128 `intelsr` nodes; max 48 GPUs concurrently per user |
| `long`   | 7 days  | same as medium |

Tip: submit to the **shortest queue the job fits into** — shorter queues have shorter waits.
`sinfo -o "%P %l %c %m %G"` shows live partitions/limits; `scontrol show partitions` for detail.

## 4. Resource defaults (important)

- Ask for cores (`--ntasks` etc.) → get **proportional RAM** (48/96 cores on `intelsr` ⇒ 500/1000 GB).
- Ask for GPUs (`--gpus`) → get **proportional cores** (1/4 A100 ⇒ 32/128 cores ⇒ 1/4 RAM).
- Setting both `--gpus` and `--ntasks` → the **CPU count governs RAM**.
- Override RAM explicitly with `--mem`.
- **`--account` is required on Marvin**: jobs must be tied to your working group's SLURM account (set `SBATCH_ACCOUNT`, see above). Find yours with `sshare -U` or `sacctmgr show assoc user=$USER format=Account,QOS,Partition`.

## 5. Job script template

```bash
#!/bin/bash
#SBATCH --job-name=myjob
#SBATCH --partition=intelsr_short           # <node_type>_<queue_type>
#SBATCH --time=02:00:00                      # give 1.5–2× expected runtime
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=32G                            # or let it derive from cores
#SBATCH --output=logs/%x-%j.out              # %x=jobname %j=jobid

module purge
module load Miniforge3                        # conda init already done
source activate my_env                        # an env you created (see section 8)

srun python myscript.py
```

GPU example:
```bash
#SBATCH --partition=mlgpu_short   # A40 ML queue  (or sgpu_* for A100)
#SBATCH --gpus=1
#SBATCH --time=04:00:00
module load CUDA                  # plus whatever your framework needs
```

## 6. Submitting, monitoring, cancelling

| Action | Command |
|--------|---------|
| Submit | `sbatch script.sh` (CLI flags override `#SBATCH` lines) |
| My queue | `squeue --me` |
| Live job detail | `scontrol show job <id>` |
| Past-job accounting | `sacct -j <id> --format=JobID,State,Elapsed,MaxRSS,ReqMem,AllocCPUS` |
| Efficiency check | `seff <id>` |
| Cancel | `scancel <id>` (or `scancel --me`) |
| **Interactive session** | `srun --pty <slurm opts> /bin/bash` — for interactive/CPU-heavy debug work. **Do not** do this on the login node. |
| Array job (sweeps) | `#SBATCH --array=0-99` instead of many separate submits |

Output defaults to `slurm-<id>.out` in the submit directory; change with `--output`.

## 7. Filesystems — where data goes

| Location | Quota / lifetime | Use for |
|----------|------------------|---------|
| **Home** (`/home/<user>`) | 100 GB, persistent, shared all nodes | your code, job scripts, conda envs |
| **Workspace** (Lustre `/lustre/scratch/...`) | no size limit; **90 days, extend ×3 → 360 days**, then 21-day grace before deletion | bulk input/output/intermediate data for jobs |
| **Workspace SSD** (`-F mlnvme`, `/lustre/mlnvme/...`) | 307 TB SSD pool | high file-I/O jobs |
| **Node-local** (`/tmp`) | 2 TB SSD/node, **wiped at job end**, per-node | scratch for very high I/O within one job |

Workspace commands:
```bash
ws_allocate <name> 90                          # create (defaults to 1 DAY if you omit duration!)
ws_allocate -F mlnvme <name> 90                # on the SSD pool
ws_allocate -r 7 -m <user>@uni-bonn.de <name> 90   # email reminder 7 days before expiry (uni-bonn address only)
ws_list ; ws_extend <name> 90 ; ws_release <name>
```
Copy final results OFF the cluster before a workspace expires — Marvin is **not** long-term storage.
Check Lustre usage/quota: `lfs quota -h -v -u <user> /lustre/`

## 8. Software & environments

- **Module system: Lmod + EasyBuild.** Central software in `/software` and `/opt/software`.
  - `module avail` — list installed software
  - `module spider <name>` — search / detailed info
  - `module load <mod>` / `module purge` / `module list` / `module help`
- **Conda:** `module load Miniforge3`, then `conda init` **once** (edits `.bashrc`; don't put `conda init` in job scripts).
  - Anaconda/Miniconda and the default Anaconda channels are **disallowed** (licensing) — use **Miniforge + conda-forge**.
  - Cannot install into `base` — always create your own env.
  - Envs live in home → watch the 100 GB quota; run `conda clean --all` periodically.
  - For GPU package variants, run `conda install` inside a GPU interactive job or on the GPU login node so the right build is detected.
- **Containers:** Apptainer/Singularity available (e.g. AlphaFold3 provided as a module: `module load AlphaFold3/3.0.1-apptainer`).

## 9. Lustre etiquette (shared 5 PB filesystem)

- **Avoid creating huge numbers of tiny files** — small files use Data-on-MDT; millions of them fill the metadata targets and degrade the FS for everyone. Tar/pack many small outputs.
- Stage high-I/O work to node-local `/tmp` or the `mlnvme` pool, write condensed results back to scratch.

## 10. Checking the live system

The partition matrix, installed modules and quotas change over time. Re-probe rather than trusting
this document:

```bash
sinfo -o "%P %l %c %m %G"          # partitions, time limits, cores, memory, GPUs
module spider <tool>               # exact module versions (AlphaFold, Boltz, CUDA, BLAST, ...)
sshare -U                          # fair-share standing for your account
du -sh ~ ; lfs quota -h -u $USER /lustre/
```

At the time of writing, central modules include AlphaFold 2/3 (Apptainer and CUDA builds),
AlphaPulldown, Boltz, Amber, BCFtools, BBMap and Biopython, with CUDA 11.4 to 12.8.

Support: marvin-support@hpc.uni-bonn.de
