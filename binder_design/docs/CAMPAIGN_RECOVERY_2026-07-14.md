# Full-scale campaign recovery — 2026-07-14

The original login-node wave wrapper (`submit_fullscale_waves.sh`, PID 399729,
launched 2026-07-13 22:47) **died ~2 minutes after launch** (last log write
22:49:01). Root cause: the login node's periodic sweep reaped the long-lived
process — `setsid` survives the SSH session ending but NOT the login-node
reaper. Only wave 1 (4 human chains) had been submitted; the 5 mouse chains,
all 4 consensus phases, and the completion email were never reached.

A **second latent bug** was also found: the deployed wrapper wired array→next
dependencies with `afterok`. RFdiffusion at 500 bb/shard needs ~7.3–8 h and
hits the 8 h `mlgpu_short` wall → shards end `TIMEOUT` (after writing most of
their backbones). `afterok` requires every array task to reach `COMPLETED`, so
a single TIMEOUT'd shard would cancel the downstream MPNN with
`DependencyNeverSatisfied`.

## Fix
1. **Rescued the 4 human chains**: cancelled the doomed `afterok` MPNN/Boltz and
   resubmitted them `afterany` on the existing RFd arrays (which had already
   produced ~7.7–9.4k of 10k backbones each — not rerun).
2. **`recover_controller.sh`**: a resume-aware controller that runs **as a SLURM
   batch job** on `intelsr_long` (7-day walltime, compute node → reap-immune;
   nested `sbatch` verified working on marvin). It launches only the 5 mouse
   chains + all 4 consensus phases + the email, `afterany` throughout, with a
   **full-chain (65-task) headroom guard** so it never leaves a half-chain when
   near the 300-job cap, and per-hop submit verification (rolls back RFd if
   MPNN/Boltz bounce off the cap).
3. **Mouse RFd bumped to `mlgpu_medium` (24 h)** so shards COMPLETE, not TIMEOUT.
4. `submit_fullscale_waves.sh` patched to `afterany` for future reuse.

## Lessons (also captured in the `marvin-hpc-campaigns` skill)
- Never run a long-lived campaign controller on the login node — submit it as a
  batch job on a long-walltime CPU partition.
- Use `afterany` (not `afterok`) for array→next dependencies; reserve `afterok`
  for single→single hops. Size shards to fit the wall, or use a 24 h partition.
- Guard cap headroom for the WHOLE chain, not one task at a time.
