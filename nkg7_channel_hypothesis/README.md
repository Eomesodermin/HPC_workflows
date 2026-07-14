# NKG7 Ion-Channel Hypothesis — In Silico Evaluation

Testing whether the cytotoxic-lymphocyte granule protein **NKG7** (UniProt Q16617 / mouse Q99PA5;
gene ENSG00000105374) functions as an **ion channel** (most plausibly Ca²⁺-permeable), despite no
documented channel activity.

## Start here
**[NKG7_CHANNEL_HYPOTHESIS_PLAN.md](NKG7_CHANNEL_HYPOTHESIS_PLAN.md)** — the comprehensive, self-contained
handoff plan. A fresh session should be able to execute the whole campaign from that document plus the
three companion skills (`marvin-hpc-campaigns`, `denovo-minibinder-pipeline`, `protein-loop-flexibility`).

## Approach (tiered, each gates the next)
- **Tier 0** — structural + sequence + genome + transcript/splice + domain triage; monomer pore scan.
- **Tier 1** — homo-oligomer prediction (Boltz-2 + Chai-1 + AF-Multimer) + pore analysis (the decisive step).
- **Tier 2** — pore electrostatics, selectivity filter, ortholog conservation.
- **Tier 3** — membrane MD + ion-permeation / PMF (expensive; only if Tiers 0–2 justify it).

## Layout
- `NKG7_CHANNEL_HYPOTHESIS_PLAN.md` — the plan (primary deliverable)
- `docs/` — DESIGN_DECISIONS.md, method notes, glossary
- `pipeline/` — scripts + SLURM sbatch (mirror of marvin `$WS/pipeline/`)
- `envs/` — conda env specs
- `reports/` — per-tier self-contained HTML reports

## Marvin workspace
`/lustre/scratch/data/dcorvino_hpc-nkg7_channel_hypothesis` (create per plan Section 5).

## ⚠️ Cluster footprint
A binder-design campaign is running on marvin under the same account (`ag_iei_abdullah`, 300-job cap).
Tier 0–2 are short jobs (safe now); Tier 3 is a multi-day MD campaign — sequence it after the binder
run drains, or throttle low, with explicit user go/no-go. See plan Section 4.

## Status
Plan authored 2026-07-14. Execution not yet started.

*All in silico. Any positive result requires wet-lab confirmation (patch clamp / bilayer reconstitution / Ca²⁺-flux).*
