#!/bin/bash

if [ "$#" -ne 5 ]; then
  echo "Usage: $0 <temp_conversion_output> <barcode_fragments_tsv> <threshold> <gz_outputfile>"
  exit 1
fi

temp_conversion_output="$1"
barcode_fragments_tsv="$2"
threshold="$3"
gz_outputfile="$4"

if [ "$temp_conversion_output" == "temp_conversion" ]; then
  echo 'Using modified barcode values from temp_conversion'
  # Additional processing using modified barcode values
fi

echo '------ Number of barcodes BEFORE filtering------'
# Assuming temp_summary is used by process_conversion.sh
wc -l temp_summary

echo '------ Filtering fragments ------'
awk -v threshold=$threshold -v FS='[,|\t]' 'NR==FNR && ($2-$3-$4-$5)>threshold {Arr[$1]++;next} Arr[$4] {print $0}' temp_summary <( zcat $barcode_fragments_tsv )  | bgzip -l 5 -@ 16 -c > $gz_outputfile

echo '------ Number of barcodes AFTER filtering------'
cat temp_summary | grep -v barcode | awk -v FS="," -v threshold=$threshold '($2-$3-$4-$5)>threshold' | wc -l
