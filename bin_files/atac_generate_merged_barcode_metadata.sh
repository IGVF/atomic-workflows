#!/bin/bash

# Parse command line options
while getopts ":i:t:o:" opt; do
  case ${opt} in
    i) input_filtered_barcode_stats=${OPTARG} ;;
    t) tss_enrichment_barcode_stats=${OPTARG} ;;
    o) output_barcode_merged_metadata=${OPTARG} ;;
    \?) echo "Invalid option: -$OPTARG" >&2; exit 1 ;;
    :) echo "Option -$OPTARG requires an argument." >&2; exit 1 ;;
  esac
done

# Check if required options are provided
if [[ -z ${input_filtered_barcode_stats} || -z ${tss_enrichment_barcode_stats} || -z ${output_barcode_merged_metadata} ]]; then
  echo "Usage: $0 -i <input_filtered_barcode_stats> -t <tss_enrichment_barcode_stats> -o <output_barcode_merged_metadata>"
  exit 1
fi

# Adding new metrics to the barcode file
awk -v FS=',' -v OFS=" " 'NR==1{$1=$1;print $0,"unique","pct_dup","pct_unmapped";next}{$1=$1;if ($2-$3-$4-$5>0){print $0,($2-$3-$4-$5),$3/($2-$4-$5),($5+$4)/$2} else { print $0,0,0,0}}' "${input_filtered_barcode_stats}" > tmp-barcode-stats

# Barcode identifier
cut -f 1 "${tss_enrichment_barcode_stats}" > barcodes_passing_threshold

# Merging
join -j 1 <(cat "${tss_enrichment_barcode_stats}" | (sed -u 1q;sort -k1,1)) <(grep -wFf barcodes_passing_threshold tmp-barcode-stats | (sed -u 1q;sort -k1,1)) | \
(sed -u 1q;sort -k1,1) | \
awk -v FS=" " -v OFS=" " 'NR==1{print $0,"pct_reads_promoter"}NR>1{print $0,$4*100/$7}' | sed 's/ /\t/g' > "${output_barcode_merged_metadata}"

# Example calling command
# ./generate_barcode_metadata.sh -i path/to/filtered_barcode_stats.csv -t path/to/tss_enrichment_barcode_stats.csv -o path/to/output/barcode_merged_metadata.tsv
