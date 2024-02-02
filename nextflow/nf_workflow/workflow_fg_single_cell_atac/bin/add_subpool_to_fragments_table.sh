#!/bin/bash

if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <input_tsv_file> <input_csv_file>"
  exit 1
fi

input_tsv="$1"
input_csv="$2"

# Check if files exist
if [ ! -f "$input_tsv" ] || [ ! -f "$input_csv" ]; then
  echo "Error: One or both input files do not exist."
  exit 1
fi

echo '------  Add subpool to barcode name ------' 1>&2

# Create a temporary directory
temp_dir=$(mktemp -d)

# Process TSV file
awk -v OFS="\t" -v subpool=none '{$4=$4"_"subpool; print $0}' "$input_tsv" > "$temp_dir/temp_tsv"
mv "$temp_dir/temp_tsv" "$input_tsv"

# Process CSV file
awk -v FS="," -v OFS="," -v subpool=none 'NR==1{print $0;next}{$1=$1"_"subpool; print $0}' "$input_csv" > "$temp_dir/temp_csv"
mv "$temp_dir/temp_csv" "$input_csv"

# Remove the temporary directory
rm -r "$temp_dir"
