#!/bin/bash

# Check if all three parameters (filename, subpool, output_file_subpool) are provided
if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <filename> <subpool> <output_file_subpool>"
    exit 1
fi

filename=$1
subpool=$2
output_file_subpool=$3

echo "Input filename: ${filename}"
echo "Subpool: ${subpool}"
echo "Output filename with subpool: ${output_file_subpool}"

# Copy the input file to the output file with the specified output file subpool
cp "${filename}" "${output_file_subpool}"
echo "File copied to ${output_file_subpool}"

# Check if the subpool is not "none"
if [ "$subpool" != "none" ]; then
    # Append the subpool to each line in the input file and save to the output file
    sed 's/$/'"${subpool}"'/' "${filename}" > "${output_file_subpool}"
    echo "sed command executed on ${filename} with subpool: ${subpool}"
else
    echo "Subpool is 'none', skipping sed command."
fi
