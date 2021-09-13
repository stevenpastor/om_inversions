#!/bin/bash
#SBATCH --job-name=post_align    # Job name
#SBATCH --mail-type=ALL          # Mail events (NONE, BEGIN, END, FAIL, ALL)
#SBATCH --mail-user=pastors@chop.edu  # Where to send mail	
#SBATCH --nodes=1                     # Run all processes on a single node
#SBATCH --ntasks=1                    # Run a single task
#SBATCH --cpus-per-task=1             # Number of CPU cores per task
#SBATCH --mem=4Gb                   # Total memory limit
#SBATCH --time=96:00:00               # Time limit hrs:min:sec
#SBATCH --output=post_align_%j.log   # Standard output log
#SBATCH --error=post_align_%j.err    # Standard error log

sh POST_SPLIT_ALIGNMENT_LATEST.sh 17q_mapped 1450344 1625530 2111112 2658271
#sh POST_SPLIT_ALIGNMENT_LATEST.sh 8p_mapped 1042249 2232632 6050057 6700862 
#sh POST_SPLIT_ALIGNMENT_LATEST.sh 7q_mapped 341677 1071921 2520593 3321169
#sh POST_SPLIT_ALIGNMENT_LATEST.sh 16p_mapped 829754 1056845 1525840 1819324 
#sh POST_SPLIT_ALIGNMENT_LATEST.sh 5q_mapped 320000 700000 2020000 2320000
#sh POST_SPLIT_ALIGNMENT_LATEST.sh 2q_mapped 1060000 1720000 2900000 3360000
#sh POST_SPLIT_ALIGNMENT_LATEST.sh 17q_12_mapped 529133 708659 2217051 2631914 
#sh POST_SPLIT_ALIGNMENT_LATEST.sh 15q252_mapped 783453 1100046 2654815 3167857 
#sh POST_SPLIT_ALIGNMENT_LATEST.sh 15q252q253_mapped 2654815 3167857 3759601 3855818 


