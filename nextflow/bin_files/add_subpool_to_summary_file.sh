#!/bin/bash

if [ "$#" -ne 4 ]; then
    echo "Usage: $0 <barcode_conversion_file> <subpoolValues> <barcode_summary_csv> <output_conversion>"
    exit 1
fi

barcode_conversion_file="$1"
subpoolValues="$2"
barcode_summary_csv="$3"
output_conversion="$4"

if [[ "$barcode_conversion_file" != *".na"* ]]; then
    echo '------ There is a conversion list ------'
    if [ "$subpoolValues" != "none" ]; then
        echo '------ There is a subpool ------'
        awk -v subpool="$subpoolValues" -v OFS="\t" '{print $1"_"subpool,$2"_"subpool}' "$barcode_conversion_file" > "$output_conversion"
        # Output the modified barcode values for filter_fragments.sh
        echo "$output_conversion"
    else
        echo '------ There is NO subpool ------'
        cp "$barcode_conversion_file" "$output_conversion"
        # Output the information for filter_fragments.sh
        echo "$output_conversion"
    fi
    # Process barcode_summary_csv
    awk -v FS='[,|\t]' -v OFS=',' 'FNR==NR{map[$2]=$1; next}FNR==1{print $0}FNR>1 && map[$1] {print map[$1],$2,$3,$4,$5}' "$output_conversion" "$barcode_summary_csv" > "$output_conversion"
else
    # Process barcode_summary_csv
    echo '------ There is NO conversion list ------'
    cp "$barcode_summary_csv" "$output_conversion"
    # Output the information for filter_fragments.sh
    echo "$output_conversion"
fi
