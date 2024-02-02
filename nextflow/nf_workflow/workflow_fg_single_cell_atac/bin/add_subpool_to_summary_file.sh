#!/bin/bash

if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <barcode_conversion_file> <subpoolValues> <barcode_summary_csv>"
    exit 1
fi

barcode_conversion_file="$1"
subpoolValues="$2"
barcode_summary_csv="$3"

if [[ "$barcode_conversion_file" != *".na"* ]]; then
    echo '------ There is a conversion list ------'
    if [ "$subpoolValues" != "none" ]; then
        echo '------ There is a subpool ------'
        awk -v subpool="$subpoolValues" -v OFS="\t" '{print $1"_"subpool,$2"_"subpool}' "$barcode_conversion_file" > temp_conversion
        # Output the modified barcode values for filter_fragments.sh
        echo "temp_conversion"
    else
        touch temp_conversion
        # Output the information for filter_fragments.sh
        echo "no_subpool"
    fi
    # Process barcode_summary_csv
    awk -v FS='[,|\t]' -v OFS=',' 'FNR==NR{map[$2]=$1; next}FNR==1{print $0}FNR>1 && map[$1] {print map[$1],$2,$3,$4,$5}' temp_conversion "$barcode_summary_csv" > temp_summary
else
    # Process barcode_summary_csv
    cp "$barcode_summary_csv" temp_summary
    # Output the information for filter_fragments.sh
    echo "no_conversion"
fi
