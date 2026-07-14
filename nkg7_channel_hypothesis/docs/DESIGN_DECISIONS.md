# NKG7 Channel-Hypothesis — Design Decisions Log

Chronological record of decisions and their rationale. Newest at bottom.

## 2026-07-14 — Execution kickoff (Tier 0)

**Workspace.** Allocated a dedicated marvin Lustre workspace
`/lustre/scratch/data/dcorvino_hpc-nkg7_channel_hypothesis` (90d, `ws_allocate -F scratch`),
standard subdir layout per plan Section 5. NKG7 human (Q16617) and mouse (Q99PA5) AlphaFold
monomer models (both 165 aa, AFDB v6) copied from the binder-design workspace into `$WS/targets/`
and mirrored locally as project artifacts. Canonical sequences pulled from UniProt (both 165 aa).

**Cluster-footprint check.** Binder-design campaign still live at kickoff: ~213 array tasks in
flight (cap 300 running + 300 submitted), actively releasing waves. ~87 slots headroom. Tier 0 is
tiny (one small CPU sbatch for Foldseek + API/local work) → safe to run now without threatening the
cap. Tier 3 (membrane MD) remains gated on binder-campaign drain + explicit user go/no-go.

**Parallelization.** Tier 0's five workstreams (0A fold / 0B sequence / 0C transcripts / 0D domains
/ 0E monomer-pore) have no cross-dependencies, so dispatched as five concurrent sub-agents. Only 0A
uses marvin (Foldseek); 0B–0E are API/local-compute. Orchestrator synthesizes their outputs into the
Tier-0 HTML report + gate decision (sub-agents do NOT each write the HTML report).

**Standing hypothesis framing.** Every workstream instructed to test BOTH the channel hypothesis and
the honest counter-hypothesis (Ca_V gamma / claudin family precedent is equally consistent with a
non-conducting modulator/scaffold role — cf. the known v-ATPase/mTORC1 function). Family-precedent
hits (Ca_V gamma, claudin, MP20) are EXPECTED and do not themselves prove a pore. All conclusions
framed as computational, requiring wet-lab confirmation.

**Accession discipline.** Sub-agents told never to cite family/accession IDs from memory — pull all
InterPro/Pfam/RefSeq/Ensembl IDs from the live databases (esp. Tier 0D InterProScan).

## 2026-07-14 — Tier 0 complete → gate: ESCALATE to Tier 1

All five workstreams ran successfully (four sub-agents finished cleanly; the Foldseek sub-agent's
search completed on marvin but its result-file download stalled on an approval gate — the orchestrator
harvested the 4 result TSVs directly and stopped the stuck child).

**Convergent finding:** NKG7 is a bona-fide **claudin / PMP-22 / Ca_V-γ (CACNG) tetraspan 4-TM
superfamily** member (confirmed independently by Foldseek fold, Ensembl Compara paralogy, EBI phmmer
profile, and InterProScan PF00822/IPR004031). **But every specific analog is non-conducting:**
- **0A Foldseek:** top-20 PDB100 = ~10 claudins + 8–9 Ca_V/TARP-γ auxiliary subunits, zero standalone
  conducting pores. Critical chain-level check: the "Ca²⁺ channel" hits match the **γ auxiliary**
  subunit (3jbr→CACNG1, 9b5z→CACNG2), NOT the pore α-subunit. TM-score 0.85–0.90, seq id ~10–19%.
- **0B Sequence:** NKG7 is a BLAST singleton (no paralog/pseudogene); closest paralog GSG1L is a
  claudin-fold **auxiliary subunit of AMPA channels**. chr19q13.4 tandem cluster with LIM2/MP20 + CLDND2.
- **0C Transcripts:** dominant product in every expressing tissue (79–89%) is the intact 4-TM 165-aa
  canonical isoform; immune-restricted (blood 498 TPM). No channel-diagnostic splicing. Permissive.
- **0D Domains:** claudin family confirmed with live accessions; **NO ion-transport domain, NO channel
  GO term, NO signalling domain (no ITAM/ITIM/SH2/PDZ)**. 4-TM topology confirmed. Only motif = YETL.
- **0E Monomer pore:** occluded — narrowest constriction 0.65 Å (human) / 0.79 Å (mouse), sub-water.
  Expected negative for a lone 4-TM bundle.

**Gate decision:** ESCALATE to Tier 1 (oligomer prediction). The family architecture justifies the
decisive oligomer/pore test, BUT Tier 0 sets a **skeptical prior** — the weight of evidence already
leans toward a scaffold / auxiliary-modulator role (consistent with the known v-ATPase/mTORC1
function) rather than a conducting channel. Tier 1 will decide.

**Tooling note for Tier 1:** the sandbox could not install the reference HOLE binary; the Tier-1
oligomer pore re-scan should install real HOLE2/CHAP on marvin (or MDAnalysis+hole2 in a conda env
there) rather than the geometric probe-sphere fallback used for the monomer scan.

Report: `reports/nkg7_tier0_triage_report.html` (self-contained). Data: repo `reports/tier0_data/`
(small CSVs/notes/PNG) + `HPC_data/nkg7_channel_hypothesis/tier0/` (incl. heavy foldseek_raw/).
