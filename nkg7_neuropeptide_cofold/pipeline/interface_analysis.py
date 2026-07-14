
import os, glob, json
import numpy as np

AA3to1={'ALA':'A','ARG':'R','ASN':'N','ASP':'D','CYS':'C','GLN':'Q','GLU':'E','GLY':'G',
 'HIS':'H','ILE':'I','LEU':'L','LYS':'K','MET':'M','PHE':'F','PRO':'P','SER':'S','THR':'T',
 'TRP':'W','TYR':'Y','VAL':'V'}
ECL1=set(range(30,61))   # NKG7 ECL1 residues 30-60
ECL2=set(range(113,133)) # NKG7 ECL2 residues 113-132
TM=set(range(9,30))|set(range(61,82))|set(range(92,113))|set(range(133,154))

def parse_pdb(path):
    """Return dict chain-> {resnum: {atom: xyz}} and resname map."""
    atoms={}  # (chain,resnum,atom)->xyz
    resname={}
    for ln in open(path):
        if ln.startswith(('ATOM','HETATM')):
            ch=ln[21]; rn=int(ln[22:26]); at=ln[12:16].strip(); rname=ln[17:20].strip()
            x=float(ln[30:38]); y=float(ln[38:46]); z=float(ln[46:54])
            atoms[(ch,rn,at)]=np.array([x,y,z]); resname[(ch,rn)]=rname
    return atoms, resname

def heavy_atoms_by_res(atoms):
    d={}
    for (ch,rn,at),xyz in atoms.items():
        if at.startswith('H'): continue
        d.setdefault((ch,rn),[]).append(xyz)
    return {k:np.array(v) for k,v in d.items()}

def contacts(pdb, cutoff=4.5):
    """NKG7=chain A, peptide=chain B. Return contact pairs and per-loop tallies."""
    atoms,resname=parse_pdb(pdb)
    byres=heavy_atoms_by_res(atoms)
    A=[(rn,byres[(c,rn)]) for (c,rn) in byres if c=='A']
    B=[(rn,byres[(c,rn)]) for (c,rn) in byres if c=='B']
    pairs=[]  # (nkg7_res, pep_res, mindist)
    nkg7_contact_res=set()
    for arn,acoords in A:
        for brn,bcoords in B:
            d=np.linalg.norm(acoords[:,None,:]-bcoords[None,:,:],axis=2).min()
            if d<=cutoff:
                pairs.append((arn,brn,round(float(d),2)))
                nkg7_contact_res.add(arn)
    n_ecl1=len(nkg7_contact_res&ECL1); n_ecl2=len(nkg7_contact_res&ECL2)
    n_tm=len(nkg7_contact_res&TM)
    n_other=len(nkg7_contact_res)-n_ecl1-n_ecl2-n_tm
    # fraction of interface contacts on each loop
    total=len(nkg7_contact_res) or 1
    return {
      "n_contacts":len(pairs),
      "n_nkg7_contact_res":len(nkg7_contact_res),
      "ecl1_res":sorted(nkg7_contact_res&ECL1),
      "ecl2_res":sorted(nkg7_contact_res&ECL2),
      "tm_res":sorted(nkg7_contact_res&TM),
      "other_res":sorted(nkg7_contact_res-ECL1-ECL2-TM),
      "frac_ecl1":round(n_ecl1/total,3),
      "frac_ecl2":round(n_ecl2/total,3),
      "loop_assignment": ("ECL1" if n_ecl1>n_ecl2 else "ECL2" if n_ecl2>n_ecl1 else ("ECL1+ECL2" if n_ecl1>0 else "non-loop")),
      "pairs":pairs,
    }

def read_conf(js):
    d=json.load(open(js))
    return {k:d.get(k) for k in ["confidence_score","ptm","iptm","complex_plddt","complex_iplddt","complex_pde","complex_ipde"]}
print("analysis module defined")
