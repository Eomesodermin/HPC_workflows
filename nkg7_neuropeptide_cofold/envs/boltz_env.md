# boltz conda env (marvin) — key packages

Python 3.11.15. Created as: `conda create -n boltz python=3.11 pip; pip install boltz`
(generic AVX2-safe wheels — required because marvin mlgpu nodes are AMD, no AVX-512).

```
boltz==2.2.1
torch==2.13.0          # CUDA 13 wheels
pytorch-lightning==2.5.0
torchmetrics==1.9.0
numpy==1.26.4
rdkit==2026.3.3
```

Weights cached in ~/.boltz: boltz2_conf.ckpt (structure, 2.2G), boltz2_aff.ckpt (affinity head, ~2.0G).
NB: boltz2_aff.ckpt required re-download once (initial copy was corrupt).

Run: `boltz predict complex.yaml --out_dir OUT --recycling_steps 3 --diffusion_samples 5 --no_kernels --output_format pdb`
