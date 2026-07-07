# Marvin HPC (University of Bonn) — Usage Reference

Source: https://wiki.hpc.uni-bonn.de/ (Marvin cluster). Scheduler: **SLURM**.
This doc is the operating manual for submitting jobs to Marvin from Claude Science.
Golden rule: **login nodes orchestrate, compute nodes compute. Never run analysis on a login node.**

**Verified account (2026-07-07):** user `dcorvino_hpc`, SLURM account **`ag_iei_abdullah`** — use `--account=ag_iei_abdullah`. Existing conda envs: `nextflow`, `tcrbert`. Home 20/100 GB used.

**Local layout (this machine):**
- General-purpose HPC scaffolding (this doc, job templates, env specs): `~/Documents/Github/Eomesodermin/HPC_workflows/`
- Project code (git-tracked): `~/Documents/Github/Eomesodermin/<project>/` (e.g. `Thymic_NK_development/`)
- Project data + harvested HPC outputs (NOT git-tracked): `~/Documents/HPC_data/<project>/{raw,processed,hpc_runs}/`
- **Convention:** after a compute job's `compute_done` notification, harvested files should be moved from the ephemeral workspace `hpc/<job_id>/` into `~/Documents/HPC_data/<project>/hpc_runs/<date>_<job_description>/` before being discarded from the session workspace, and/or saved as artifacts via `save_artifacts` for provenance.

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
- **`--account` is REQUIRED on Marvin** — jobs must be tied to your working group's SLURM account. Find yours with `sshare -U` or `sacctmgr show assoc user=$USER format=Account,QOS,Partition`.

## 5. Job script template

```bash
#!/bin/bash
#SBATCH --job-name=myjob
#SBATCH --account=ag_iei_abdullah           # REQUIRED on Marvin (this account)
#SBATCH --partition=intelsr_short           # <node_type>_<queue_type>
#SBATCH --time=02:00:00                      # give 1.5–2× expected runtime
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=32G                            # or let it derive from cores
#SBATCH --output=logs/%x-%j.out              # %x=jobname %j=jobid

module purge
module load Miniforge3                        # conda init already done
source activate tcrbert                       # your existing envs: nextflow, tcrbert

srun python myscript.py
```

GPU example:
```bash
#SBATCH --partition=mlgpu_short   # A40 ML queue  (or sgpu_* for A100)
#SBATCH --gpus=1
#SBATCH --time=04:00:00
#SBATCH --account=ag_iei_abdullah
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

## 10. How Claude Science submits here (the mechanics)

1. Marvin is registered as an SSH host (`ssh:marvin`) in the Compute panel (user + FreeIPA key).
2. **Reachability:** Marvin only accepts connections from inside the uni-bonn network/VPN. Confirmed working when connecting from on-campus/VPN.
3. Flow: stage inputs → `sbatch` a job script (this doc's template) → the poller harvests outputs back and notifies on completion. Nothing runs on the login node.
4. Always set `--account`, a right-sized partition, and a sane `--time`.

## 10b. scratch_root (Compute panel config)

The `ssh:marvin` provider's **scratch_root** is set (via the Compute panel host-settings UI — NOT via this doc; compute_details is documentation, not the resolution mechanism) to the general-purpose workspace:
`/lustre/scratch/data/dcorvino_hpc-claude_science`

For project-specific bulk data, allocate a dedicated workspace, e.g.:
```bash
ws_allocate -r 7 -m dcorvino@uni-bonn.de thymic_nk_development 90
```
and reference its path explicitly in job scripts / `inputs`/`outputs` rather than changing the global scratch_root.

## 11. Live-system state (verified 2026-07-07)

- **Account:** `ag_iei_abdullah` (only account; fairshare ~0.56). Confirmed via `sshare -U`.
- **Partitions:** full `intelsr / mlgpu / sgpu / lm / vlm` × `devel/short/medium/long` matrix + `jupyter_default`.
- **Software already installed** (module avail): AlphaFold2 (ColabFold), AlphaFold3 (apptainer + CUDA builds), AlphaPulldown, Amber, Boltz-1, BCFtools, BBMap, Biopython, CUDA 11.4–12.8, and much more. Use `module spider <tool>` for exact version strings.
- **Conda:** `module load Miniforge3` (v24.1.2), `conda init` already done. User envs: `nextflow`, `tcrbert` in `~/.conda/envs/`.
- **Storage:** home 20/100 GB. Lustre 159.5 GB / 9.7k files, no quota limit. General-purpose workspace `dcorvino_hpc-claude_science` active (scratch_root).

Re-probe anytime with: `sinfo -o "%P %l %c %m %G"`, `module spider <tool>`, `du -sh ~`, `lfs quota -h -u $USER /lustre/`.

Support: marvin-support@hpc.uni-bonn.de
