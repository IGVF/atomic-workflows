#!/bin/bash

# Extract input path from command-line argument
file_name=$1

echo 'Start run_whitelist_gunzip'
echo "File is: $file_name"
echo 'Files before processing:'
# Check if the file exists and is a gzipped file
if [[ -e $file_name && $file_name == *.gz ]]; then
  gunzip -c "$file_name" > "${file_name%.gz}"
elif [[ -e $file_name ]]; then
  # If the file exists but is not gzipped, copy it
  cp "$file_name" "${file_name%.gz}"
else
  # If the file doesn't exist, print an error and exit
  echo "Error: File $file_name not found."
  exit 1
fi

echo 'Files after processing:'
ls -lt
echo 'Finished run_whitelist_gunzip'
