#!/bin/bash

# ./execute_kb_count.sh "path/to/index_file" "path/to/t2g_txt" "path/to/technology_file" "path/to/whitelist_file" "task_name" "path/to/fastq1" "path/to/fastq2" "number_of_cpus"

# Check if the correct number of arguments is provided
if [ "$#" -ne 7 ]; then
    echo "Usage: $0 <index_file> <t2g_txt> <technology_file> <whitelist_file> <fastq1> <fastq2> <cpus>"
    exit 1
fi

# Assign command line arguments to variables
index_file="$1"
t2g_txt="$2"
technology_file="$3"
whitelist_file="$4"
fastq1="$5"
fastq2="$6"
cpus="$7"


# Extract technology_string from technology_file
technology_string=$(cat "$technology_file")

# Create the 'out' directory if it doesn't exist
mkdir -p out

# Run the kb count command
kb_count_command="kb count -i $index_file -g $t2g_txt -x $technology_string -w $whitelist_file -o out --h5ad -t $cpus $fastq1 $fastq2"
echo "Running command: $kb_count_command"
eval "$kb_count_command"
