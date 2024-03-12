#!/bin/bash

# Extract input path from command-line argument
raw_file=$1

echo 'Start run_gzip'
echo "Gzip file is: ${raw_file}.gz"

# Check if the input file exists
if [[ -e $raw_file ]]; then
  gzip < "$raw_file" > "${raw_file}.gz"
  echo 'Files after processing:'
  ls -lt
else
  # If the file doesn't exist, print an error and exit
  echo "Error: File $raw_file not found."
  exit 1
fi

echo 'Finished run_gzip'
