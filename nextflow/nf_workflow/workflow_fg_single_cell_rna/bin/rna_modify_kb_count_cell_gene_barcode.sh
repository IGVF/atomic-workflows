#!/bin/bash

# Check if all three parameters (filename, suffix, output_file_suffix) are provided
if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <filename> <suffix> <output_file_suffix>"
    exit 1
fi

filename=$1
suffix=$2
output_file_suffix=$3

# Copy the input file to the output file with the specified output file suffix
cp "${filename}" "${output_file_suffix}"
echo "File copied to ${output_file_suffix}"

# Check if the suffix is not "none"
if [ "$suffix" != "none" ]; then
    # Append the suffix to each line in the input file and save to the output file
    sed 's/$/'"${suffix}"'/' "${filename}" > "${output_file_suffix}"
    echo "sed command executed on ${filename} with suffix: ${suffix}"
else
    echo "Suffix is 'none', skipping sed command."
fi
