cd /lustre/scratch/data/dcorvino_hpc-thymic_nk_development/work
N=0
rm -rf vdj_TCR_Pan_T7935503
sbatch --job-name=crvdj_TCR_Pan_T7935503 cr_vdj_one.sh TCR_Pan_T7935503 ERR9249344 https://ftp.sra.ebi.ac.uk/vol1/run/ERR924/ERR9249344/TCR_Pan_T7935503_S1_L001_R1_001.fastq.gz https://ftp.sra.ebi.ac.uk/vol1/run/ERR924/ERR9249344/TCR_Pan_T7935503_S1_L001_R2_001.fastq.gz tcr >/dev/null && N=$((N+1))
rm -rf vdj_TCRgd_Pan_T9475745
sbatch --job-name=crvdj_TCRgd_Pan_T9475745 cr_vdj_one.sh TCRgd_Pan_T9475745 ERR9249359 https://ftp.sra.ebi.ac.uk/vol1/run/ERR924/ERR9249359/TCRgd_Pan_T9475745_S1_L001_R1_001.fastq.gz https://ftp.sra.ebi.ac.uk/vol1/run/ERR924/ERR9249359/TCRgd_Pan_T9475745_S1_L001_R2_001.fastq.gz gd >/dev/null && N=$((N+1))
rm -rf vdj_TCRgd_Pan_T9475755
sbatch --job-name=crvdj_TCRgd_Pan_T9475755 cr_vdj_one.sh TCRgd_Pan_T9475755 ERR9249363 https://ftp.sra.ebi.ac.uk/vol1/run/ERR924/ERR9249363/TCRgd_Pan_T9475755_S1_L001_R1_001.fastq.gz https://ftp.sra.ebi.ac.uk/vol1/run/ERR924/ERR9249363/TCRgd_Pan_T9475755_S1_L001_R2_001.fastq.gz gd >/dev/null && N=$((N+1))
rm -rf vdj_TCRgd_Pan_T9475753
sbatch --job-name=crvdj_TCRgd_Pan_T9475753 cr_vdj_one.sh TCRgd_Pan_T9475753 ERR9249367 https://ftp.sra.ebi.ac.uk/vol1/run/ERR924/ERR9249367/TCRgd_Pan_T9475753_S1_L001_R1_001.fastq.gz https://ftp.sra.ebi.ac.uk/vol1/run/ERR924/ERR9249367/TCRgd_Pan_T9475753_S1_L001_R2_001.fastq.gz gd >/dev/null && N=$((N+1))
rm -rf vdj_TCRgd_Pan_T9475747
sbatch --job-name=crvdj_TCRgd_Pan_T9475747 cr_vdj_one.sh TCRgd_Pan_T9475747 ERR9249380 https://ftp.sra.ebi.ac.uk/vol1/run/ERR924/ERR9249380/TCRgd_Pan_T9475747_S1_L001_R1_001.fastq.gz https://ftp.sra.ebi.ac.uk/vol1/run/ERR924/ERR9249380/TCRgd_Pan_T9475747_S1_L001_R2_001.fastq.gz gd >/dev/null && N=$((N+1))
rm -rf vdj_TCRgd_Pan_T9475746
sbatch --job-name=crvdj_TCRgd_Pan_T9475746 cr_vdj_one.sh TCRgd_Pan_T9475746 ERR9249390 https://ftp.sra.ebi.ac.uk/vol1/run/ERR924/ERR9249390/TCRgd_Pan_T9475746_S1_L001_R1_001.fastq.gz https://ftp.sra.ebi.ac.uk/vol1/run/ERR924/ERR9249390/TCRgd_Pan_T9475746_S1_L001_R2_001.fastq.gz gd >/dev/null && N=$((N+1))
rm -rf vdj_TCR_Pan_T7918900
sbatch --job-name=crvdj_TCR_Pan_T7918900 cr_vdj_one.sh TCR_Pan_T7918900 ERR9249399 https://ftp.sra.ebi.ac.uk/vol1/run/ERR924/ERR9249399/TCR_Pan_T7918900_S1_L001_R1_001.fastq.gz https://ftp.sra.ebi.ac.uk/vol1/run/ERR924/ERR9249399/TCR_Pan_T7918900_S1_L001_R2_001.fastq.gz tcr >/dev/null && N=$((N+1))
rm -rf vdj_TCR_Pan_T7980372
sbatch --job-name=crvdj_TCR_Pan_T7980372 cr_vdj_one.sh TCR_Pan_T7980372 ERR9249408 https://ftp.sra.ebi.ac.uk/vol1/run/ERR924/ERR9249408/TCR_Pan_T7980372_S1_L001_R1_001.fastq.gz https://ftp.sra.ebi.ac.uk/vol1/run/ERR924/ERR9249408/TCR_Pan_T7980372_S1_L001_R2_001.fastq.gz tcr >/dev/null && N=$((N+1))
rm -rf vdj_TCRgd_Pan_T9475751
sbatch --job-name=crvdj_TCRgd_Pan_T9475751 cr_vdj_one.sh TCRgd_Pan_T9475751 ERR9249409 https://ftp.sra.ebi.ac.uk/vol1/run/ERR924/ERR9249409/TCRgd_Pan_T9475751_S1_L001_R1_001.fastq.gz https://ftp.sra.ebi.ac.uk/vol1/run/ERR924/ERR9249409/TCRgd_Pan_T9475751_S1_L001_R2_001.fastq.gz gd >/dev/null && N=$((N+1))
rm -rf vdj_TCR_Pan_T7980373
sbatch --job-name=crvdj_TCR_Pan_T7980373 cr_vdj_one.sh TCR_Pan_T7980373 ERR9249412 https://ftp.sra.ebi.ac.uk/vol1/run/ERR924/ERR9249412/TCR_Pan_T7980373_S1_L001_R1_001.fastq.gz https://ftp.sra.ebi.ac.uk/vol1/run/ERR924/ERR9249412/TCR_Pan_T7980373_S1_L001_R2_001.fastq.gz tcr >/dev/null && N=$((N+1))
rm -rf vdj_TCRgd_Pan_T9475750
sbatch --job-name=crvdj_TCRgd_Pan_T9475750 cr_vdj_one.sh TCRgd_Pan_T9475750 ERR9249413 https://ftp.sra.ebi.ac.uk/vol1/run/ERR924/ERR9249413/TCRgd_Pan_T9475750_S1_L001_R1_001.fastq.gz https://ftp.sra.ebi.ac.uk/vol1/run/ERR924/ERR9249413/TCRgd_Pan_T9475750_S1_L001_R2_001.fastq.gz gd >/dev/null && N=$((N+1))
rm -rf vdj_TCR_Pan_T7980374
sbatch --job-name=crvdj_TCR_Pan_T7980374 cr_vdj_one.sh TCR_Pan_T7980374 ERR9249416 https://ftp.sra.ebi.ac.uk/vol1/run/ERR924/ERR9249416/TCR_Pan_T7980374_S1_L001_R1_001.fastq.gz https://ftp.sra.ebi.ac.uk/vol1/run/ERR924/ERR9249416/TCR_Pan_T7980374_S1_L001_R2_001.fastq.gz tcr >/dev/null && N=$((N+1))
rm -rf vdj_TCR_Pan_T7980377
sbatch --job-name=crvdj_TCR_Pan_T7980377 cr_vdj_one.sh TCR_Pan_T7980377 ERR9249419 https://ftp.sra.ebi.ac.uk/vol1/run/ERR924/ERR9249419/TCR_Pan_T7980377_S1_L001_R1_001.fastq.gz https://ftp.sra.ebi.ac.uk/vol1/run/ERR924/ERR9249419/TCR_Pan_T7980377_S1_L001_R2_001.fastq.gz tcr >/dev/null && N=$((N+1))
rm -rf vdj_TCRgd_Pan_T9475754
sbatch --job-name=crvdj_TCRgd_Pan_T9475754 cr_vdj_one.sh TCRgd_Pan_T9475754 ERR9249420 https://ftp.sra.ebi.ac.uk/vol1/run/ERR924/ERR9249420/TCRgd_Pan_T9475754_S1_L001_R1_001.fastq.gz https://ftp.sra.ebi.ac.uk/vol1/run/ERR924/ERR9249420/TCRgd_Pan_T9475754_S1_L001_R2_001.fastq.gz gd >/dev/null && N=$((N+1))
rm -rf vdj_TCR_Pan_T7980378
sbatch --job-name=crvdj_TCR_Pan_T7980378 cr_vdj_one.sh TCR_Pan_T7980378 ERR9249423 https://ftp.sra.ebi.ac.uk/vol1/run/ERR924/ERR9249423/TCR_Pan_T7980378_S1_L001_R1_001.fastq.gz https://ftp.sra.ebi.ac.uk/vol1/run/ERR924/ERR9249423/TCR_Pan_T7980378_S1_L001_R2_001.fastq.gz tcr >/dev/null && N=$((N+1))
rm -rf vdj_TCR_Pan_T7980379
sbatch --job-name=crvdj_TCR_Pan_T7980379 cr_vdj_one.sh TCR_Pan_T7980379 ERR9249426 https://ftp.sra.ebi.ac.uk/vol1/run/ERR924/ERR9249426/TCR_Pan_T7980379_S1_L001_R1_001.fastq.gz https://ftp.sra.ebi.ac.uk/vol1/run/ERR924/ERR9249426/TCR_Pan_T7980379_S1_L001_R2_001.fastq.gz tcr >/dev/null && N=$((N+1))
rm -rf vdj_TCR_Pan_T7980381
sbatch --job-name=crvdj_TCR_Pan_T7980381 cr_vdj_one.sh TCR_Pan_T7980381 ERR9249430 https://ftp.sra.ebi.ac.uk/vol1/run/ERR924/ERR9249430/TCR_Pan_T7980381_S1_L001_R1_001.fastq.gz https://ftp.sra.ebi.ac.uk/vol1/run/ERR924/ERR9249430/TCR_Pan_T7980381_S1_L001_R2_001.fastq.gz tcr >/dev/null && N=$((N+1))
rm -rf vdj_TCR_Pan_T7980383
sbatch --job-name=crvdj_TCR_Pan_T7980383 cr_vdj_one.sh TCR_Pan_T7980383 ERR9249434 https://ftp.sra.ebi.ac.uk/vol1/run/ERR924/ERR9249434/TCR_Pan_T7980383_S1_L001_R1_001.fastq.gz https://ftp.sra.ebi.ac.uk/vol1/run/ERR924/ERR9249434/TCR_Pan_T7980383_S1_L001_R2_001.fastq.gz tcr >/dev/null && N=$((N+1))
rm -rf vdj_TCR_Pan_T7991613
sbatch --job-name=crvdj_TCR_Pan_T7991613 cr_vdj_one.sh TCR_Pan_T7991613 ERR9249437 https://ftp.sra.ebi.ac.uk/vol1/run/ERR924/ERR9249437/TCR_Pan_T7991613_S1_L001_R1_001.fastq.gz https://ftp.sra.ebi.ac.uk/vol1/run/ERR924/ERR9249437/TCR_Pan_T7991613_S1_L001_R2_001.fastq.gz tcr >/dev/null && N=$((N+1))
rm -rf vdj_TCR_Pan_T7991614
sbatch --job-name=crvdj_TCR_Pan_T7991614 cr_vdj_one.sh TCR_Pan_T7991614 ERR9249440 https://ftp.sra.ebi.ac.uk/vol1/run/ERR924/ERR9249440/TCR_Pan_T7991614_S1_L001_R1_001.fastq.gz https://ftp.sra.ebi.ac.uk/vol1/run/ERR924/ERR9249440/TCR_Pan_T7991614_S1_L001_R2_001.fastq.gz tcr >/dev/null && N=$((N+1))
rm -rf vdj_TCR_Pan_T7991615
sbatch --job-name=crvdj_TCR_Pan_T7991615 cr_vdj_one.sh TCR_Pan_T7991615 ERR9249443 https://ftp.sra.ebi.ac.uk/vol1/run/ERR924/ERR9249443/TCR_Pan_T7991615_S1_L001_R1_001.fastq.gz https://ftp.sra.ebi.ac.uk/vol1/run/ERR924/ERR9249443/TCR_Pan_T7991615_S1_L001_R2_001.fastq.gz tcr >/dev/null && N=$((N+1))
rm -rf vdj_TCR_Pan_T7991616
sbatch --job-name=crvdj_TCR_Pan_T7991616 cr_vdj_one.sh TCR_Pan_T7991616 ERR9249446 https://ftp.sra.ebi.ac.uk/vol1/run/ERR924/ERR9249446/TCR_Pan_T7991616_S1_L001_R1_001.fastq.gz https://ftp.sra.ebi.ac.uk/vol1/run/ERR924/ERR9249446/TCR_Pan_T7991616_S1_L001_R2_001.fastq.gz tcr >/dev/null && N=$((N+1))
rm -rf vdj_TCR_Pan_T7991617
sbatch --job-name=crvdj_TCR_Pan_T7991617 cr_vdj_one.sh TCR_Pan_T7991617 ERR9249449 https://ftp.sra.ebi.ac.uk/vol1/run/ERR924/ERR9249449/TCR_Pan_T7991617_S1_L001_R1_001.fastq.gz https://ftp.sra.ebi.ac.uk/vol1/run/ERR924/ERR9249449/TCR_Pan_T7991617_S1_L001_R2_001.fastq.gz tcr >/dev/null && N=$((N+1))
rm -rf vdj_TCR_Pan_T7991618
sbatch --job-name=crvdj_TCR_Pan_T7991618 cr_vdj_one.sh TCR_Pan_T7991618 ERR9249452 https://ftp.sra.ebi.ac.uk/vol1/run/ERR924/ERR9249452/TCR_Pan_T7991618_S1_L001_R1_001.fastq.gz https://ftp.sra.ebi.ac.uk/vol1/run/ERR924/ERR9249452/TCR_Pan_T7991618_S1_L001_R2_001.fastq.gz tcr >/dev/null && N=$((N+1))
rm -rf vdj_TCR_Pan_T7991619
sbatch --job-name=crvdj_TCR_Pan_T7991619 cr_vdj_one.sh TCR_Pan_T7991619 ERR9249455 https://ftp.sra.ebi.ac.uk/vol1/run/ERR924/ERR9249455/TCR_Pan_T7991619_S1_L001_R1_001.fastq.gz https://ftp.sra.ebi.ac.uk/vol1/run/ERR924/ERR9249455/TCR_Pan_T7991619_S1_L001_R2_001.fastq.gz tcr >/dev/null && N=$((N+1))
rm -rf vdj_TCRgd_Pan_T9475748
sbatch --job-name=crvdj_TCRgd_Pan_T9475748 cr_vdj_one.sh TCRgd_Pan_T9475748 ERR9249456 https://ftp.sra.ebi.ac.uk/vol1/run/ERR924/ERR9249456/TCRgd_Pan_T9475748_S1_L001_R1_001.fastq.gz https://ftp.sra.ebi.ac.uk/vol1/run/ERR924/ERR9249456/TCRgd_Pan_T9475748_S1_L001_R2_001.fastq.gz gd >/dev/null && N=$((N+1))
rm -rf vdj_TCR_Pan_T7991620
sbatch --job-name=crvdj_TCR_Pan_T7991620 cr_vdj_one.sh TCR_Pan_T7991620 ERR9249459 https://ftp.sra.ebi.ac.uk/vol1/run/ERR924/ERR9249459/TCR_Pan_T7991620_S1_L001_R1_001.fastq.gz https://ftp.sra.ebi.ac.uk/vol1/run/ERR924/ERR9249459/TCR_Pan_T7991620_S1_L001_R2_001.fastq.gz tcr >/dev/null && N=$((N+1))
rm -rf vdj_TCRgd_Pan_T9475756
sbatch --job-name=crvdj_TCRgd_Pan_T9475756 cr_vdj_one.sh TCRgd_Pan_T9475756 ERR9249460 https://ftp.sra.ebi.ac.uk/vol1/run/ERR924/ERR9249460/TCRgd_Pan_T9475756_S1_L001_R1_001.fastq.gz https://ftp.sra.ebi.ac.uk/vol1/run/ERR924/ERR9249460/TCRgd_Pan_T9475756_S1_L001_R2_001.fastq.gz gd >/dev/null && N=$((N+1))
rm -rf vdj_TCR_Pan_T7991622
sbatch --job-name=crvdj_TCR_Pan_T7991622 cr_vdj_one.sh TCR_Pan_T7991622 ERR9249464 https://ftp.sra.ebi.ac.uk/vol1/run/ERR924/ERR9249464/TCR_Pan_T7991622_S1_L001_R1_001.fastq.gz https://ftp.sra.ebi.ac.uk/vol1/run/ERR924/ERR9249464/TCR_Pan_T7991622_S1_L001_R2_001.fastq.gz tcr >/dev/null && N=$((N+1))
rm -rf vdj_TCRgd_Pan_T9475749
sbatch --job-name=crvdj_TCRgd_Pan_T9475749 cr_vdj_one.sh TCRgd_Pan_T9475749 ERR9249465 https://ftp.sra.ebi.ac.uk/vol1/run/ERR924/ERR9249465/TCRgd_Pan_T9475749_S1_L001_R1_001.fastq.gz https://ftp.sra.ebi.ac.uk/vol1/run/ERR924/ERR9249465/TCRgd_Pan_T9475749_S1_L001_R2_001.fastq.gz gd >/dev/null && N=$((N+1))
rm -rf vdj_TCR_Pan_T7991623
sbatch --job-name=crvdj_TCR_Pan_T7991623 cr_vdj_one.sh TCR_Pan_T7991623 ERR9249468 https://ftp.sra.ebi.ac.uk/vol1/run/ERR924/ERR9249468/TCR_Pan_T7991623_S1_L001_R1_001.fastq.gz https://ftp.sra.ebi.ac.uk/vol1/run/ERR924/ERR9249468/TCR_Pan_T7991623_S1_L001_R2_001.fastq.gz tcr >/dev/null && N=$((N+1))
rm -rf vdj_TCR_Pan_T7991624
sbatch --job-name=crvdj_TCR_Pan_T7991624 cr_vdj_one.sh TCR_Pan_T7991624 ERR9249471 https://ftp.sra.ebi.ac.uk/vol1/run/ERR924/ERR9249471/TCR_Pan_T7991624_S1_L001_R1_001.fastq.gz https://ftp.sra.ebi.ac.uk/vol1/run/ERR924/ERR9249471/TCR_Pan_T7991624_S1_L001_R2_001.fastq.gz tcr >/dev/null && N=$((N+1))
rm -rf vdj_TCR_Pan_T8010345
sbatch --job-name=crvdj_TCR_Pan_T8010345 cr_vdj_one.sh TCR_Pan_T8010345 ERR9249474 https://ftp.sra.ebi.ac.uk/vol1/run/ERR924/ERR9249474/TCR_Pan_T8010345_S1_L001_R1_001.fastq.gz https://ftp.sra.ebi.ac.uk/vol1/run/ERR924/ERR9249474/TCR_Pan_T8010345_S1_L001_R2_001.fastq.gz tcr >/dev/null && N=$((N+1))
rm -rf vdj_TCR_Pan_T8010347
sbatch --job-name=crvdj_TCR_Pan_T8010347 cr_vdj_one.sh TCR_Pan_T8010347 ERR9249478 https://ftp.sra.ebi.ac.uk/vol1/run/ERR924/ERR9249478/TCR_Pan_T8010347_S1_L001_R1_001.fastq.gz https://ftp.sra.ebi.ac.uk/vol1/run/ERR924/ERR9249478/TCR_Pan_T8010347_S1_L001_R2_001.fastq.gz tcr >/dev/null && N=$((N+1))
rm -rf vdj_TCR_Pan_T8010348
sbatch --job-name=crvdj_TCR_Pan_T8010348 cr_vdj_one.sh TCR_Pan_T8010348 ERR9249481 https://ftp.sra.ebi.ac.uk/vol1/run/ERR924/ERR9249481/TCR_Pan_T8010348_S1_L001_R1_001.fastq.gz https://ftp.sra.ebi.ac.uk/vol1/run/ERR924/ERR9249481/TCR_Pan_T8010348_S1_L001_R2_001.fastq.gz tcr >/dev/null && N=$((N+1))
rm -rf vdj_TCR_Pan_T8010351
sbatch --job-name=crvdj_TCR_Pan_T8010351 cr_vdj_one.sh TCR_Pan_T8010351 ERR9249485 https://ftp.sra.ebi.ac.uk/vol1/run/ERR924/ERR9249485/TCR_Pan_T8010351_S1_L001_R1_001.fastq.gz https://ftp.sra.ebi.ac.uk/vol1/run/ERR924/ERR9249485/TCR_Pan_T8010351_S1_L001_R2_001.fastq.gz tcr >/dev/null && N=$((N+1))
rm -rf vdj_TCR_Pan_T8010352
sbatch --job-name=crvdj_TCR_Pan_T8010352 cr_vdj_one.sh TCR_Pan_T8010352 ERR9249488 https://ftp.sra.ebi.ac.uk/vol1/run/ERR924/ERR9249488/TCR_Pan_T8010352_S1_L001_R1_001.fastq.gz https://ftp.sra.ebi.ac.uk/vol1/run/ERR924/ERR9249488/TCR_Pan_T8010352_S1_L001_R2_001.fastq.gz tcr >/dev/null && N=$((N+1))
rm -rf vdj_TCR_Pan_T8010353
sbatch --job-name=crvdj_TCR_Pan_T8010353 cr_vdj_one.sh TCR_Pan_T8010353 ERR9249491 https://ftp.sra.ebi.ac.uk/vol1/run/ERR924/ERR9249491/TCR_Pan_T8010353_S1_L001_R1_001.fastq.gz https://ftp.sra.ebi.ac.uk/vol1/run/ERR924/ERR9249491/TCR_Pan_T8010353_S1_L001_R2_001.fastq.gz tcr >/dev/null && N=$((N+1))
rm -rf vdj_TCRgd_Pan_T9475752
sbatch --job-name=crvdj_TCRgd_Pan_T9475752 cr_vdj_one.sh TCRgd_Pan_T9475752 ERR9249492 https://ftp.sra.ebi.ac.uk/vol1/run/ERR924/ERR9249492/TCRgd_Pan_T9475752_S1_L001_R1_001.fastq.gz https://ftp.sra.ebi.ac.uk/vol1/run/ERR924/ERR9249492/TCRgd_Pan_T9475752_S1_L001_R2_001.fastq.gz gd >/dev/null && N=$((N+1))
rm -rf vdj_TCR_Pan_T8010356
sbatch --job-name=crvdj_TCR_Pan_T8010356 cr_vdj_one.sh TCR_Pan_T8010356 ERR9249495 https://ftp.sra.ebi.ac.uk/vol1/run/ERR924/ERR9249495/TCR_Pan_T8010356_S1_L001_R1_001.fastq.gz https://ftp.sra.ebi.ac.uk/vol1/run/ERR924/ERR9249495/TCR_Pan_T8010356_S1_L001_R2_001.fastq.gz tcr >/dev/null && N=$((N+1))
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
rm -rf vdj_TCR_CZI-IA10244331
sbatch --job-name=crvdj_TCR_CZI-IA10244331 cr_vdj_one.sh TCR_CZI-IA10244331 ERR9249704 https://ftp.sra.ebi.ac.uk/vol1/run/ERR924/ERR9249704/TCR_CZI-IA10244331_S1_L001_R1_001.fastq.gz https://ftp.sra.ebi.ac.uk/vol1/run/ERR924/ERR9249704/TCR_CZI-IA10244331_S1_L001_R2_001.fastq.gz tcr >/dev/null && N=$((N+1))
rm -rf vdj_TCR_CZI-IA10466282
sbatch --job-name=crvdj_TCR_CZI-IA10466282 cr_vdj_one.sh TCR_CZI-IA10466282 ERR9249712 https://ftp.sra.ebi.ac.uk/vol1/run/ERR924/ERR9249712/TCR_CZI-IA10466282_S1_L001_R1_001.fastq.gz https://ftp.sra.ebi.ac.uk/vol1/run/ERR924/ERR9249712/TCR_CZI-IA10466282_S1_L001_R2_001.fastq.gz tcr >/dev/null && N=$((N+1))
rm -rf vdj_TCR_CZI-IA10471910
sbatch --job-name=crvdj_TCR_CZI-IA10471910 cr_vdj_one.sh TCR_CZI-IA10471910 ERR9249736 https://ftp.sra.ebi.ac.uk/vol1/run/ERR924/ERR9249736/TCR_CZI-IA10471910_S1_L001_R1_001.fastq.gz https://ftp.sra.ebi.ac.uk/vol1/run/ERR924/ERR9249736/TCR_CZI-IA10471910_S1_L001_R2_001.fastq.gz tcr >/dev/null && N=$((N+1))
rm -rf vdj_TCR_CZI-IA10466283
sbatch --job-name=crvdj_TCR_CZI-IA10466283 cr_vdj_one.sh TCR_CZI-IA10466283 ERR9249716 https://ftp.sra.ebi.ac.uk/vol1/run/ERR924/ERR9249716/TCR_CZI-IA10466283_S1_L001_R1_001.fastq.gz https://ftp.sra.ebi.ac.uk/vol1/run/ERR924/ERR9249716/TCR_CZI-IA10466283_S1_L001_R2_001.fastq.gz tcr >/dev/null && N=$((N+1))
rm -rf vdj_TCR_CZI-IA10466284
sbatch --job-name=crvdj_TCR_CZI-IA10466284 cr_vdj_one.sh TCR_CZI-IA10466284 ERR9249720 https://ftp.sra.ebi.ac.uk/vol1/run/ERR924/ERR9249720/TCR_CZI-IA10466284_S1_L001_R1_001.fastq.gz https://ftp.sra.ebi.ac.uk/vol1/run/ERR924/ERR9249720/TCR_CZI-IA10466284_S1_L001_R2_001.fastq.gz tcr >/dev/null && N=$((N+1))
rm -rf vdj_TCR_CZI-IA10471912
sbatch --job-name=crvdj_TCR_CZI-IA10471912 cr_vdj_one.sh TCR_CZI-IA10471912 ERR9249744 https://ftp.sra.ebi.ac.uk/vol1/run/ERR924/ERR9249744/TCR_CZI-IA10471912_S1_L001_R1_001.fastq.gz https://ftp.sra.ebi.ac.uk/vol1/run/ERR924/ERR9249744/TCR_CZI-IA10471912_S1_L001_R2_001.fastq.gz tcr >/dev/null && N=$((N+1))
rm -rf vdj_TCR_CZI-IA10466285
sbatch --job-name=crvdj_TCR_CZI-IA10466285 cr_vdj_one.sh TCR_CZI-IA10466285 ERR9249724 https://ftp.sra.ebi.ac.uk/vol1/run/ERR924/ERR9249724/TCR_CZI-IA10466285_S1_L001_R1_001.fastq.gz https://ftp.sra.ebi.ac.uk/vol1/run/ERR924/ERR9249724/TCR_CZI-IA10466285_S1_L001_R2_001.fastq.gz tcr >/dev/null && N=$((N+1))
rm -rf vdj_TCR_CZI-IA10471913
sbatch --job-name=crvdj_TCR_CZI-IA10471913 cr_vdj_one.sh TCR_CZI-IA10471913 ERR9249748 https://ftp.sra.ebi.ac.uk/vol1/run/ERR924/ERR9249748/TCR_CZI-IA10471913_S1_L001_R1_001.fastq.gz https://ftp.sra.ebi.ac.uk/vol1/run/ERR924/ERR9249748/TCR_CZI-IA10471913_S1_L001_R2_001.fastq.gz tcr >/dev/null && N=$((N+1))
rm -rf vdj_TCR_CZI-IA10466286
sbatch --job-name=crvdj_TCR_CZI-IA10466286 cr_vdj_one.sh TCR_CZI-IA10466286 ERR9249728 https://ftp.sra.ebi.ac.uk/vol1/run/ERR924/ERR9249728/TCR_CZI-IA10466286_S1_L001_R1_001.fastq.gz https://ftp.sra.ebi.ac.uk/vol1/run/ERR924/ERR9249728/TCR_CZI-IA10466286_S1_L001_R2_001.fastq.gz tcr >/dev/null && N=$((N+1))
echo "resubmitted $N"
