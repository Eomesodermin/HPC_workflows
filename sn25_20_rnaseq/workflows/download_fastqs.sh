#!/bin/bash
#SBATCH --account=ag_iei_abdullah
#SBATCH --partition=intelsr_medium
#SBATCH --cpus-per-task=8
#SBATCH --mem=16G
#SBATCH --time=12:00:00
#SBATCH --job-name=sn25_dl
#SBATCH --output=%x_%j.log
set -uo pipefail
module load rclone/1.66.0
WS=$(ws_find sn25_20_rnaseq)
cd $WS/raw
START=$SECONDS
rclone copy :webdav: $WS/raw   --include "*.fq.gz"   --transfers 8 --checkers 16   --multi-thread-streams 4   --low-level-retries 20 --retries 10 --retries-sleep 10s   --timeout 120s --contimeout 60s   --stats 60s --stats-one-line   --log-file $WS/logs/rclone_download.log
RC=$?
echo "rclone copy exit=$RC after $((SECONDS-START))s"
echo "=== files present ==="; ls -1 $WS/raw/*.fq.gz 2>/dev/null | wc -l
echo "=== md5 verification ==="
cd $WS/raw
md5sum -c md5sum.txt > $WS/logs/md5_check.log 2>&1
NFAIL=$(grep -c 'FAILED' $WS/logs/md5_check.log || true)
NOK=$(grep -c ': OK' $WS/logs/md5_check.log || true)
echo "md5 OK=$NOK FAILED=$NFAIL"
if [ "$RC" -eq 0 ] && [ "$NFAIL" -eq 0 ] && [ "$NOK" -eq 60 ]; then
  touch $WS/raw/DOWNLOAD_OK; echo "ALL_GOOD"
else
  touch $WS/raw/DOWNLOAD_FAIL; echo "CHECK_FAILED (see md5_check.log)"
fi
echo "[$(date +%T)] download job finished"
