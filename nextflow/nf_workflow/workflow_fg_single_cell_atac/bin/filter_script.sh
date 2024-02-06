#!/bin/bash

# filter_script.sh

# Input parameters
threshold=$1
temp_dict_conversion=$2
output_file_name=$3
barcodeFragmentsTsv=$4

# Create a temporary file for storing intermediate results
temp_filtered_file="tmp_file"

awk -v threshold="$threshold" -v FS='[,|\t]' 'NR==FNR && ($2-$3-$4-$5)>threshold {print}' "$temp_dict_conversion" <(zcat "$barcodeFragmentsTsv") > "$temp_filtered_file"
echo "------ 3 - Number of lines in intermediate file AFTER 2nd filtering ------"
wc -l "$temp_filtered_file"

# Compress the filtered file
echo "------ bgzip of temp_filtered_file and creating output_file_name------"
bgzip -l 5 -@ 16 -c "$temp_filtered_file" > "$output_file_name"

# Print the line count after filtering and compression (Part 2)
echo "------ Number of lines in zcat $output_file_name AFTER filtering and compression ------"
zcat "$output_file_name" | wc -l

# Print the path of the output file for Nextflow to capture
echo "name of output_file_name is: $output_file_name"

# Additional command using script variable and parameters
echo "------ Additional command: Counting lines in temp_filtered_file ------"
cat "$temp_filtered_file" | grep -v barcode | awk -v FS="," -v threshold="$threshold" '($2-$3-$4-$5)>threshold' | wc -l
