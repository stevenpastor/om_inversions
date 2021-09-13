#!/bin/sh
#$ -N for_split
#$ -S /bin/sh
#$ -l h_vmem=500M
#$ -l m_mem_free=500M
#$ -wd /mnt/isilon/emanuel_lab/bionano_assemblies_BACKUP/Compressed_Assemblies/DLE1_Assemblies/all_assemblies/FINAL_APPROACH_INVERSIONS
#$ -pe smp 1

for b in *bnx.gz
do

sample=$(echo $b | sed 's/\.bnx\.gz//g')

echo ""
echo "-----"
echo $sample
echo "-----"
echo ""

gzip -d $b

mkdir -p $sample"_split"
grep "#" $sample.bnx > $sample.header
grep -v "#" $sample.bnx > $sample.data
split -l 250000 -a 6 $sample.data $sample"_split"/
for i in $sample"_split"/*; do mv $i $i.bnx; done
for i in $sample"_split"/*; do cat $sample.header | cat - $i > /tmp/out && mv /tmp/out $i; done
rm -f $sample.header; rm -f $sample.data

gzip $sample.bnx

done

