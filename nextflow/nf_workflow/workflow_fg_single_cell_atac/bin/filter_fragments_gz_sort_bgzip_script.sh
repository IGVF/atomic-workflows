#!/bin/bash

# filter_fragments_gz_sort_bgzip_script.sh

# Input parameters
threshold=$1
temp_summary_dict=$2
output_file_name=$3
in_frag_tsv_gz=$4

awk -v threshold="$threshold" -v FS='[,|\t]' 'NR==FNR && ($2-$3-$4-$5)>threshold {Arr[$1]++;next} Arr[$4] {print $0}' "$temp_summary_dict" <(zcat "$in_frag_tsv_gz") | bgzip -l 5 -@ 16 -c > "$output_file_name"

# Count the number of barcodes after filtering
echo '------ Number of barcodes AFTER filtering ------'
cat "$temp_summary_dict" | grep -v barcode | awk -v FS="," -v threshold="$threshold" '($2-$3-$4-$5)>threshold' | wc -l

# sort -k1,1 -k2,2n -k3,3n -o "${in_frag_tsv_gz}.sorted"