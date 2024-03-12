#!/bin/bash

# Extract input and output paths from command-line arguments
zcat_file=$1
zcat_file_out=$2

echo 'Start run_zcat'
echo "Zcat file is: $zcat_file"
echo "Output file is: $zcat_file_out"

# Check if the file exists and is a gzipped file
if [[ -e $zcat_file && $zcat_file == *.gz ]]; then
  zcat $zcat_file > $zcat_file_out
elif [[ -e $zcat_file ]]; then
  # If the file exists but is not gzipped, copy it
  cp $zcat_file $zcat_file_out
else
  # If the file doesn't exist, print an error and exit
  echo "Error: File $zcat_file not found."
  exit 1
fi

echo 'Files after processing:'
ls -lt
echo 'Finished run_zcat'
