#!/bin/sh
#$ -N inv_filt
#$ -S /bin/sh
#$ -l h_vmem=4G
#$ -l m_mem_free=4G
#$ -wd /mnt/isilon/emanuel_lab/bionano_assemblies_BACKUP/Compressed_Assemblies/DLE1_Assemblies/all_assemblies/FINAL_APPROACH_INVERSIONS
#$ -pe smp 1

## Define these variables before running:
# chr:
CHR="chr17"
# ref:
REF="43000000_45300000"
# SD groups surrounding (including) inversion:
FIVEFIVESD=492293
FIVETHREESD=705165
THREEFIVESD=1280653
THREETHREESD=1784489

# number of labels outside the start AND end coordinates for inversion fuzzy breakpoint ranges:
num_labels=5

# directory where split-mapped files located:
SPLIT_DIRECTORY="/mnt/isilon/emanuel_lab/bionano_assemblies_BACKUP/Compressed_Assemblies/DLE1_Assemblies/all_assemblies/FINAL_APPROACH_INVERSIONS/17q_mapped"


#### loop through all mapped genomes:
cd $SPLIT_DIRECTORY

for y in *_mapped
do

SAMPLE=$(echo $y | cut -d'_' -f1)

# merge split aligned maps into one per xmap, qcmap, and rcmap:
cd "$SAMPLE"_mapped
grep "#" "$SAMPLE"_1_vs_"$CHR"_"$REF"_q.cmap > "$SAMPLE"_"$REF"_q.cmap
for i in *"$REF"*q.cmap; do grep -v "#" $i; done >> "$SAMPLE"_"$REF"_q.cmap

# use one ref only for the r.cmap merging, since each r.cmap is the same:
cp "$SAMPLE"_1_vs_"$CHR"_"$REF"_r.cmap "$SAMPLE"_"$REF"_r.cmap

# merge xmaps:
grep "#" "$SAMPLE"_1_vs_"$CHR"_"$REF".xmap > "$SAMPLE"_"$REF".xmap
for i in *vs_"$CHR"_*"$REF"*.xmap; do grep -v "#" $i >> "$SAMPLE"_"$REF".xmap; done

### Filters:
## 1. separate IDs with >1 count from those with only 1 count:
grep -v "#" "$SAMPLE"_"$REF".xmap | cut -f2 | sort | uniq -c | awk '$1 == "1"' | awk '{$1=$1};1' | cut -d' ' -f2 > molecule_ids_counts_ones
grep -v "#" "$SAMPLE"_"$REF".xmap | cut -f2 | sort | uniq -c | awk '$1 > 1' | awk '{$1=$1};1' | cut -d' ' -f2 > molecule_ids_counts_multiples

## get XMAPs of these:
grep "#" "$SAMPLE"_"$REF".xmap > "$SAMPLE"_singles.xmap
grep "#" "$SAMPLE"_"$REF".xmap > "$SAMPLE"_multiples.xmap
while read line; do grep -v "#" "$SAMPLE"_"$REF".xmap | grep -w "$line" >> "$SAMPLE"_singles.xmap; done <molecule_ids_counts_ones
#while read line; do grep -v "#" "$SAMPLE"_"$REF".xmap | grep -w "$line" >> "$SAMPLE"_multiples.xmap; done <molecule_ids_counts_multiples
while read line; do grep -v "#" "$SAMPLE"_"$REF".xmap | awk -v id="$line" '$2 == id' >> "$SAMPLE"_multiples.xmap; done <molecule_ids_counts_multiples

## Keep IDs which have opposite orientation and (re)place into the "SAMPLE"_multiples.xmap:
while read line; do grep -w "$line" "$SAMPLE"_multiples.xmap | cut -f2,8 | tr '\n' ';' | tr '\t' ' ' | grep "+" | grep "-"; echo ""; done <molecule_ids_counts_multiples | awk 'NF' | cut -d' ' -f1  > tmp
grep "#" "$SAMPLE"_"$REF".xmap > tmp.xmap
while read line; do grep -w "$line" "$SAMPLE"_"$REF".xmap; done <tmp >> tmp.xmap
rm -f "$SAMPLE"_multiples.xmap
mv -f tmp.xmap "$SAMPLE"_multiples.xmap

## Now "SAMPLE"_multiples.xmap has split maps with opposing orientations

cd ..
done


###############
### Per genome, find the split map breaks:
for i in *mapped; do while read line; do SAMPLE=$(echo $i | sed 's/_mapped//g'); grep -v "#" $i/"$SAMPLE"_"$REF".xmap | awk -v id="$line" '$2 == id' | cut -f2,4,5 | tr '\n' '\t'; echo ""; done <$i/tmp | awk '{print $1}' > $i/query_ids; done
for i in *mapped; do while read line; do SAMPLE=$(echo $i | sed 's/_mapped//g'); grep -v "#" $i/"$SAMPLE"_"$REF".xmap | awk -v id="$line" '$2 == id' | cut -f4,5 | tr '\n' '\t'; echo ""; done <$i/tmp > $i/queries; done
for i in *mapped; do while read line; do echo $line | tr ' ' '\n' | sort -k1n | tr '\n' '\t'; echo ""; done <$i/queries|  cut -f2- | rev | sed 's/^\t//g' | cut -f2- | rev > $i/query_middles; done 
for i in *mapped; do paste $i/query_ids $i/query_middles > $i/query_ids_middles; done 

# TWOS-TWELVES (b/c one is mol ID so do not use):
# first, it prints ID and QUERY START OR END (echo $line1 $line2)
# then, it finds if the QUERY COLUMN is a start or end and adds 2 to this value, since this will be the REF start or end COLUMN (makes into rows, finds the query start or end row, adds 2 so can get the ref start or end row, which will become column once flattened as XMAP row again)
# finally, prints the actual REF start or END 
# prints 4 total things:
for i in *mapped; do SAMPLE=$(echo $i | sed 's/_mapped//g'); while read line1 line2 line3 line4 line5 line6 line7 line8 line9 line10 line11 line12; do echo $line1 $line2 | tr '\n' '\t'; val=$(grep -w "$line2" $i/"$SAMPLE"_"$REF".xmap | head -1 | cut -f2,4,5,6,7 | tr '\t' '\n' | grep -nw "$line2" | cut -d':' -f1 | awk '{print $1+2}'); echo $val | tr '\n' '\t'; grep -w "$line2" $i/"$SAMPLE"_"$REF".xmap | head -1 | cut -f2,4,5,6,7 | awk -v locus="$val" '{print $locus}'; done <$i/query_ids_middles > $i/TWOS; done
for i in *mapped; do SAMPLE=$(echo $i | sed 's/_mapped//g'); while read line1 line2 line3 line4 line5 line6 line7 line8 line9 line10 line11 line12; do echo $line1 $line3 | tr '\n' '\t'; val=$(grep -w "$line3" $i/"$SAMPLE"_"$REF".xmap | tail -1 | cut -f2,4,5,6,7 | tr '\t' '\n' | grep -nw "$line3" | cut -d':' -f1 | awk '{print $1+2}'); echo $val | tr '\n' '\t'; grep -w "$line3" $i/"$SAMPLE"_"$REF".xmap | tail -1 | cut -f2,4,5,6,7 | awk -v locus="$val" '{print $locus}'; done <$i/query_ids_middles > $i/THREES; done
for i in *mapped; do SAMPLE=$(echo $i | sed 's/_mapped//g'); while read line1 line2 line3 line4 line5 line6 line7 line8 line9 line10 line11 line12; do if [[ $line4 == '' ]]; then echo "No No No No" | tr ' ' '\t'; else echo $line1 $line4 | tr '\n' '\t'; val=$(grep -w "$line4" $i/"$SAMPLE"_"$REF".xmap | head -1 | cut -f2,4,5,6,7 | tr '\t' '\n' | grep -nw "$line4" | cut -d':' -f1 | awk '{print $1+2}'); echo $val | tr '\n' '\t'; grep -w "$line4" $i/"$SAMPLE"_"$REF".xmap | head -1 | cut -f2,4,5,6,7 | awk -v locus="$val" '{print $locus}'; fi; done <$i/query_ids_middles > $i/FOURS; done
for i in *mapped; do SAMPLE=$(echo $i | sed 's/_mapped//g'); while read line1 line2 line3 line4 line5 line6 line7 line8 line9 line10 line11 line12; do if [[ $line5 == '' ]]; then echo "No No No No" | tr ' ' '\t'; else echo $line1 $line5 | tr '\n' '\t'; val=$(grep -w "$line5" $i/"$SAMPLE"_"$REF".xmap | tail -1 | cut -f2,4,5,6,7 | tr '\t' '\n' | grep -nw "$line5" | cut -d':' -f1 | awk '{print $1+2}'); echo $val | tr '\n' '\t'; grep -w "$line5" $i/"$SAMPLE"_"$REF".xmap | cut -f2,4,5,6,7 | tail -1 | awk -v locus="$val" '{print $locus}'; fi; done <$i/query_ids_middles > $i/FIVES; done
for i in *mapped; do SAMPLE=$(echo $i | sed 's/_mapped//g'); while read line1 line2 line3 line4 line5 line6 line7 line8 line9 line10 line11 line12; do if [[ $line6 == '' ]]; then echo "No No No No" | tr ' ' '\t'; else echo $line1 $line6 | tr '\n' '\t'; val=$(grep -w "$line6" $i/"$SAMPLE"_"$REF".xmap | cut -f2,4,5,6,7 | tr '\t' '\n' | grep -nw "$line6" | cut -d':' -f1 | awk '{print $1+2}'); echo $val | tr '\n' '\t'; grep -w "$line6" $i/"$SAMPLE"_"$REF".xmap | cut -f2,4,5,6,7 | awk -v locus="$val" '{print $locus}'; fi; done <$i/query_ids_middles > $i/SIXES; done
for i in *mapped; do SAMPLE=$(echo $i | sed 's/_mapped//g'); while read line1 line2 line3 line4 line5 line6 line7 line8 line9 line10 line11 line12; do if [[ $line7 == '' ]]; then echo "No No No No" | tr ' ' '\t'; else echo $line1 $line7 | tr '\n' '\t'; val=$(grep -w "$line7" $i/"$SAMPLE"_"$REF".xmap | cut -f2,4,5,6,7 | tr '\t' '\n' | grep -nw "$line7" | cut -d':' -f1 | awk '{print $1+2}'); echo $val | tr '\n' '\t'; grep -w "$line7" $i/"$SAMPLE"_"$REF".xmap | cut -f2,4,5,6,7 | awk -v locus="$val" '{print $locus}'; fi; done <$i/query_ids_middles > $i/SEVENS; done
for i in *mapped; do SAMPLE=$(echo $i | sed 's/_mapped//g'); while read line1 line2 line3 line4 line5 line6 line7 line8 line9 line10 line11 line12; do if [[ $line8 == '' ]]; then echo "No No No No" | tr ' ' '\t'; else echo $line1 $line8 | tr '\n' '\t'; val=$(grep -w "$line8" $i/"$SAMPLE"_"$REF".xmap | cut -f2,4,5,6,7 | tr '\t' '\n' | grep -nw "$line8" | cut -d':' -f1 | awk '{print $1+2}'); echo $val | tr '\n' '\t'; grep -w "$line8" $i/"$SAMPLE"_"$REF".xmap | cut -f2,4,5,6,7 | awk -v locus="$val" '{print $locus}'; fi; done <$i/query_ids_middles > $i/EIGHTS; done
for i in *mapped; do SAMPLE=$(echo $i | sed 's/_mapped//g'); while read line1 line2 line3 line4 line5 line6 line7 line8 line9 line10 line11 line12; do if [[ $line9 == '' ]]; then echo "No No No No" | tr ' ' '\t'; else echo $line1 $line9 | tr '\n' '\t'; val=$(grep -w "$line9" $i/"$SAMPLE"_"$REF".xmap | cut -f2,4,5,6,7 | tr '\t' '\n' | grep -nw "$line9" | cut -d':' -f1 | awk '{print $1+2}'); echo $val | tr '\n' '\t'; grep -w "$line9" $i/"$SAMPLE"_"$REF".xmap | cut -f2,4,5,6,7 | awk -v locus="$val" '{print $locus}'; fi; done <$i/query_ids_middles > $i/NINES; done
for i in *mapped; do SAMPLE=$(echo $i | sed 's/_mapped//g'); while read line1 line2 line3 line4 line5 line6 line7 line8 line9 line10 line11 line12; do if [[ $line10 == '' ]]; then echo "No No No No" | tr ' ' '\t'; else echo $line1 $line10 | tr '\n' '\t'; val=$(grep -w "$line10" $i/"$SAMPLE"_"$REF".xmap | cut -f2,4,5,6,7 | tr '\t' '\n' | grep -nw "$line10" | cut -d':' -f1 | awk '{print $1+2}'); echo $val | tr '\n' '\t'; grep -w "$line10" $i/"$SAMPLE"_"$REF".xmap | cut -f2,4,5,6,7 | awk -v locus="$val" '{print $locus}'; fi; done <$i/query_ids_middles > $i/TENS; done
for i in *mapped; do SAMPLE=$(echo $i | sed 's/_mapped//g'); while read line1 line2 line3 line4 line5 line6 line7 line8 line9 line10 line11 line12; do if [[ $line11 == '' ]]; then echo "No No No No" | tr ' ' '\t'; else echo $line1 $line11 | tr '\n' '\t'; val=$(grep -w "$line11" $i/"$SAMPLE"_"$REF".xmap | cut -f2,4,5,6,7 | tr '\t' '\n' | grep -nw "$line11" | cut -d':' -f1 | awk '{print $1+2}'); echo $val | tr '\n' '\t'; grep -w "$line11" $i/"$SAMPLE"_"$REF".xmap | cut -f2,4,5,6,7 | awk -v locus="$val" '{print $locus}'; fi; done <$i/query_ids_middles > $i/ELEVENS; done
for i in *mapped; do SAMPLE=$(echo $i | sed 's/_mapped//g'); while read line1 line2 line3 line4 line5 line6 line7 line8 line9 line10 line11 line12; do if [[ $line12 == '' ]]; then echo "No No No No" | tr ' ' '\t'; else echo $line1 $line12 | tr '\n' '\t'; val=$(grep -w "$line12" $i/"$SAMPLE"_"$REF".xmap | cut -f2,4,5,6,7 | tr '\t' '\n' | grep -nw "$line12" | cut -d':' -f1 | awk '{print $1+2}'); echo $val | tr '\n' '\t'; grep -w "$line12" $i/"$SAMPLE"_"$REF".xmap | cut -f2,4,5,6,7 | awk -v locus="$val" '{print $locus}'; fi; done <$i/query_ids_middles > $i/TWELVES; done

# Go through the TWOS-TWELVES and prints the ID and REF locus (1st and 4th cols for TWOS and only 4th col for rest since do not need ID for rest as redundant (same one) per file):
for i in *mapped; do SAMPLE=$(echo $i | sed 's/_mapped//g'); tr ' ' '\t' <$i/TWOS | cut -f1,4 > $i/TWOS.cols14; done
for i in *mapped; do SAMPLE=$(echo $i | sed 's/_mapped//g'); tr ' ' '\t' <$i/THREES | cut -f4 > $i/THREES.cols14; done
for i in *mapped; do SAMPLE=$(echo $i | sed 's/_mapped//g'); tr ' ' '\t' <$i/FOURS | cut -f4 > $i/FOURS.cols14; done
for i in *mapped; do SAMPLE=$(echo $i | sed 's/_mapped//g'); tr ' ' '\t' <$i/FIVES | cut -f4 > $i/FIVES.cols14; done
for i in *mapped; do SAMPLE=$(echo $i | sed 's/_mapped//g'); tr ' ' '\t' <$i/SIXES | cut -f4 > $i/SIXES.cols14; done
for i in *mapped; do SAMPLE=$(echo $i | sed 's/_mapped//g'); tr ' ' '\t' <$i/SEVENS | cut -f4 > $i/SEVENS.cols14; done
for i in *mapped; do SAMPLE=$(echo $i | sed 's/_mapped//g'); tr ' ' '\t' <$i/EIGHTS | cut -f4 > $i/EIGHTS.cols14; done
for i in *mapped; do SAMPLE=$(echo $i | sed 's/_mapped//g'); tr ' ' '\t' <$i/NINES | cut -f4 > $i/NINES.cols14; done
for i in *mapped; do SAMPLE=$(echo $i | sed 's/_mapped//g'); tr ' ' '\t' <$i/TENS | cut -f4 > $i/TENS.cols14; done
for i in *mapped; do SAMPLE=$(echo $i | sed 's/_mapped//g'); tr ' ' '\t' <$i/ELEVENS | cut -f4 > $i/ELEVENS.cols14; done
for i in *mapped; do SAMPLE=$(echo $i | sed 's/_mapped//g'); tr ' ' '\t' <$i/TWELVES | cut -f4 > $i/TWELVES.cols14; done

# paste these together:
for i in *mapped; do SAMPLE=$(echo $i | sed 's/_mapped//g'); paste $i/TWOS.cols14 $i/THREES.cols14 $i/FOURS.cols14 $i/FIVES.cols14 $i/SIXES.cols14 $i/SEVENS.cols14 $i/EIGHTS.cols14 $i/NINES.cols14 $i/TENS.cols14 $i/ELEVENS.cols14 $i/TWELVES.cols14 > $i/combined.cols14; done

# count (enumerate) the ref coords in each $i/combined.cols14 as these are the inversion breakpoints:
for i in *mapped; do cut -f2- $i/combined.cols14 | tr '\t' '\n' | grep -v "No" | sort -k1n | uniq -c | awk '{$1=$1};1' | tr ' ' '\t' | sort -k1nr > $i/combined.cols14.counted; done

# top 20 split breaks:
for i in *mapped; do cut -f2- $i/combined.cols14 | tr '\t' '\n' | grep -v "No"; done | sort -k1n | uniq -c | sort -k1nr | head -20 > top_20_split_breaks.txt

# top 1000 split breaks:
for i in *mapped; do cut -f2- $i/combined.cols14 | tr '\t' '\n' | grep -v "No"; done | sort -k1n | uniq -c | sort -k1nr | head -1000 > top_1000_split_breaks.txt
############################


###################
## Non-Inversion maps:
#for y in *_mapped
#do
#cd $y
#SAMPLE=$(echo $y | cut -d'_' -f1)
#grep -v "#" "$SAMPLE"_singles_completely_crossing_either_sd_group.xmap | cut -f2 > ids
#grep "#" "$SAMPLE"_43000000_45300000_q.cmap > "$SAMPLE"_singles_q.cmap
#while read line; do awk -v id="$line" '$1 == id' "$SAMPLE"_43000000_45300000_q.cmap >> "$SAMPLE"_singles_q.cmap; done <ids
#rm -f ids
#cd ..
#done

#for y in *_mapped
#do
#echo $y/*_singles_q.cmap
#done > ./all_singles_qcmap_files

#../../RefAligner -merge -if all_singles_qcmap_files -o all_singles_qcmap

#../../RefAligner -i all_singles_qcmap.cmap -ref ../../../Inversion_References/"$CHR"_"$REF".cmap -o all_singles_qcmaps_vs_"$REF" \
#-maxthreads 6 \
#-maxmem 20 \
#-M 3 3 -FP 0.918057 -FN 0.099062 -sf 0.233588 -sd 0.090609 -S 0 -minlen 160 -minsites 10 -T 1e-11 -res 3.5 -resSD 0.7 -Mfast 0 -biaswt 0 -A 5 -BestRef 0 -nosplit 2 -outlier 1e-7 -endoutlier 1e-7 -f



##########################
### Inversion maps:
rm -f all_inv_lengths
for y in *_mapped
do
cd $y
SAMPLE=$(echo $y | cut -d'_' -f1)
grep -v "#" "$SAMPLE"_multiples.xmap | cut -f2 | sort -k1n | uniq > ids
while read line; do awk -v id="$line" '$2 == id' "$SAMPLE"_multiples.xmap | awk -v s="$SAMPLE" '{print $7-$6}' | tr '\n' '\t' | awk -v s="$SAMPLE" -v id="$line" '{print s"\t"id"\t"$0}' >> ../all_inv_lengths; done <ids
rm -f ids
cd ..
done

while read line; do echo $line | tr ' ' '\t' | cut -f3- | tr '\t' '\n' | awk '{sum+=$1;} END{print sum;}'; done <all_inv_lengths > tmp
paste all_inv_lengths tmp > all_inv_lengths_summed
cut -f1-4,6 all_inv_lengths_summed > tmp; rm all_inv_lengths_summed; mv tmp all_inv_lengths_summed
sort -k5nr all_inv_lengths_summed | head -100 > all_inv_lengths_summed_top_100
sort -k5nr all_inv_lengths_summed | head -1000 > all_inv_lengths_summed_top_1000
sort -k5nr all_inv_lengths_summed | head -10000 > all_inv_lengths_summed_top_10000

#for y in *_mapped
#do
#echo $y/*_multiples_q.cmap
#done > ./all_multiples_qcmap_files

#../../RefAligner -merge -if all_multiples_qcmap_files -o all_multiples_qcmap

#../../RefAligner -i all_multiples_qcmap.cmap -ref ../../../Inversion_References/"$CHR"_"$REF".cmap -o all_multiples_qcmaps_vs_"$REF" \
#-maxthreads 6 \
#-maxmem 20 \
#-M 3 3 -FP 0.918057 -FN 0.099062 -sf 0.233588 -sd 0.090609 -S 0 -minlen 160 -minsites 10 -T 1e-11 -res 3.5 -resSD 0.7 -Mfast 0 -biaswt 0 -A 5 -BestRef 0 -nosplit 2 -outlier 1e-7 -endoutlier 1e-7 -f

##while read line1 line2 line3; do awk -v id="$line2" '$2 == id' "$line1"_mapped/"$line1"_multiples.xmap; done <all_inv_lengths_summed_top_10000


##########
# Inversion breakpoint fuzzy ranges:
# ranges for 5’ and 3’ ends of the split map breakpoints but ONLY those within SDs:
for y in *_mapped
do
SAMPLE=$(echo $y | cut -d'_' -f1)

# get all split breaks, even if repeated (not unique):
cut -f2- $y/combined.cols14 | tr '\t' '\n' | grep -v "No" | sort -k1n > $y/combined.cols14.raw
# obtain only those split breaks within complexity defined at top of file:
while read line2; do echo $line2 | awk -v ff="$FIVEFIVESD" -v ft="$FIVETHREESD" -v tf="$THREEFIVESD" -v tt="$THREETHREESD" '$1>=ff && $1<=ft {print $1}'; done <$y/combined.cols14.raw | sort -k1n > $y/tmp.coords
while read line2; do echo $line2 | awk -v ff="$FIVEFIVESD" -v ft="$FIVETHREESD" -v tf="$THREEFIVESD" -v tt="$THREETHREESD" '$1>=tf && $1<=tt {print $1}'; done <$y/combined.cols14.raw | sort -k1n >> $y/tmp.coords
# bin the breaks into 100kb bins
awk -v size=100000 '{ b=int($1/size); a[b]++; bmax=b>bmax?b:bmax; bmin=b<bmin?b:bmin } END { for(i=bmin;i<=bmax;++i) print i*size,(i+1)*size,a[i] }' $y/tmp.coords | tr ' ' '\t' | awk '$3 > 0' > $y/combined.cols14.bins

## deprecated: this used all breaks (in 17q, this created some spurious results due to the 130XXXXXX breaks and want a fuzzy range around most accurate breaks more >=150XXXXXX):
#five_smallest=$(while read line1 line2; do echo $line2 | awk -v ff="$FIVEFIVESD" -v ft="$FIVETHREESD" -v tf="$THREEFIVESD" -v tt="$THREETHREESD" '$1>=ff && $1<=ft {print $1}'; done <$y/combined.cols14.counted | sort -k1n | head -1)
#five_largest=$(while read line1 line2; do echo $line2 | awk -v ff="$FIVEFIVESD" -v ft="$FIVETHREESD" -v tf="$THREEFIVESD" -v tt="$THREETHREESD" '$1>=ff && $1<=ft {print $1}'; done <$y/combined.cols14.counted | sort -k1n | tail -1)
#three_smallest=$(while read line1 line2; do echo $line2 | awk -v ff="$FIVEFIVESD" -v ft="$FIVETHREESD" -v tf="$THREEFIVESD" -v tt="$THREETHREESD" '$1>=tf && $1<=tt {print $1}'; done <$y/combined.cols14.counted | sort -k1n | head -1)
#three_largest=$(while read line1 line2; do echo $line2 | awk -v ff="$FIVEFIVESD" -v ft="$FIVETHREESD" -v tf="$THREEFIVESD" -v tt="$THREETHREESD" '$1>=tf && $1<=tt {print $1}'; done <$y/combined.cols14.counted | sort -k1n | tail -1)

## print these out to a file:
#echo $SAMPLE $five_smallest $five_largest $three_smallest $three_largest | tr ' ' '\t' > $y/inversion_breakpoint_ranges

# 5' only bins:
while read line1 line2 line3; do echo $line1 $line2 $line3 | tr ' ' '\t' | awk -v ff="$FIVEFIVESD" -v ft="$FIVETHREESD" '{if ($1>=ff && $1<=ft) {print $1"\t"$2"\t"$3} else if ($2>=ff && $2<=ft) {print $1"\t"$2"\t"$3}}'; done <$y/combined.cols14.bins | sort -k1n > $y/five.bins

# first 2 largest (in the event of a tie, picks the coordinate with biggest range; reduces sensitivity of non-inversions but conservative which may be more specific:
# if there are 2 lines or more or 1 line:
nlines=$(wc -l $y/five.bins | awk '{$1=$1};1' | cut -d' ' -f1)
if [[ "$nlines" -gt 1 ]]
then
    sort -k3nr $y/five.bins | head -2 | sort -k1n | head -1 > $y/five.bins.best.small
    sort -k3nr $y/five.bins | head -2 | sort -k1n | tail -1 > $y/five.bins.best.large
    # get the loci from each bin:
    # smallest:
    five_smallest=$(while read line1 line2 line3; do awk -v lone="$line1" -v ltwo="$line2" '$1>=lone && $1<=ltwo {print $1}' $y/combined.cols14.raw; done <$y/five.bins.best.small | sort -k1n | head -1)
    # largest:
    five_largest=$(while read line1 line2 line3; do awk -v lone="$line1" -v ltwo="$line2" '$1>=lone && $1<=ltwo {print $1}' $y/combined.cols14.raw; done <$y/five.bins.best.large | sort -k1n | tail -1)
else
    sort -k3nr $y/five.bins | head -1 > $y/five.bins.best
    five_smallest=$(while read line1 line2 line3; do awk -v lone="$line1" -v ltwo="$line2" '$1>=lone && $1<=ltwo {print $1}' $y/combined.cols14.raw; done <$y/five.bins.best | sort -k1n | head -1)
    five_largest=$(while read line1 line2 line3; do awk -v lone="$line1" -v ltwo="$line2" '$1>=lone && $1<=ltwo {print $1}' $y/combined.cols14.raw; done <$y/five.bins.best | sort -k1n | tail -1)
fi

# 3' only bins:
while read line1 line2 line3; do echo $line1 $line2 $line3 | tr ' ' '\t' | awk -v tf="$THREEFIVESD" -v tt="$THREETHREESD" '{if ($1>=tf && $1<=tt) {print $1"\t"$2"\t"$3} else if ($2>=tf && $2<=tt) {print $1"\t"$2"\t"$3}}'; done <$y/combined.cols14.bins | sort -k1n > $y/three.bins

# first 2 largest (in the event of a tie, picks the coordinate with biggest range; reduces sensitivity of non-inversions but conservative which may be more specific:
nlines=$(wc -l $y/three.bins | awk '{$1=$1};1' | cut -d' ' -f1)
if [[ "$nlines" -gt 1 ]]
then
    sort -k3nr $y/three.bins | head -2 | sort -k1n | head -1 > $y/three.bins.best.small
    sort -k3nr $y/three.bins | head -2 | sort -k1n | tail -1 > $y/three.bins.best.large
    three_smallest=$(while read line1 line2 line3; do awk -v lone="$line1" -v ltwo="$line2" '$1>=lone && $1<=ltwo {print $1}' $y/combined.cols14.raw; done <$y/three.bins.best.small | sort -k1n | head -1)
    three_largest=$(while read line1 line2 line3; do awk -v lone="$line1" -v ltwo="$line2" '$1>=lone && $1<=ltwo {print $1}' $y/combined.cols14.raw; done <$y/three.bins.best.large | sort -k1n | tail -1)
else
    sort -k3nr $y/three.bins | head -1 > $y/three.bins.best
    three_smallest=$(while read line1 line2 line3; do awk -v lone="$line1" -v ltwo="$line2" '$1>=lone && $1<=ltwo {print $1}' $y/combined.cols14.raw; done <$y/three.bins.best | sort -k1n | head -1)
    three_largest=$(while read line1 line2 line3; do awk -v lone="$line1" -v ltwo="$line2" '$1>=lone && $1<=ltwo {print $1}' $y/combined.cols14.raw; done <$y/three.bins.best | sort -k1n | tail -1)
fi

# print these out to a file:
echo $SAMPLE $five_smallest $five_largest $three_smallest $three_largest | tr ' ' '\t' > $y/inversion_breakpoint_ranges


###########
# Non-Inversion support:
# obtain the label indices for the ref complex coordinates:
ffsd=$(cut -f2 $y/inversion_breakpoint_ranges)
ftsd=$(cut -f3 $y/inversion_breakpoint_ranges)
tfsd=$(cut -f4 $y/inversion_breakpoint_ranges)
ttsd=$(cut -f5 $y/inversion_breakpoint_ranges)
five_five_ref=$(grep -v "#" $y/"$SAMPLE"_"$REF"_r.cmap | awk -v ff="$ffsd" '$6 <= ff' | cut -f4 | tail -1)
five_three_ref=$(grep -v "#" $y/"$SAMPLE"_"$REF"_r.cmap | awk -v ft="$ftsd" '$6 >= ft' | cut -f4 | head -1)
three_five_ref=$(grep -v "#" $y/"$SAMPLE"_"$REF"_r.cmap | awk -v tf="$tfsd" '$6 <= tf' | cut -f4 | tail -1)
three_three_ref=$(grep -v "#" $y/"$SAMPLE"_"$REF"_r.cmap | awk -v tt="$ttsd" '$6 >= tt' | cut -f4 | head -1)

# >=num_labels outside the start AND end coordinates of the above fuzzy inversion breakpoint ranges:
while read line; 
do 
    echo $line | grep -v "#" | cut -d' ' -f14 | sed 's/)/\n/g' | sed 's/(//g' | cut -d',' -f1 | awk -v ff="$five_five_ref" '$1 <= ff' | awk 'NF' | wc -l | tr '\n' '\t'; 
    echo $line | grep -v "#" | cut -d' ' -f14 | sed 's/)/\n/g' | sed 's/(//g' | cut -d',' -f1 | awk -v ft="$five_three_ref" '$1 >= ft' | awk 'NF' | wc -l | tr '\n' '\t'; 
    echo $line | grep -v "#" | cut -d' ' -f14 | sed 's/)/\n/g' | sed 's/(//g' | cut -d',' -f1 | awk -v tf="$three_five_ref" '$1 <= tf' | awk 'NF' | wc -l | tr '\n' '\t'; 
    echo $line | grep -v "#" | cut -d' ' -f14 | sed 's/)/\n/g' | sed 's/(//g' | cut -d',' -f1 | awk -v tt="$three_three_ref" '$1 >= tt' | awk 'NF' | wc -l; 
done <$y/"$SAMPLE"_singles.xmap > $y/counts.tmp

awk -v nl="$num_labels" '$1 >= nl && $2 >= nl {print NR}' $y/counts.tmp > $y/non_inversions.tmp
awk -v nl="$num_labels" '$3 >= nl && $4 >= nl {print NR}' $y/counts.tmp >> $y/non_inversions.tmp
sort -k1n $y/non_inversions.tmp | uniq | sort -k1n > $y/non_inversions

grep "#" $y/"$SAMPLE"_singles.xmap > $y/tmp.xmap
while read line; do sed -n "$line p" $y/"$SAMPLE"_singles.xmap >> $y/tmp.xmap; done <$y/non_inversions
rm -f $y/"$SAMPLE"_singles.xmap; mv -f $y/tmp.xmap $y/"$SAMPLE"_singles.xmap


# multiples (inversion support):
while read line1 line2; do echo $line2 | awk -v ff="$FIVEFIVESD" -v ft="$FIVETHREESD" -v tf="$THREEFIVESD" -v tt="$THREETHREESD" '{if ($1>=ff && $1<=ft) {print $1} else if ($1>=tf && $1<=tt) {print $1}}'; done <$y/combined.cols14.counted | sort -k1n > $y/get_these_coordinates
while read line; do grep -w "$line" $y/"$SAMPLE"_multiples.xmap; done <$y/get_these_coordinates | cut -f2 | sort | uniq -c | awk '{$1=$1};1' | tr ' ' '\t' | awk '$1 > 1' | cut -f2 > $y/get_these_ids_multiples
grep "#" $y/"$SAMPLE"_multiples.xmap > $y/tmp.xmap
while read line; do awk -v id="$line" '$2 == id' $y/"$SAMPLE"_multiples.xmap >> $y/tmp.xmap; done <$y/get_these_ids_multiples
rm -f $y/"$SAMPLE"_multiples.xmap; mv -f $y/tmp.xmap $y/"$SAMPLE"_multiples.xmap

done



