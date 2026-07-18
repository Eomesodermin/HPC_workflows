#!/usr/bin/env python3
"""Turn featureCounts output into a clean gene_id x sample matrix for DESeq2.

featureCounts writes: line 1 = command comment, line 2 = header
(Geneid Chr Start End Strand Length <bam paths...>), then counts. This replaces
the BAM-path columns with sample IDs (the parent dir name of each BAM) in the
same order and drops the annotation columns.

Usage: python tidy_matrix.py <workspace_root>
  reads  <ws>/counts/featurecounts.txt
  writes <ws>/counts/gene_counts_matrix.tsv
"""
import os, sys, csv, statistics

def main():
    ws = sys.argv[1] if len(sys.argv) > 1 else os.popen("ws_find sn25_20_rnaseq").read().strip()
    fc = os.path.join(ws, "counts", "featurecounts.txt")
    with open(fc) as f:
        lines = f.readlines()
    header = lines[1].rstrip("\n").split("\t")
    bam_cols = header[6:]
    ids = [os.path.basename(os.path.dirname(b)) for b in bam_cols]
    out = os.path.join(ws, "counts", "gene_counts_matrix.tsv")
    n = 0
    with open(out, "w", newline="") as g:
        w = csv.writer(g, delimiter="\t")
        w.writerow(["gene_id"] + ids)
        for ln in lines[2:]:
            p = ln.rstrip("\n").split("\t")
            w.writerow([p[0]] + p[6:])
            n += 1
    print(f"wrote {out}: {n} genes x {len(ids)} samples")
    # library-size sanity summary
    with open(out) as f:
        rd = csv.reader(f, delimiter="\t"); next(rd)
        sums = [0] * len(ids)
        for row in rd:
            for i, v in enumerate(row[1:]):
                sums[i] += int(v)
    print("lib sizes (M): min %.1f  median %.1f  max %.1f" %
          (min(sums)/1e6, statistics.median(sums)/1e6, max(sums)/1e6))

if __name__ == "__main__":
    main()
