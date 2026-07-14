#!/bin/bash
# =====================================================================
# recover_controller.sh — RESUME controller for the NKG7 full-scale campaign
# after the original login-node wrapper (PID 399729) died ~2 min post-launch.
#
# Runs AS A SLURM JOB on intelsr_long (7-day walltime, compute node) so it
# CANNOT be reaped like a login-node process. Nested sbatch verified working.
#
# Fixes vs the dead wrapper:
#   * afterany (not afterok) on ALL array->next deps: RFd shards TIMEOUT at the
#     8h wall having written most backbones; afterok would cancel MPNN. afterany
#     proceeds on whatever backbones exist.
#   * RESUME: the 4 human chains + their MPNN/Boltz were already (re)submitted
#     with afterany in stage 1; this controller launches ONLY the 5 mouse chains
#     and ALL 4 arms' consensus phases + the completion email.
#   * Mouse RFd bumped to mlgpu_medium (24h) so shards don't TIMEOUT.
#
# Chains already in flight (human, do NOT resubmit):
#   human_ecl1__c0 rfd=26507458 mpnn=26508713 boltz=26508714
#   human_ecl1__c1 rfd=26507471 mpnn=26508711 boltz=26508712
#   human_ecl2__c0 rfd=26507474 mpnn=26508707 boltz=26508708
#   human_ecl2__c1 rfd=26507477 mpnn=26508709 boltz=26508710
# =====================================================================
#SBATCH --account=ag_iei_abdullah
#SBATCH --partition=intelsr_long
#SBATCH --time=3-00:00:00
#SBATCH --ntasks=1 --cpus-per-task=1 --mem=2G
#SBATCH --job-name=nkg7_ctrl
set -uo pipefail

WS=/lustre/scratch/data/dcorvino_hpc-nkg7_binder_design
REND=$WS/pipeline/rendered_prod
MAXC="${MAX_CHAINS_IN_FLIGHT:-3}"     # 3 mouse chains x 65 = 195 tasks; human chains draining alongside
ACCT=ag_iei_abdullah
NOTIFY_EMAIL="${NOTIFY_EMAIL:-dcorvino@uni-bonn.de}"
CAP_SOFT=270                          # keep total submitted tasks under this (hard cap 300)
JOBMAP=$WS/runs/fullscale/recovery_jobids.tsv   # human rescue rows already here; append mouse+consensus
LOG=$WS/runs/fullscale/controller/controller.log
mkdir -p "$(dirname "$LOG")"
exec >>"$LOG" 2>&1
echo "[ctrl] === resume controller start $(date) on $(hostname) ==="

# Mouse chains to launch (human already in flight)
MOUSE_CHAINS=(mouse_ecl1__c0 mouse_ecl1__c1 mouse_ecl1__c2 mouse_ecl2__c0 mouse_ecl2__c1)
# All arms need a consensus phase; human chains' boltz ids come from the human rescue rows
declare -A HUMAN_BOLTZ=( [human_ecl1]="26508714 26508712" [human_ecl2]="26508708 26508710" )
CHAIN_TASKS=65     # rfd 20 + mpnn 20 + boltz 25 for one mouse chain
CAP_HARD=300

submitted_tasks() { squeue -u "$USER" -h -t PENDING,RUNNING -r 2>/dev/null | grep -v operon | wc -l; }

# Launch a full chain ONLY if the whole 65-task chain fits under the cap, and
# verify each hop actually submitted (else roll back so we never leave a half-chain).
launch_mouse_chain() {
  local ch="$1" d="$REND/$1" jr jm jb
  jr=$(sbatch --parsable "$d/rfdiffusion.sbatch" 2>>"$LOG.err")
  if [ -z "$jr" ]; then echo "[ctrl] RFd submit FAILED for $ch (cap?), will retry next loop"; return 1; fi
  jm=$(sbatch --parsable --dependency=afterany:$jr "$d/proteinmpnn.sbatch" 2>>"$LOG.err")
  if [ -z "$jm" ]; then echo "[ctrl] MPNN submit FAILED for $ch -> cancel rfd $jr, retry"; scancel "$jr"; return 1; fi
  jb=$(sbatch --parsable --dependency=afterany:$jm "$d/boltz.sbatch" 2>>"$LOG.err")
  if [ -z "$jb" ]; then echo "[ctrl] Boltz submit FAILED for $ch -> cancel rfd $jr mpnn $jm, retry"; scancel "$jr" "$jm"; return 1; fi
  echo -e "$ch\trfd=$jr\tmpnn=$jm\tboltz=$jb" >> "$JOBMAP"
  echo "[ctrl] launched $ch : rfd=$jr mpnn=$jm boltz=$jb"
  LAUNCHED_BOLTZ["$ch"]=$jb
  return 0
}

declare -A LAUNCHED_BOLTZ
idx=0; inflight=()
while [ $idx -lt ${#MOUSE_CHAINS[@]} ] || [ ${#inflight[@]} -gt 0 ]; do
  new_inflight=()
  for entry in "${inflight[@]}"; do
    cbb="${entry##*:}"
    if squeue -j "$cbb" -h 2>/dev/null | grep -q .; then new_inflight+=("$entry"); fi
  done
  inflight=("${new_inflight[@]}")
  while [ ${#inflight[@]} -lt $MAXC ] && [ $idx -lt ${#MOUSE_CHAINS[@]} ]; do
    cur=$(submitted_tasks)
    # FULL-chain headroom: only start if the entire 65-task chain fits under the hard cap
    if [ $((cur + CHAIN_TASKS)) -gt $((CAP_HARD - 5)) ]; then
      echo "[ctrl] headroom guard: $cur tasks + $CHAIN_TASKS chain > cap; waiting"; break
    fi
    if launch_mouse_chain "${MOUSE_CHAINS[$idx]}"; then
      inflight+=("${MOUSE_CHAINS[$idx]}:${LAUNCHED_BOLTZ[${MOUSE_CHAINS[$idx]}]}")
      idx=$((idx+1))
    else
      break   # submit failed (cap race); wait and retry this same chain
    fi
  done
  { [ $idx -lt ${#MOUSE_CHAINS[@]} ] || [ ${#inflight[@]} -gt 0 ]; } && sleep 120
done
echo "[ctrl] all mouse chains submitted $(date)"

# --- Consensus phase for ALL 4 arms (held afterany on that arm's boltz jobs) ---
echo "[ctrl] submitting per-arm consensus (refold->chai->cross), afterany on chains..."
LAST_CROSS_IDS=()
for cdir in $(ls -d "$REND"/*__consensus/ 2>/dev/null | xargs -n1 basename); do
  arm="${cdir%%__consensus}"
  # gather this arm's boltz ids: human from HUMAN_BOLTZ, mouse from JOBMAP rows
  if [ -n "${HUMAN_BOLTZ[$arm]:-}" ]; then
    deps=$(echo "${HUMAN_BOLTZ[$arm]}" | tr ' ' ':')
  else
    deps=$(awk -F'\t' -v a="${arm}__" '$1 ~ "^"a {sub("boltz=","",$4); print $4}' "$JOBMAP" | paste -sd: -)
  fi
  if [ -z "$deps" ]; then echo "[ctrl] WARN no chains for $arm, skip consensus"; continue; fi
  jp=$(sbatch --parsable --dependency=afterany:$deps "$REND/$cdir/refold_prep.sbatch")
  jf=$(sbatch --parsable --dependency=afterany:$jp "$REND/$cdir/refold_fold.sbatch")
  jr=$(sbatch --parsable --dependency=afterany:$jf "$REND/$cdir/refold_rank.sbatch")
  jc=$(sbatch --parsable --dependency=afterany:$jr "$REND/$cdir/chai.sbatch")
  jx=$(sbatch --parsable --dependency=afterany:$jc "$REND/$cdir/crossspecies.sbatch")
  echo -e "${arm}__consensus\trefprep=$jp\trefold=$jf\trefrank=$jr\tchai=$jc\tcross=$jx" >> "$JOBMAP"
  echo "[ctrl] $arm consensus: refprep=$jp refold=$jf refrank=$jr chai=$jc cross=$jx (afterany:$deps)"
  LAST_CROSS_IDS+=("$jx")
done

# --- Email-on-completion (one job, afterany ALL cross jobs) ---
if [ ${#LAST_CROSS_IDS[@]} -gt 0 ] && [ -n "$NOTIFY_EMAIL" ]; then
  alldeps=$(IFS=:; echo "${LAST_CROSS_IDS[*]}")
  jn=$(sbatch --parsable --dependency=afterany:$alldeps \
        --account=$ACCT --partition=intelsr_short --time=00:05:00 \
        --ntasks=1 --cpus-per-task=1 --mem=2G --job-name=nkg7_done \
        --mail-user="$NOTIFY_EMAIL" --mail-type=END,FAIL \
        --wrap="echo 'NKG7 full-scale campaign complete. Results under $WS/runs/fullscale/*/{04_chai,05_crossspecies,06_refold}.'")
  echo -e "notify\t-\t-\t-\t-\temail=$jn" >> "$JOBMAP"
  echo "[ctrl] email-on-completion job=$jn (afterany:$alldeps) -> $NOTIFY_EMAIL"
fi
echo "[ctrl] === controller complete $(date); job map: $JOBMAP ==="
