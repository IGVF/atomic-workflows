#!/bin/bash

# filter_script.sh

# Input parameters
threshold=$1
temp_summary_dict=$2
output_file_name=$3
in_fragments_tsv_g=$4

awk -v threshold="$threshold" -v FS='[,|\t]' 'NR==FNR && ($2-$3-$4-$5)>threshold {Arr[$1]++;next} Arr[$4] {print $0}' "$temp_summary_dict" <(zcat "$in_fragments_tsv_g") | bgzip -l 5 -@ 16 -c > "$output_file_name"


# Count the number of barcodes after filtering
echo '------ Number of barcodes AFTER filtering ------'
cat "$temp_summary_dict" | grep -v barcode | awk -v FS="," -v threshold="$threshold" '($2-$3-$4-$5)>threshold' | wc -l