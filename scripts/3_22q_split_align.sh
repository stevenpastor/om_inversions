#!/bin/sh
#SBATCH --job-name=split_align
#SBATCH --mail-type=ALL
#SBATCH --mail-user=pastors@chop.edu
#SBATCH --nodes=1                   # Use one node
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem-per-cpu=4gb
#SBATCH --output=array22_%A-%a.out    # Standard output log
#SBATCH --error=array22_%A-%a.err     # Standard error log


# how to run this script:
#sbatch --array [1-3] 3_2q_21_1_split_align.sh


# first, re-name all the split_bnxs (do locally and not in this script):
#cd split_bnxs
#num=1; for i in *split; do mv $i $i.$num; num=$((num+1)); done
#cd ..

#REF="chr17_43000000_45300000"
#REF="chr2_129000000_133000000"
#REF="chr5_175600000_178200000"
#REF="chr7_72200000_75800000"
#REF="chr8_6000000_13500000"
#REF="chr17_35700000_38700000"
#REF="chr15_81400000_86200000"
#REF="chr16_20900000_23400000"
REF="chr22_17800000_19400000"
REFDIR="/mnt/isilon/emanuel_lab/bionano_assemblies_BACKUP/Compressed_Assemblies/DLE1_Assemblies/Inversion_References"
RADIR="/mnt/isilon/emanuel_lab/bionano_assemblies_BACKUP/Compressed_Assemblies/DLE1_Assemblies/all_assemblies"
BNX=$(echo split_bnxs/*_"$SLURM_ARRAY_TASK_ID".bnx)
NAME=$(echo split_bnxs/*_"$SLURM_ARRAY_TASK_ID".bnx | cut -d'/' -f2 | cut -d'_' -f1)

#echo BNX file: $BNX and the base name: $NAME

$RADIR/RefAligner -i $BNX -ref $REFDIR/$REF.cmap -o $NAME"_"$SLURM_ARRAY_TASK_ID"_vs_"$REF \
-maxthreads 8 \
-maxmem 30 \
-M 3 3 -FP 0.918057 -FN 0.099062 -sf 0.233588 -sd 0.090609 -S 0 -minlen 160 -minsites 10 -T 1e-11 -res 3.5 -resSD 0.7 -Mfast 0 -biaswt 0 -A 5 -BestRef 0 -nosplit 0 -outlier 1e-7 -endoutlier 1e-7 -f

# clean-up:
rm -f $NAME"_"$SLURM_ARRAY_TASK_ID"_vs_"$REF*intervals*
rm -f $NAME"_"$SLURM_ARRAY_TASK_ID"_vs_"$REF*errbin
rm -f $NAME"_"$SLURM_ARRAY_TASK_ID"_vs_"$REF*err
rm -f $NAME"_"$SLURM_ARRAY_TASK_ID"_vs_"$REF*maprate
rm -f $NAME"_"$SLURM_ARRAY_TASK_ID"_vs_"$REF*.map

mkdir -p $NAME"_mapped"
mv -f $NAME"_"$SLURM_ARRAY_TASK_ID"_vs_"$REF* $NAME"_mapped"



