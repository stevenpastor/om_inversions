#!/bin/sh
#SBATCH --job-name=split_align
#SBATCH --mail-type=ALL
#SBATCH --mail-user=pastors@chop.edu
#SBATCH --nodes=1                   # Use one node
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem-per-cpu=4gb
#SBATCH --output=array3q29_%A-%a.out    # Standard output log
#SBATCH --error=array3q29_%A-%a.err     # Standard error log


REF="chr3_195150000_196600000"
REFDIR="/mnt/isilon/emanuel_lab/bionano_assemblies_BACKUP/Compressed_Assemblies/DLE1_Assemblies/Inversion_References"
RADIR="/mnt/isilon/emanuel_lab/bionano_assemblies_BACKUP/Compressed_Assemblies/DLE1_Assemblies/all_assemblies"
BNX="11948B.bnx"
NAME="11948B"

#echo BNX file: $BNX and the base name: $NAME

$RADIR/RefAligner -i $BNX -ref $REFDIR/$REF.cmap -o $NAME"_vs_"$REF \
-maxthreads 8 \
-maxmem 30 \
-M 3 3 -FP 0.918057 -FN 0.099062 -sf 0.233588 -sd 0.090609 -S 0 -minlen 160 -minsites 10 -T 1e-11 -res 3.5 -resSD 0.7 -Mfast 0 -biaswt 0 -A 5 -BestRef 0 -nosplit 0 -outlier 1e-7 -endoutlier 1e-7 -f

# clean-up:
rm -f $NAME"_vs_"$REF*intervals*
rm -f $NAME"_vs_"$REF*errbin
rm -f $NAME"_vs_"$REF*err
rm -f $NAME"_vs_"$REF*maprate
rm -f $NAME"_vs_"$REF*.map


