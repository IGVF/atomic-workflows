#!/bin/bash

# Check for correct number of parameters
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <log_file> <input_file>"
    exit 1
fi

# Extract parameters
input_file="$1"
output_log_file="$2"


# Print parameters for debugging
echo "output_log_file: $output_log_file"
echo "input_file: $input_file"

# Print the first few lines of the input file
echo "Head of input_file:"
zcat "$input_file" | head


touch "$output_log_file"
echo "insert_size" > $output_log_file
awk '{print $3-$2}' <(zcat $input_file ) | sort --parallel 4 -n | uniq -c | awk -v OFS="\t" '{print $2,$1}' >> $output_log_file


# Print the contents of the output log file
#echo "Contents of $output_log_file:"
#cat "$output_log_file"