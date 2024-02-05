#!/bin/bash

if [ "$#" -ne 5 ]; then
  echo "Usage: $0 <temp_conversion_output> <barcode_fragments_tsv> <threshold> <no_singleton_bed>"
  exit 1
fi

temp_conversion_output="$1"
barcode_fragments_tsv="$2"
threshold="$3"
no_singleton_bed="$4"
 # TODO: set to the desired number of CPUs
# cpus=4

echo "Script is running..."
echo "Input tempConversionOutput is $1"
echo "Input barcodeFragmentsTsv is $2"
echo "Input threshold is $3"
echo "Input no_singleton_bed is $4"


echo '------ There is a conversion list ------'
echo 'Using modified barcode values from temp_conversion'
# wc -l $temp_conversion_output

# echo '------ Debugging: Printing lines from temp_conversion_output ------'
# awk -v threshold="$threshold" -v FS='[,|\t]' 'NR==FNR {print $0} ($2-$3-$4-$5)>threshold {Arr[$1]++;next} Arr[$4] {print $0}' "$temp_conversion_output"

# echo '------ Debugging: Printing lines from zcat barcode_fragments_tsv ------'
# zcat "$barcode_fragments_tsv" | head -n 10  # Print the first 10 lines for debugging

# echo '------ Debugging: Filtering fragments ------'
# awk -v threshold="$threshold" -v FS='[,|\t]' 'NR==FNR && ($2-$3-$4-$5)>threshold {Arr[$1]++;next} Arr[$4] {print $0}' "$temp_conversion_output" <( zcat "$barcode_fragments_tsv" ) | tee debug_output.txt

# echo '------ Debugging: Number of barcodes AFTER filtering ------'
# cat "$temp_conversion_output" | grep -v barcode | awk -v FS="," -v threshold="$threshold" '($2-$3-$4-$5)>threshold' | wc -l
