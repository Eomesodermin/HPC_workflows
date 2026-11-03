# Environments

Declarative conda specs, recreated on the cluster with `conda env create -f <file> -n <name>` inside
a compute job (never on a login node). Use Miniforge and conda-forge only: the default Anaconda
channels are not permitted on Marvin.

| File | Purpose |
|------|---------|
| `dandelion_env.yml` | sc-dandelion for re-annotating 10x V(D)J data while retaining non-productive contigs; the IgBLAST/IMGT references it needs are described inside the file |

The environments used by the protein-design campaigns (RFdiffusion, Boltz-2, Chai-1, OpenMM) are
pinned in the `envs/` directory of
[`nkg7-binder-design`](https://github.com/Eomesodermin/nkg7-binder-design/tree/main/envs).
