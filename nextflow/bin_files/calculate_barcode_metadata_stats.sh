#!/bin/bash

# calculate_barcode_metadata_stats.sh

# Assigning values to inputs
temp_dict_conversion=$1
tss_enrichment_barcode_stats=$2
output_tmp_barcode_stats=$3
output_barcodes_passing_threshold=$4

echo "Input temp_dict_conversion: $temp_dict_conversion"
echo "Input tss_enrichment_barcode_stats: $tss_enrichment_barcode_stats"
echo "Output tmp_barcode_stats: $output_tmp_barcode_stats"
echo "Output barcodes_passing_threshold: $output_barcodes_passing_threshold"

# Header for the outputs
echo -e "Column1\tColumn2\tunique\tpct_dup\tpct_unmapped" > "$output_tmp_barcode_stats"

# Use awk to process the file, the tss_enrichment_barcode_stats is tab separator and the output_tmp_barcode_stats is tab separator
awk -v FS='\t' -v OFS="\t" 'NR>1{$1=$1;if ($2-$3-$4-$5>0){print $1,$2,$2-$3-$4-$5,$3/($2-$4-$5),($5+$4)/$2} else { print $1,$2,0,0,0}}' "$tss_enrichment_barcode_stats" >> "$output_tmp_barcode_stats"


# awk -v FS=',' -v OFS="\t" 'NR==1{next}{$1=$1;if ($2-$3-$4-$5>0){print $0,($2-$3-$4-$5),$3/($2-$4-$5),($5+$4)/$2} else { print $0,0,0,0}}' "$tss_enrichment_barcode_stats" >> "$output_tmp_barcode_stats"

cut -f 1 "$tss_enrichment_barcode_stats" > "$output_barcodes_passing_threshold"

# Output the first few lines of output_tmp_barcode_stats
echo "------ START: Output tmp_barcode_stats ------"
head "$output_tmp_barcode_stats"
echo "------ END: Output tmp_barcode_stats ------"

# Output the first few lines of output_barcodes_passing_threshold
echo "------ START: Output barcodes_passing_threshold ------"
head "$output_barcodes_passing_threshold"
echo "------ END: Output barcodes_passing_threshold ------"
