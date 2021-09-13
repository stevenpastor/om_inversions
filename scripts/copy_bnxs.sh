#!/bin/bash
#SBATCH --job-name=copy_bnx    # Job name
#SBATCH --mail-type=END,FAIL          # Mail events (NONE, BEGIN, END, FAIL, ALL)
#SBATCH --mail-user=pastors@chop.edu  # Where to send mail	
#SBATCH --nodes=1                     # Run all processes on a single node
#SBATCH --ntasks=1                    # Run a single task
#SBATCH --cpus-per-task=1             # Number of CPU cores per task
#SBATCH --mem=600mb                   # Total memory limit
#SBATCH --time=012:00:00               # Time limit hrs:min:sec
#SBATCH --output=test_%j.log   # Standard output log
#SBATCH --error=test_%j.err    # Standard error log


# load modules:
#module load python


# commands:
#while read line1 line2 line3 line4
#do
#    cp -r split_bnxs_separate_directories/"$line1"_split split_bnxs_separate_directories_parents/
#done <all_assemblies_parents.txt

#for i in split_bnxs_separate_directories_parents/*split; do cp -r $i/*bnx split_bnxs/; done

cd split_bnxs
while read line1 line2; do cp -f "$line2" fixed/"$line1"; done <MOVEME

