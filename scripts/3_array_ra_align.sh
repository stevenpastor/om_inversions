#!/bin/sh
#$ -N arr_ra_align
#$ -S /bin/sh
#$ -l h_vmem=4G
#$ -l m_mem_free=4G
#$ -wd /mnt/isilon/emanuel_lab/bionano_assemblies_BACKUP/Compressed_Assemblies/DLE1_Assemblies/all_assemblies/FINAL_APPROACH_INVERSIONS
#$ -pe smp 6

##$ -t 1-49

. /etc/profile

BNX="$1"
SPLITDIR="/mnt/isilon/emanuel_lab/bionano_assemblies_BACKUP/Compressed_Assemblies/DLE1_Assemblies/all_assemblies/FINAL_APPROACH_INVERSIONS/split_bnxs"
#REF="chr17_43000000_45300000"
REF="chr2_129000000_133000000"
REFDIR="/mnt/isilon/emanuel_lab/bionano_assemblies_BACKUP/Compressed_Assemblies/DLE1_Assemblies/Inversion_References"
RADIR="/mnt/isilon/emanuel_lab/bionano_assemblies_BACKUP/Compressed_Assemblies/DLE1_Assemblies/all_assemblies"

# align vs cmap:
$RADIR/RefAligner -i $SPLITDIR/$BNX"_split"/$BNX"_"$SGE_TASK_ID.bnx -ref $REFDIR/$REF.cmap -o $BNX"_"$SGE_TASK_ID"_vs_"$REF \
-maxthreads 6 \
-maxmem 20 \
-M 3 3 -FP 0.918057 -FN 0.099062 -sf 0.233588 -sd 0.090609 -S 0 -minlen 160 -minsites 10 -T 1e-11 -res 3.5 -resSD 0.7 -Mfast 0 -biaswt 0 -A 5 -BestRef 0 -nosplit 0 -outlier 1e-7 -endoutlier 1e-7 -f

# clean-up:
rm -f "$BNX"_"$SGE_TASK_ID"_vs_"$REF"*intervals*; rm -f "$BNX"_"$SGE_TASK_ID"_vs_"$REF"*errbin; rm -f "$BNX"_"$SGE_TASK_ID"_vs_"$REF"*err; rm -f "$BNX"_"$SGE_TASK_ID"_vs_"$REF"*maprate; rm -f "$BNX"_"$SGE_TASK_ID"_vs_"$REF"*.map
mkdir -p $BNX"_mapped"
mv -f "$BNX"_"$SGE_TASK_ID"_vs_"$REF"* $BNX"_mapped"

