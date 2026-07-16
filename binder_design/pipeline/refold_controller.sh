#!/bin/bash
# =====================================================================
# refold_controller.sh — FOLDING-ONLY rerun after the MPNN SIGPIPE bug.
#
# RFdiffusion output (~9.75-10k backbones/conformer, 9 conformers) is INTACT
# and reused as-is. This controller reruns only MPNN -> Boltz per conformer
# chain, then the per-arm consensus (refold -> chai -> cross) + email.
# The MPNN scripts are the SIGPIPE-fixed versions (glob-array, no `ls|head`).
#
# Runs AS A SLURM BATCH JOB on intelsr_long (reap-immune compute node).
# Chain = mpnn(20 shards) + boltz(25 shards) = 45 tasks. 9 chains = 405 > 300
# cap, so throttle with a full-chain (45-task) headroom guard.
# =====================================================================
#SBATCH --account=ag_iei_abdullah
#SBATCH --partition=intelsr_long
#SBATCH --time=3-00:00:00
#SBATCH --ntasks=1 --cpus-per-task=1 --mem=2G
#SBATCH --job-name=nkg7_refold
set -uo pipefail

WS=/lustre/scratch/data/dcorvino_hpc-nkg7_binder_design
REND=$WS/pipeline/rendered_prod
MAXC="${MAX_CHAINS_IN_FLIGHT:-5}"     # 5 chains x 45 = 225 tasks in flight
NOTIFY_EMAIL="${NOTIFY_EMAIL:-dcorvino@uni-bonn.de}"
CHAIN_TASKS=45                         # mpnn 20 + boltz 25
CAP_HARD=300
JOBMAP=$WS/runs/fullscale/refold_jobids.tsv
LOG=$WS/runs/fullscale/controller/refold_controller.log
mkdir -p "$(dirname "$LOG")"; : > "$JOBMAP"
exec >>"$LOG" 2>&1
echo "[refold] === folding-only controller start $(date) on $(hostname) ==="

# All 9 conformer chains (RFd done; rerun mpnn->boltz)
CHAINS=($(ls -d "$REND"/*/ 2>/dev/null | xargs -n1 basename | grep -v '__consensus$'))
echo "[refold] ${#CHAINS[@]} conformer chains to refold: ${CHAINS[*]}"

submitted_tasks() { squeue -u "$USER" -h -t PENDING,RUNNING -r 2>/dev/null | grep -v operon | wc -l; }

declare -A LAUNCHED_BOLTZ
launch_chain() {
  local ch="$1" d="$REND/$1" jm jb
  jm=$(sbatch --parsable "$d/proteinmpnn.sbatch" 2>>"$LOG.err")   # no upstream dep (RFd done)
  if [ -z "$jm" ]; then echo "[refold] MPNN submit FAILED for $ch (cap?), retry next loop"; return 1; fi
  jb=$(sbatch --parsable --dependency=afterany:$jm "$d/boltz.sbatch" 2>>"$LOG.err")
  if [ -z "$jb" ]; then echo "[refold] Boltz submit FAILED for $ch -> cancel mpnn $jm, retry"; scancel "$jm"; return 1; fi
  echo -e "$ch\tmpnn=$jm\tboltz=$jb" >> "$JOBMAP"
  echo "[refold] launched $ch : mpnn=$jm boltz=$jb"
  LAUNCHED_BOLTZ["$ch"]=$jb
  return 0
}

idx=0; inflight=()
while [ $idx -lt ${#CHAINS[@]} ] || [ ${#inflight[@]} -gt 0 ]; do
  new_inflight=()
  for entry in "${inflight[@]}"; do
    cbb="${entry##*:}"
    if squeue -j "$cbb" -h 2>/dev/null | grep -q .; then new_inflight+=("$entry"); fi
  done
  inflight=("${new_inflight[@]}")
  while [ ${#inflight[@]} -lt $MAXC ] && [ $idx -lt ${#CHAINS[@]} ]; do
    cur=$(submitted_tasks)
    if [ $((cur + CHAIN_TASKS)) -gt $((CAP_HARD - 5)) ]; then
      echo "[refold] headroom guard: $cur tasks + $CHAIN_TASKS chain > cap; waiting"; break
    fi
    if launch_chain "${CHAINS[$idx]}"; then
      inflight+=("${CHAINS[$idx]}:${LAUNCHED_BOLTZ[${CHAINS[$idx]}]}")
      idx=$((idx+1))
    else
      break
    fi
  done
  { [ $idx -lt ${#CHAINS[@]} ] || [ ${#inflight[@]} -gt 0 ]; } && sleep 120
done
echo "[refold] all conformer chains submitted $(date)"

# --- Per-arm consensus (refold->chai->cross), afterany on that arm's boltz jobs ---
echo "[refold] submitting per-arm consensus..."
LAST_CROSS=()
for cdir in $(ls -d "$REND"/*__consensus/ 2>/dev/null | xargs -n1 basename); do
  arm="${cdir%%__consensus}"
  deps=$(awk -F'\t' -v a="${arm}__" '$1 ~ "^"a {sub("boltz=","",$3); print $3}' "$JOBMAP" | paste -sd: -)
  if [ -z "$deps" ]; then echo "[refold] WARN no chains for $arm, skip"; continue; fi
  jp=$(sbatch --parsable --dependency=afterany:$deps "$REND/$cdir/refold_prep.sbatch")
  jf=$(sbatch --parsable --dependency=afterany:$jp "$REND/$cdir/refold_fold.sbatch")
  jr=$(sbatch --parsable --dependency=afterany:$jf "$REND/$cdir/refold_rank.sbatch")
  jc=$(sbatch --parsable --dependency=afterany:$jr "$REND/$cdir/chai.sbatch")
  jx=$(sbatch --parsable --dependency=afterany:$jc "$REND/$cdir/crossspecies.sbatch")
  echo -e "${arm}__consensus\trefprep=$jp\trefold=$jf\trefrank=$jr\tchai=$jc\tcross=$jx" >> "$JOBMAP"
  echo "[refold] $arm consensus: refprep=$jp refold=$jf refrank=$jr chai=$jc cross=$jx (afterany:$deps)"
  LAST_CROSS+=("$jx")
done

# --- Completion email (afterany ALL cross jobs) ---
if [ ${#LAST_CROSS[@]} -gt 0 ] && [ -n "$NOTIFY_EMAIL" ]; then
  alldeps=$(IFS=:; echo "${LAST_CROSS[*]}")
  jn=$(sbatch --parsable --dependency=afterany:$alldeps \
        --account=ag_iei_abdullah --partition=intelsr_short --time=00:05:00 \
        --ntasks=1 --cpus-per-task=1 --mem=2G --job-name=nkg7_done \
        --mail-user="$NOTIFY_EMAIL" --mail-type=END,FAIL \
        --wrap="echo 'NKG7 folding-only rerun complete. Verify OUTPUT (per-arm scored counts, non-empty ranked CSVs) under $WS/runs/fullscale/*/{04_chai,05_crossspecies,06_refold} before trusting.'")
  echo -e "notify\temail=$jn" >> "$JOBMAP"
  echo "[refold] email job=$jn (afterany:$alldeps) -> $NOTIFY_EMAIL"
fi
echo "[refold] === controller complete $(date); map: $JOBMAP ==="
