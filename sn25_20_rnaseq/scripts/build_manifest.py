#!/usr/bin/env python3
"""Build scripts/samples.tsv from a sample sheet + the actual FASTQ files.

Pairs R1/R2 by filename prefix and joins each sample to its condition from a
two-column (or tab-delimited) sample sheet. Adjust the sample-sheet parsing and
the donor/treatment split to your naming scheme.

Usage: python build_manifest.py <workspace_root> [sample_sheet.txt]
  - FASTQs expected in <ws>/raw/ as *_1.fq.gz / *_2.fq.gz (edit SUFFIXES below)
  - sample_sheet: lines "<sample_id>\\t<condition words>"; donor = first word,
    treatment = remaining words joined by '_'. EDIT for your design.
"""
import os, sys, glob, csv
from collections import Counter

R1_SUF, R2_SUF = "_1.fq.gz", "_2.fq.gz"   # EDIT for your naming (e.g. _R1_001.fastq.gz)

def main():
    ws = sys.argv[1] if len(sys.argv) > 1 else os.popen("ws_find sn25_20_rnaseq").read().strip()
    raw = os.path.join(ws, "raw")
    sheet = sys.argv[2] if len(sys.argv) > 2 else None
    cond = {}
    if sheet and os.path.exists(sheet):
        with open(sheet) as f:
            for line in f:
                line = line.strip().replace("\r", "")
                if not line:
                    continue
                parts = line.split("\t")
                if len(parts) >= 2:
                    cond[parts[0].strip()] = parts[1].strip()
    rows = []
    for r1 in sorted(glob.glob(os.path.join(raw, f"*{R1_SUF}"))):
        b = os.path.basename(r1)
        sid = b[:-len(R1_SUF)]
        r2 = r1[:-len(R1_SUF)] + R2_SUF
        assert os.path.exists(r2), f"missing R2 for {sid}"
        c = cond.get(sid, "UNKNOWN")
        w = c.split()
        donor = w[0] if w else "NA"
        treatment = "_".join(w[1:]) if len(w) > 1 else (w[0] if w else "NA")
        rows.append((sid, sid, donor, treatment, c.replace(" ", "_"), r1, r2))
    out = os.path.join(ws, "scripts", "samples.tsv")
    os.makedirs(os.path.dirname(out), exist_ok=True)
    with open(out, "w", newline="") as f:
        w = csv.writer(f, delimiter="\t")
        w.writerow(["sample_id", "deid", "donor", "treatment", "condition", "fastq_1", "fastq_2"])
        w.writerows(rows)
    print(f"wrote {out}: {len(rows)} samples")
    print("donors:", dict(Counter(r[2] for r in rows)))
    print("treatments:", len(set(r[3] for r in rows)))

if __name__ == "__main__":
    main()
