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
- Plan authored 2026-07-14.
- **Tier 0 complete (2026-07-14)** → gate: **ESCALATE to Tier 1**. Marvin workspace created; NKG7
  confirmed a claudin/PMP-22/Ca_V-γ tetraspan (PF00822/IPR004031), but every structural/evolutionary
  analog is non-conducting (auxiliary Ca_V/TARP-γ subunits, paracellular claudins); no ion-transport
  or signalling domain; monomer pore occluded. Skeptical prior toward a scaffold/modulator role.
  Report: [`reports/nkg7_tier0_triage_report.html`](reports/nkg7_tier0_triage_report.html).
- **Tier 1 complete (2026-07-14)** → gate: **STOP the channel track**. Homo-oligomer C2–C6 predicted
  with three independent methods (Boltz-2, AlphaFold3 3.0.1, Chai-1) + reference-HOLE pore re-scan of all
  15 models. No confident oligomer (best interface ipTM 0.63; predictors disagree on stoichiometry AND
  confidence), and pore-opening anti-correlates with confidence — every confident model is occluded, the
  only "open" ones are low-confidence 100+ Å splayed aggregates. Weight of evidence now **against** a
  self-contained channel, **for** a scaffold/auxiliary-modulator role. Do not run channel-centric Tier 2/3;
  if Ca²⁺ biology matters, reframe to a hetero-complex campaign (NKG7 + candidate partner).
  Report: [`reports/nkg7_tier1_oligomer_report.html`](reports/nkg7_tier1_oligomer_report.html).

*All in silico. Any positive result requires wet-lab confirmation (patch clamp / bilayer reconstitution / Ca²⁺-flux).*
