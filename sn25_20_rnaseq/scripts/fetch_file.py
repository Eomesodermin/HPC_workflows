#!/usr/bin/env python3
"""Reliable file transfer off a congested SLURM login node via md5-verified
base64 chunks through call_command.

marvin's compute download() helper can stall for minutes on multi-MB files when
the login node is congested. This fetches via small base64 chunks (the
call_command stdout cap is ~64 KB, so use 45 KB pieces) and verifies the whole
file's md5 before writing. Use from the `repl` tool (host.compute available there).

    from fetch_file import fetch_file
    c = host.compute.create("ssh:marvin")
    n, md5 = fetch_file(c, "/lustre/.../multiqc_raw.html", "deliverables/multiqc_raw.html")

For a large deliverable also consider chaining it into the next job via
inputs=[{remote_path: ...}] instead of pulling it local at all.
"""
import base64, os, re, hashlib

def fetch_file(c, remote, local, chunk=45000):
    """Copy `remote` (absolute path on host) to `local`. Returns (nbytes, md5)
    on success; raises RuntimeError on md5 mismatch. `c` is a host.compute
    instance (host.compute.create(...))."""
    md5_exp = c.call_command(f"md5sum {remote}|cut -d' ' -f1",
                             intent="md5").get("stdout", "").strip()
    c.call_command(
        f"cd /tmp; rm -f _ch_*; base64 -w0 {remote} > _f.b64; "
        f"split -b {chunk} -d -a 4 _f.b64 _ch_; ls _ch_*|wc -l",
        intent="split")
    listing = c.call_command("cd /tmp; ls _ch_*", intent="list").get("stdout", "")
    chunks = sorted(listing.strip().split("\n"))
    data = ""
    for name in chunks:
        o = c.call_command(f"cat /tmp/{name}", intent="chunk")
        data += re.sub(r"[^A-Za-z0-9+/=]", "", o.get("stdout", ""))
    raw = base64.b64decode(data)
    md5_got = hashlib.md5(raw).hexdigest()
    if md5_got != md5_exp:
        raise RuntimeError(f"md5 mismatch for {remote}: {md5_got} != {md5_exp}")
    os.makedirs(os.path.dirname(local) or ".", exist_ok=True)
    with open(local, "wb") as f:
        f.write(raw)
    c.call_command("rm -f /tmp/_ch_* /tmp/_f.b64", intent="cleanup")
    return len(raw), md5_got
