#!/bin/bash

# Check for correct number of parameters
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <log_file> <input_file>"
    exit 1
fi

# Extract parameters
log_file="$1"
input_file="$2"

# Print parameters for debugging
echo "log_file: $log_file"
echo "input_file: $input_file"

# Command 1
echo "Inserting size into log file..."
echo "insert_size" > "$log_file"
echo "Header 'insert_size' added to $log_file"

# Command 2
echo "Printing head of zcat output:"
head <(zcat "$input_file")

echo "Calculating insert size and updating log file..."
awk '{print $3-$2}' <(zcat "$input_file") | sort --parallel 4 -n | uniq -c | awk -v OFS="\t" '{print $2,$1}' >> "$log_file"
echo "Insert size calculated and appended to $log_file"
