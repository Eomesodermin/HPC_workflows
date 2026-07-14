
from pymol import cmd
import json, sys
detail = json.load(open("handoff/contacts_detail.json"))
order = ["MCH","PDYN","TKN4","VGF","SCG2","GALP","PROK2","CTRL"]
cmd.set("ray_opaque_background", 0)
cmd.set("cartoon_transparency", 0.0)
cmd.set("ray_shadows", 0)
cmd.set("antialias", 2)
cmd.set("cartoon_fancy_helices", 1)
cmd.bg_color("white")
for pid in order:
    cmd.delete("all")
    cmd.load(f"structures/NKG7_{pid}.pdb", "cx")
    cmd.hide("everything")
    cmd.show("cartoon", "cx")
    # NKG7 = chain A
    cmd.color("grey80", "cx and chain A")
    cmd.color("orange",  "cx and chain A and resi 30-60")    # ECL1
    cmd.color("teal",    "cx and chain A and resi 113-132")  # ECL2
    cmd.color("grey50",  "cx and chain A and (resi 9-29 or resi 61-81 or resi 92-112 or resi 133-153)")  # TM
    # peptide = chain B
    cmd.color("magenta", "cx and chain B")
    cmd.show("sticks", "cx and chain B and not (name C+N+O)")
    cmd.set("stick_radius", 0.15, "cx and chain B")
    # contact residues on NKG7 -> sticks
    d = detail[pid]
    cres = d["ecl1_res"] + d["ecl2_res"]
    if cres:
        sel = "cx and chain A and resi " + "+".join(str(r) for r in cres)
        cmd.show("sticks", sel + " and not (name C+N+O)")
        cmd.set("stick_radius", 0.12, sel)
    cmd.orient("cx and chain B")
    cmd.zoom("cx and chain B", 8)
    cmd.turn("y", 20)
    cmd.set("ray_trace_mode", 0)
    cmd.ray(1100, 950)
    cmd.png(f"figures/complex_{pid}.png", dpi=200)
    print("rendered", pid)
