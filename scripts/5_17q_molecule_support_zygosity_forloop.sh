#!/bin/sh
#$ -N mol_filt
#$ -S /bin/sh
#$ -l h_vmem=4G
#$ -l m_mem_free=4G
#$ -wd /mnt/isilon/emanuel_lab/bionano_assemblies_BACKUP/Compressed_Assemblies/DLE1_Assemblies/all_assemblies/FINAL_APPROACH_INVERSIONS
#$ -pe smp 1


###########
# all this does is count the number of lines in the inversion supporting XMAP
# and the non-inversion supporting XMAP
# goes into each mapped dir to do this
###########

# change me:
INV="17q"
FIVE="43000000_45300000"
ALL="/mnt/isilon/emanuel_lab/bionano_assemblies_BACKUP/Compressed_Assemblies/DLE1_Assemblies/all_assemblies/all_assemblies.txt"
# directory where split-mapped files located:
SPLIT_DIRECTORY="/mnt/isilon/emanuel_lab/bionano_assemblies_BACKUP/Compressed_Assemblies/DLE1_Assemblies/all_assemblies/FINAL_APPROACH_INVERSIONS/17q_mapped"


cd $SPLIT_DIRECTORY

echo "#genome no_inversion_mols inversion_mols zygosity" | tr ' ' '\t' > "$INV"_molecule_support_zygosity.txt 

for i in *_mapped
do
SAMPLE=$(echo $i | cut -d'_' -f1)

cd "$SAMPLE"_mapped

# inversion support:
#inv_support=$(grep -v "#" "$SAMPLE"_inversion_support.xmap | cut -f2 | sort | uniq | sort -k1n | wc -l)
inv_support=$(grep -v "#" "$SAMPLE"_multiples.xmap | cut -f2 | sort | uniq | sort -k1n | wc -l)

# no inversion support (an either or proposition):
#five_prime_no_inv_support=$(grep -v "#" "$SAMPLE"_no_inversion_support.xmap | cut -f2 | sort | uniq | sort -k1n | wc -l)
five_prime_no_inv_support=$(grep -v "#" "$SAMPLE"_singles.xmap | cut -f2 | sort | uniq | sort -k1n | wc -l)

# determine if any evidence for het, hom inv, or hom no inv; print genome name, molecule support frequency, and zygosity:
echo $five_prime_no_inv_support $inv_support | tr ' ' '\t' | awk -v s="$SAMPLE" '{if ($2 > 0 && $1 > 0) {print s"\t"$1"\t"$2"\t""HET"} else if ($1 == 0 && $2 == 0) {print s"\t"$1"\t"$2"\t""NO_EVIDENCE"} else if ($2 == 0 && $1 > 0) {print s"\t"$1"\t"$2"\t""HOM_NO_INVERSION"} else if ($1 == 0 && $2 > 0) {print s"\t"$1"\t"$2"\t"$3"\t""HOM_INVERSION"}}' >> ../"$INV"_molecule_support_zygosity.txt

cd ..

done


cd $SPLIT_DIRECTORY

#1. add genome names
while read line1 line2 line3 line4; do grep -w "$line1" "$INV"_molecule_support_zygosity.txt | awk -v n="$line3" '{print n"\t"$0}'; done <$ALL > "$INV"_molecule_support_zygosity_plus_names.txt

#2. sum for total molecules
awk '{print $1"\t"$2"\t"$3"\t"$4"\t"$5"\t"$3+$4}' "$INV"_molecule_support_zygosity_plus_names.txt > "$INV"_tmp.txt

#3. balanced molecules (only applies to HETs, means both inversion and no inversion molecules are >=10)
echo "#genome_name assembly_id no_inversion_mols inversion_mols zygosity total_molecules balanced_molecule_evidence" | tr ' ' '\t' > "$INV"_final_support.txt
awk '{if ($3 >= 10 && $4 >= 10) {print $0"\t""yes"} else {print $0"\t""no"}}' "$INV"_tmp.txt >> "$INV"_final_support.txt

rm -f "$INV"_molecule_support_zygosity_plus_names.txt
rm -f "$INV"_tmp.txt

