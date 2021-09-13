# define these:
#mapped_dir="7q_mapped"
#FIVEFIVESD=341677
#FIVETHREESD=1071921
#THREEFIVESD=2520593
#THREETHREESD=3321169
mapped_dir="$1"
FIVEFIVESD="$2"
FIVETHREESD="$3"
THREEFIVESD="$4"
THREETHREESD="$5"

# pad with 50kb:
FIVEFIVESD=$(echo "$FIVEFIVESD" | awk '{print $0-50000}')
FIVETHREESD=$(echo "$FIVETHREESD" | awk '{print $0+50000}')
THREEFIVESD=$(echo "$THREEFIVESD" | awk '{print $0-50000}')
THREETHREESD=$(echo "$THREETHREESD" | awk '{print $0+50000}')

# just region name:
mapped_region=$(echo $mapped_dir | sed 's/_mapped//g')

cd $mapped_dir
rm -f *refcoords

for m in *_mapped
do 
genome=$(echo $m | sed 's/_mapped//g')
for i in "$m"/*_vs_chr*xmap;
do
    rm -f *.multiple.ids
    rm -f *.single.ids
    rm -f *.opposite.orientation.ids
    rm -f *.five
    rm -f *.three
    rm -f *.five.three
    rm -f *.five.three.xmap

    # get multiple (split mappers) and single (non split mappers) IDs:
    grep -v "#" $i | cut -f2 | sort | uniq -c | awk '$1 > 1' | awk '{$1=$1};1' | cut -d' ' -f2 | tr ' ' '\t' > $i.multiple.ids
    grep -v "#" $i | cut -f2 | sort | uniq -c | awk '$1== "1"' | awk '{$1=$1};1' | cut -d' ' -f2 | tr ' ' '\t' > $i.single.ids

    # get splitters in opposite orientation:
    while read line; do awk -v id="$line" '$2 == id' $i | cut -f2,8 | tr '\n' '\t' | grep "+" | grep "-" | cut -f1; echo ""; done <$i.multiple.ids | awk 'NF' > $i.multiple.opposite.orientation.ids

    # get splitters in 5' and 3' SDs:
    # of the above new file, get those from XMAP and see if between 5’ or 3’ SDs padded with 50kb (already done padding)
    while read line; do awk -v id="$line" '$2 == id {print $2"\t"$6"\t"$7}' $i | awk -v ff="$FIVEFIVESD" -v ft="$FIVETHREESD" -v tf="$THREEFIVESD" -v tt="$THREETHREESD"  '($2 >= ff && $2 <= ft) || ($3 >= ff && $3 <= ft)'; done <$i.multiple.opposite.orientation.ids > $i.multiple.opposite.orientation.five

    while read line; do awk -v id="$line" '$2 == id {print $2"\t"$6"\t"$7}' $i | awk -v ff="$FIVEFIVESD" -v ft="$FIVETHREESD" -v tf="$THREEFIVESD" -v tt="$THREETHREESD"  '($2 >= tf && $2 <= tt) || ($3 >= tf && $3 <= tt)'; done <$i.multiple.opposite.orientation.ids > $i.multiple.opposite.orientation.three

    # see which lines shared between five and three to get those with splits in both SD groups:
    while read line1 line2 line3; do awk -v id="$line1" '$1 == id' $i.multiple.opposite.orientation.three; done <$i.multiple.opposite.orientation.five | cut -f1 | sort -k1,1n | uniq > $i.multiple.opposite.orientation.five.three

    # get these from original combined.xmap to obtain the final, opposite orientation and interspersed SD group multiple split map molecules:
    while read line; do awk -v id="$line" '$2 == id' $i; done <$i.multiple.opposite.orientation.five.three > $i.multiple.opposite.orientation.five.three.final

done
for i in "$m"/*.multiple.opposite.orientation.five.three.final;
do
    cat $i
done > "$genome"."$mapped_region".ids.refcoords
done


