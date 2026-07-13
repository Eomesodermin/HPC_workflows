cd /lustre/scratch/data/dcorvino_hpc-thymic_nk_development/work
N=0
rm -rf vdj_TCR_Pan_T7991619
sbatch --job-name=crvdj_TCR_Pan_T7991619 cr_vdj_one.sh TCR_Pan_T7991619 ERR9249455 https://ftp.sra.ebi.ac.uk/vol1/run/ERR924/ERR9249455/TCR_Pan_T7991619_S1_L001_R1_001.fastq.gz https://ftp.sra.ebi.ac.uk/vol1/run/ERR924/ERR9249455/TCR_Pan_T7991619_S1_L001_R2_001.fastq.gz tcr >/dev/null && N=$((N+1))
rm -rf vdj_TCR_Pan_T8010352
sbatch --job-name=crvdj_TCR_Pan_T8010352 cr_vdj_one.sh TCR_Pan_T8010352 ERR9249488 https://ftp.sra.ebi.ac.uk/vol1/run/ERR924/ERR9249488/TCR_Pan_T8010352_S1_L001_R1_001.fastq.gz https://ftp.sra.ebi.ac.uk/vol1/run/ERR924/ERR9249488/TCR_Pan_T8010352_S1_L001_R2_001.fastq.gz tcr >/dev/null && N=$((N+1))
rm -rf vdj_TCR_Pan_T8010353
sbatch --job-name=crvdj_TCR_Pan_T8010353 cr_vdj_one.sh TCR_Pan_T8010353 ERR9249491 https://ftp.sra.ebi.ac.uk/vol1/run/ERR924/ERR9249491/TCR_Pan_T8010353_S1_L001_R1_001.fastq.gz https://ftp.sra.ebi.ac.uk/vol1/run/ERR924/ERR9249491/TCR_Pan_T8010353_S1_L001_R2_001.fastq.gz tcr >/dev/null && N=$((N+1))
rm -rf vdj_TCRgd_Pan_T9475752
sbatch --job-name=crvdj_TCRgd_Pan_T9475752 cr_vdj_one.sh TCRgd_Pan_T9475752 ERR9249492 https://ftp.sra.ebi.ac.uk/vol1/run/ERR924/ERR9249492/TCRgd_Pan_T9475752_S1_L001_R1_001.fastq.gz https://ftp.sra.ebi.ac.uk/vol1/run/ERR924/ERR9249492/TCRgd_Pan_T9475752_S1_L001_R2_001.fastq.gz gd >/dev/null && N=$((N+1))
rm -rf vdj_TCRgd_Pan_T9475757
sbatch --job-name=crvdj_TCRgd_Pan_T9475757 cr_vdj_one.sh TCRgd_Pan_T9475757 ERR9249496 https://ftp.sra.ebi.ac.uk/vol1/run/ERR924/ERR9249496/TCRgd_Pan_T9475757_S1_L001_R1_001.fastq.gz https://ftp.sra.ebi.ac.uk/vol1/run/ERR924/ERR9249496/TCRgd_Pan_T9475757_S1_L001_R2_001.fastq.gz gd >/dev/null && N=$((N+1))
rm -rf vdj_TCR_Pan_T8010357
sbatch --job-name=crvdj_TCR_Pan_T8010357 cr_vdj_one.sh TCR_Pan_T8010357 ERR9249499 https://ftp.sra.ebi.ac.uk/vol1/run/ERR924/ERR9249499/TCR_Pan_T8010357_S1_L001_R1_001.fastq.gz https://ftp.sra.ebi.ac.uk/vol1/run/ERR924/ERR9249499/TCR_Pan_T8010357_S1_L001_R2_001.fastq.gz tcr >/dev/null && N=$((N+1))
rm -rf vdj_TCR_Pan_T7935498
sbatch --job-name=crvdj_TCR_Pan_T7935498 cr_vdj_one.sh TCR_Pan_T7935498 ERR9249502 https://ftp.sra.ebi.ac.uk/vol1/run/ERR924/ERR9249502/TCR_Pan_T7935498_S1_L001_R1_001.fastq.gz https://ftp.sra.ebi.ac.uk/vol1/run/ERR924/ERR9249502/TCR_Pan_T7935498_S1_L001_R2_001.fastq.gz tcr >/dev/null && N=$((N+1))
rm -rf vdj_TCR_Pan_T7935499
sbatch --job-name=crvdj_TCR_Pan_T7935499 cr_vdj_one.sh TCR_Pan_T7935499 ERR9249505 https://ftp.sra.ebi.ac.uk/vol1/run/ERR924/ERR9249505/TCR_Pan_T7935499_S1_L001_R1_001.fastq.gz https://ftp.sra.ebi.ac.uk/vol1/run/ERR924/ERR9249505/TCR_Pan_T7935499_S1_L001_R2_001.fastq.gz tcr >/dev/null && N=$((N+1))
rm -rf vdj_TCR_Pan_T7935500
sbatch --job-name=crvdj_TCR_Pan_T7935500 cr_vdj_one.sh TCR_Pan_T7935500 ERR9249508 https://ftp.sra.ebi.ac.uk/vol1/run/ERR924/ERR9249508/TCR_Pan_T7935500_S1_L001_R1_001.fastq.gz https://ftp.sra.ebi.ac.uk/vol1/run/ERR924/ERR9249508/TCR_Pan_T7935500_S1_L001_R2_001.fastq.gz tcr >/dev/null && N=$((N+1))
rm -rf vdj_TCR_CZI-IA10244332
sbatch --job-name=crvdj_TCR_CZI-IA10244332 cr_vdj_one.sh TCR_CZI-IA10244332 ERR9249700 https://ftp.sra.ebi.ac.uk/vol1/run/ERR924/ERR9249700/TCR_CZI-IA10244332_S1_L001_R1_001.fastq.gz https://ftp.sra.ebi.ac.uk/vol1/run/ERR924/ERR9249700/TCR_CZI-IA10244332_S1_L001_R2_001.fastq.gz tcr >/dev/null && N=$((N+1))
rm -rf vdj_TCR_CZI-IA10466281
sbatch --job-name=crvdj_TCR_CZI-IA10466281 cr_vdj_one.sh TCR_CZI-IA10466281 ERR9249708 https://ftp.sra.ebi.ac.uk/vol1/run/ERR924/ERR9249708/TCR_CZI-IA10466281_S1_L001_R1_001.fastq.gz https://ftp.sra.ebi.ac.uk/vol1/run/ERR924/ERR9249708/TCR_CZI-IA10466281_S1_L001_R2_001.fastq.gz tcr >/dev/null && N=$((N+1))
rm -rf vdj_TCR_CZI-IA10471909
sbatch --job-name=crvdj_TCR_CZI-IA10471909 cr_vdj_one.sh TCR_CZI-IA10471909 ERR9249732 https://ftp.sra.ebi.ac.uk/vol1/run/ERR924/ERR9249732/TCR_CZI-IA10471909_S1_L001_R1_001.fastq.gz https://ftp.sra.ebi.ac.uk/vol1/run/ERR924/ERR9249732/TCR_CZI-IA10471909_S1_L001_R2_001.fastq.gz tcr >/dev/null && N=$((N+1))
rm -rf vdj_TCR_CZI-IA10471910
sbatch --job-name=crvdj_TCR_CZI-IA10471910 cr_vdj_one.sh TCR_CZI-IA10471910 ERR9249736 https://ftp.sra.ebi.ac.uk/vol1/run/ERR924/ERR9249736/TCR_CZI-IA10471910_S1_L001_R1_001.fastq.gz https://ftp.sra.ebi.ac.uk/vol1/run/ERR924/ERR9249736/TCR_CZI-IA10471910_S1_L001_R2_001.fastq.gz tcr >/dev/null && N=$((N+1))
rm -rf vdj_TCR_CZI-IA10466284
sbatch --job-name=crvdj_TCR_CZI-IA10466284 cr_vdj_one.sh TCR_CZI-IA10466284 ERR9249720 https://ftp.sra.ebi.ac.uk/vol1/run/ERR924/ERR9249720/TCR_CZI-IA10466284_S1_L001_R1_001.fastq.gz https://ftp.sra.ebi.ac.uk/vol1/run/ERR924/ERR9249720/TCR_CZI-IA10466284_S1_L001_R2_001.fastq.gz tcr >/dev/null && N=$((N+1))
rm -rf vdj_TCR_CZI-IA10471912
sbatch --job-name=crvdj_TCR_CZI-IA10471912 cr_vdj_one.sh TCR_CZI-IA10471912 ERR9249744 https://ftp.sra.ebi.ac.uk/vol1/run/ERR924/ERR9249744/TCR_CZI-IA10471912_S1_L001_R1_001.fastq.gz https://ftp.sra.ebi.ac.uk/vol1/run/ERR924/ERR9249744/TCR_CZI-IA10471912_S1_L001_R2_001.fastq.gz tcr >/dev/null && N=$((N+1))
echo "resubmitted $N"
