#!/usr/bin/env python3
import csv, os, json
WS=os.environ["WS"]
tgt=list(csv.DictReader(open(f"{WS}/inputs/nkg7_target.csv")))[0]
peps=list(csv.DictReader(open(f"{WS}/inputs/peptides.csv")))
os.makedirs(f"{WS}/yaml",exist_ok=True)
NKG7=tgt["seq"]
# MCH mature DFDMLRCMLGRVYRPCWQV -> Cys at positions 7 and 16 (1-based within peptide chain B)
mch_cys=(7,16)
for p in peps:
    pid=p["pep_id"]; pseq=p["seq"]
    y=["version: 1","sequences:",
       "  - protein:","      id: A",f"      sequence: {NKG7}",
       "  - protein:","      id: B",f"      sequence: {pseq}"]
    if pid=="MCH":
        y+=["constraints:",
            "  - bond:",
            f"      atom1: [B, {mch_cys[0]}, SG]",
            f"      atom2: [B, {mch_cys[1]}, SG]"]
    open(f"{WS}/yaml/NKG7__{pid}.yaml","w").write("\n".join(y)+"\n")
    print(pid, len(pseq),"aa -> NKG7__%s.yaml"%pid, "(+SS)" if pid=="MCH" else "")
print("wrote", len(peps),"yaml files")
