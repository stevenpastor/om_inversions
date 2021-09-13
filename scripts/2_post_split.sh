#!/usr/bin/env bash

for j in *_split
do

sample=$(echo $j | sed 's/_split//g')

for i in "$sample"_split/*bnx; do sample=$(echo $i | cut -d'/' -f1 | sed 's/_split//g'); echo $i "$sample"_split/$sample; done | awk '{print $1"\t"$2"_"NR".bnx"}' > to_move

while read line1 line2; do mv $line1 $line2; done <to_move

done

rm -f to_move

