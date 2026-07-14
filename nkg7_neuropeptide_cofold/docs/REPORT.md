# NKG7 × neuropeptide binding — integrated report

**Prepared for:** Susanna Ng / A. Loukas Lab collaboration (grant P1_NKG7)
**Compute:** marvin HPC (SLURM, NVIDIA A40)
**Software:** Boltz-2 v2.2.1; OpenMM 8.2 + AmberTools 24 (ff14SB, GBn2)

---

## 1. Background and question

The Alex Loukas lab (Connor McHugh, AITHM/JCU) screened the full human secretome
against the two NKG7 extracellular-loop peptide sequences with **AlphaFold-Multimer
(AFM)** and nominated a set of neuropeptides as candidate **NKG7** binders. Those
hits passed the screen's contact filter (LIS/LIA) but sat at the **bottom** of the
AFM confidence ranking (ipTM ≈ 0.27–0.49) — plausible but weak.

**Question for this workflow:** does an independent structure predictor reproduce a
consistent NKG7-binding mode for these neuropeptides, and can we distinguish genuine
binding from the general "stickiness" of the NKG7 loops?

## 2. Methods primer (plain language)

**NKG7** is a small four-transmembrane (4-TM) membrane protein. Its two extracellular
loops — **ECL1 (residues 30–60)** and **ECL2 (residues 113–132)** — are the only parts
a secreted peptide could contact from outside the cell, so they are the target surface.

**Co-folding (Boltz-2).** Boltz-2 is an open structure predictor (an AlphaFold3-class
model) that, given two sequences, predicts the 3-D structure of the *complex*. We use it
as an **orthogonal cross-check** to the Loukas AFM screen — a second, mechanistically
independent method looking at the same question.

**ipTM (interface predicted TM-score, 0–1).** The model's own confidence that the
*interface between the two chains* is correct. > 0.5 is the conventional "the model
thinks these two things form an interface" threshold. **ipTM is a geometric confidence
score, not a binding energy** — a high ipTM says the model can place the peptide on the
receptor confidently, not that the pair binds tightly or specifically in reality.

**MM/GBSA — Molecular Mechanics / Generalized Born Surface Area.** A physics-based
estimate of **binding free energy** (ΔG_bind): how energetically favourable it is for the
peptide and NKG7 to be bound versus free in solution. It combines (i) *molecular
mechanics* force-field energy (bonds, angles, torsions, van der Waals, electrostatics;
here Amber **ff14SB**), (ii) *Generalized Born* implicit solvent — water treated as a
continuum to estimate the electrostatic cost of desolvation on binding, and (iii) a
*surface-area* term for the hydrophobic contribution. The estimate is computed as

> ΔG_bind ≈ ⟨E_complex⟩ − ⟨E_receptor⟩ − ⟨E_peptide⟩   (averaged over short-MD snapshots)

**Caveat (stated up front):** single-trajectory MM/GBSA omits configurational entropy
(−TΔS) and uses approximate implicit-solvent electrostatics, so the number is **not an
absolute Kd**. It is a **relative ranking tool** — meaningful *within* this run and
*against the scrambled controls*, not as an absolute affinity. This is the same footing
used in the sister `ligand_cofold` (p-cresol-sulfate) workflow.

**Scrambled controls (the specificity test).** The core risk is that NKG7's loops accept
*any* short peptide. To test this we co-fold **sequence-shuffled decoys** — identical
amino-acid composition, biological motif destroyed. If a real peptide scores no better
than its own shuffles, its confident co-fold is not evidence of specific binding. Several
independent shuffles per peptide give a **null distribution**, against which each real
peptide gets a **z-score**.

## 3. Inputs

**Receptor:** human NKG7 (UniProt Q16617, 165 aa), full length. Sequence and loop
definitions cross-verified four ways (UniProt topology; Loukas "Alex NKG7 extracellular
domains" pptx; the local NKG7 minibinder campaign config; the AF model staged on marvin) —
all agree. TM helices 9–29 / 61–81 / 92–112 / 133–153 ⇒ ECL1 = 30–60, ECL2 = 113–132.

**Peptides:** mature bioactive forms (from UniProt processed-peptide features), `inputs/peptides.csv`:

| ID | Peptide | UniProt | Mature range | Length |
|----|---------|---------|--------------|--------|
| PROK2 | prokineticin-2 | Q9HC23 | 28–129 | 102 |
| PDYN | dynorphin A(1-17) | P01213 | 207–223 | 17 |
| MCH | melanin-concentrating hormone | P20382 | 147–165 | 19 |
| GALP | galanin-like peptide | Q9UBC7 | 25–84 | 60 |
| VGF | VGF TLQP-21 | O15240 | 554–574 | 21 |
| TKN4 | tachykinin-4 / neurokinin-B | Q9UHF0 | 81–90 | 10 |
| SCG2 | secretoneurin | P13521 | 182–214 | 33 |

MCH modelled with its native Cys7–Cys16 disulfide (explicit bond constraint).

## 4. Co-folding results

Each NKG7+peptide pair predicted with Boltz-2 (`--recycling_steps 3
--diffusion_samples 5 --use_msa_server`; real MSAs confirmed — this is a native
receptor, not a de novo binder). Top model (`model_0`) carried forward. Heavy-atom
contacts counted at 4.5 Å; each contacted NKG7 residue assigned to ECL1 / ECL2 / TM /
other.

**Ranked by ipTM** (`results/nkg7_neuropeptide_ranked.csv`):

| ID | Peptide | ipTM | complex pLDDT | pTM | conf. | ECL1 | ECL2 | Loop |
|----|---------|------|------|-----|-------|------|------|------|
| MCH | melanin-concentrating hormone | **0.95** | 0.87 | 0.94 | 0.89 | 18 | 7 | ECL1 |
| PDYN | dynorphin A(1-17) | **0.93** | 0.85 | 0.94 | 0.87 | 18 | 9 | ECL1 |
| _CTRL_ | _scrambled dynorphin-A_ | _0.92_ | _0.83_ | _0.94_ | _0.85_ | _22_ | _6_ | _ECL1_ |
| TKN4 | tachykinin-4 / neurokinin-B | 0.90 | 0.89 | 0.94 | 0.89 | 11 | 6 | ECL1 |
| VGF | VGF TLQP-21 | 0.89 | 0.84 | 0.92 | 0.85 | 17 | 9 | ECL1 |
| SCG2 | secretoneurin | 0.81 | 0.83 | 0.90 | 0.83 | 17 | 8 | ECL1 |
| GALP | galanin-like peptide | 0.79 | 0.79 | 0.88 | 0.79 | 20 | 8 | ECL1 |
| PROK2 | prokineticin-2 | 0.64 | 0.75 | 0.80 | 0.73 | 18 | 8 | ECL1 |

![Confidence + loop engagement](../figures/summary_panel.png)

![Complex gallery](../figures/complex_gallery.png)

*Renders: NKG7 grey; ECL1 orange; ECL2 teal; TM helices dark grey; peptide magenta;
interface side chains as sticks.*

**ECL1 is the shared docking site.** Every peptide — and the scrambled control — engages
a common ECL1 surface. Nine ECL1 residues are contacted in **all eight** complexes:
**A31, H36, A38, H39, S40, P44, T45, D49, Y54** (with W43, I50, S52 in most). A secondary
ECL2 rim (P120, H122, I125, T127) is present but never dominates. Several peptides (PDYN,
TKN4, SCG2, VGF) form a short β-strand that pairs antiparallel with the ECL1 backbone;
MCH docks its disulfide-closed helix-loop into the ECL1/ECL2 cleft.

## 5. The specificity finding

The scrambled dynorphin-A control reproduces the real peptides' behaviour almost
exactly: **ipTM 0.92, the same ECL1 residues, the same loop assignment** — out-scoring
five of the seven real peptides. Therefore:

1. **NKG7 ECL1 is a promiscuous, "sticky" peptide-binding groove.** A confident Boltz-2
   co-fold is expected for almost any short cationic/amphipathic peptide, so high ipTM
   here is **not** evidence of a genuine physiological ligand.
2. The Boltz-2 result is best reported as an **orthogonal cross-check that reproduces a
   consistent binding *site*** (corroborating the ECL1 region the AFM screen implicated),
   not as validation of individual peptide identities.
3. **The meaningful readout is each real peptide vs its own scrambles.** On the single
   control so far, only **MCH** and **PDYN** clearly beat it.

## 6. Specificity expansion — null distributions + MM/GBSA

Two follow-up analyses put the specificity question on a quantitative footing.

### 6A. Null ipTM distributions (5 shuffles per peptide)

Each real peptide was compared to **5 composition-matched scrambled decoys**
(same amino acids, sequence shuffled, fixed seeds), co-folded identically — 35
extra complexes. Real ipTM vs the mean±SD of its own decoy null:

| Peptide | real ipTM | null mean±SD | z-score | emp. p |
|---------|-----------|--------------|---------|--------|
| MCH | 0.946 | 0.906 ± 0.023 | **+1.74** | 0.17 |
| PDYN | 0.925 | 0.899 ± 0.048 | +0.54 | 0.67 |
| GALP | 0.790 | 0.834 ± 0.136 | −0.32 | 0.83 |
| VGF | 0.888 | 0.897 ± 0.015 | −0.59 | 0.67 |
| TKN4 | 0.904 | 0.923 ± 0.023 | −0.85 | 0.67 |
| PROK2 | 0.635 | 0.766 ± 0.126 | −1.04 | 0.83 |
| SCG2 | 0.809 | 0.898 ± 0.029 | **−3.10** | 1.00 |

![Null ipTM distributions](../figures/null_distribution.png)

**No neuropeptide clears its own scrambled null.** Best case MCH is z = +1.74
(p = 0.17, n.s. at n=5); four of seven have *negative* z-scores — their real
sequence docks no better, or worse, than shuffles of themselves. ECL1 docking
confidence is driven by amino-acid composition, not the specific sequence.

### 6B. Peptide MM/GBSA binding energies

All 8 poses rescored with single-trajectory MM/GBSA adapted for peptide ligands
(whole complex ff14SB + GBn2; receptor = chain A, ligand = chain B; 25 snapshots;
no small-molecule force field). 8/8 succeeded incl. the 102-aa PROK2.

| Peptide | ΔG (kcal/mol) | SEM | ΔΔG vs CTRL | ipTM |
|---------|---------------|-----|-------------|------|
| GALP | **−115.8** | 1.5 | **−17.4** | 0.79 |
| _CTRL_ | _−98.4_ | _1.1_ | _0.0_ | _0.92_ |
| MCH | −76.0 | 0.7 | +22.4 | 0.95 |
| PROK2 | −75.9 | 1.2 | +22.5 | 0.64 |
| VGF | −75.9 | 0.9 | +22.5 | 0.89 |
| SCG2 | −67.3 | 1.4 | +31.1 | 0.81 |
| PDYN | −55.5 | 1.3 | +43.0 | 0.92 |
| TKN4 | −49.6 | 0.9 | +48.9 | 0.90 |

![MM/GBSA analysis](../figures/mmgbsa_analysis.png)

**Only GALP beats the scrambled control energetically** (−17.4 kcal/mol vs CTRL);
every other real peptide is *less* favourable than the scramble. **ΔG is
uncorrelated with ipTM** (Pearson r = 0.22 over all 8, p = 0.61; r = 0.37 over
the 7 real peptides, p = 0.42 — n.s.).

### 6C. Combined interpretation

The two orthogonal readouts **disagree and neither singles out a convincing
specific binder**: the ipTM null test's least-bad candidate is MCH (still n.s.),
while MM/GBSA favours GALP — a weak ipTM hit. The in-silico evidence **does not
support sequence-specific, high-affinity binding of any single neuropeptide** at
the resolution of these methods. What both methods *agree* on is the **binding
site**: ECL1 (res 30–60). The models localise a candidate interaction surface but
cannot rank the neuropeptides as physiological ligands — the ECL1 groove accepts
peptides too promiscuously for confidence or single-trajectory energy to
discriminate. See `results/nkg7_specificity_scorecard.csv`.

## 7. Wet-lab recommendations

- **Experimental validation is now the rate-limiter, not more prediction.** The
  in-silico screen localised the site (ECL1) and showed confidence/energy cannot
  rank the peptides. Direct binding assays (SPR/BLI competition against the ECL1
  peptide) are the decisive next step.
- If pursuing any peptide computationally, **GALP** (best MM/GBSA) and **MCH**
  (best ipTM z) are the two least-inconsistent candidates — but they are nominated
  by *different* methods, itself a caution flag.
- The NKG7-KO NK killing assay with PROK2 / dynorphin-A remains the most direct
  functional test and is unaffected by these ranking ambiguities.
- Treat all ipTM-based rankings as **hypothesis-generating**, not confirmatory:
  the scrambled controls show the assay's confident-by-default failure mode.

## 8. Files

- `results/nkg7_neuropeptide_ranked.csv` — confidence + contact table (8 complexes)
- `results/contacts_detail.json` — per-complex contacted-residue lists
- `figures/summary_panel.png`, `figures/complex_gallery.png`, `figures/complex_<ID>.png`
- `structures/NKG7_<ID>.pdb` — co-fold coordinates (chain A = NKG7, chain B = peptide)
- `pipeline/` — YAML render, interface analysis, PyMOL render, peptide MM/GBSA
- `envs/` — marvin conda env specs + build gotchas
