#!/bin/bash

echo "------ Script Parameters ------"
echo "barcode_conversion_dict_file: $0"
echo "subpool_in: $1"
echo "barcode_summary: $2"
echo "fragments_cutoff: $3"
echo "fragments_file: $4"
echo "cpus: $5"
echo "filtered_fragment_file: $6"
echo "------------------------------"

if [ "$1" == "na.na" ]; then
    echo '------ There is no barcode_conversion_dict_file ------'
    cp "$3" temp_summary
else
    echo '------ There is a conversion list ------'
    if [ -z "$2" ]; then
        echo '------ There is no subpool ------'
        cp "$1" temp_conversion
    else
        echo '------ There is a subpool ------'
        awk -v subpool="$2" -v OFS="\t" '{print $1"_"subpool,$2"_"subpool}' "$1" > temp_conversion
    fi

    awk -v FS='[,|\t]' -v OFS=',' 'FNR==NR{map[$2]=$1; next}FNR==1{print $0}FNR>1 && map[$1] {print map[$1],$2,$3,$4,$5}' temp_conversion "$3" > temp_summary
fi

echo '------ Number of barcodes BEFORE filtering ------'
wc -l temp_summary

echo '------ Filtering fragments ------'
awk -v threshold="$4" -v FS='[,|\t]' 'NR==FNR && ($2-$3-$4-$5)>threshold {Arr[$1]++;next} Arr[$4] {print $0}' temp_summary <( zcat "$5" ) | bgzip -l 5 -@ "$6" -c > "$7"

echo '------ Number of barcodes AFTER filtering ------'
cat temp_summary | grep -v barcode | awk -v FS="," -v threshold="$4" '($2-$3-$4-$5)>threshold' | wc -l
