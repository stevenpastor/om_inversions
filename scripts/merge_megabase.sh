#!/bin/sh
#SBATCH --job-name=merge
#SBATCH --mail-type=ALL
#SBATCH --mail-user=pastors@chop.edu
#SBATCH --nodes=1                   # Use one node
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=4gb
#SBATCH --output=merge_%A-%a.out    # Standard output log
#SBATCH --error=merge_%A-%a.err     # Standard error log


RADIR="/mnt/isilon/emanuel_lab/bionano_assemblies_BACKUP/Compressed_Assemblies/DLE1_Assemblies/all_assemblies"

#$RADIR/RefAligner -merge -bnx -if input -o merged_megabase -maxthreads 16 -maxmem 62

#for i in xa*
#do
#    $RADIR/RefAligner -merge -bnx -if "$i" -o merged_megabase_"$i" -minlen 1000 -maxthreads 16 -maxmem 62
#done

#$RADIR/RefAligner -merge -bnx -if input -o merged_megabase -maxthreads 16 -maxmem 62

mkdir split_bnxs_megabase_merged
cd split_bnxs
for i in *bnx
do
    $RADIR/RefAligner -merge -bnx -if $i -o ../split_bnxs_megabase_merged/"$i"_million -maxthreads 1 -maxmem 4
done

