#!/bin/bash

# Check if the correct number of arguments is provided
if [ "$#" -ne 5 ]; then
    echo "Usage: $0 <R1_fastq.gz> <R2_fastq.gz> <seqspec_file> <modality> <output_file>"
    exit 1
fi

# Assign command line arguments to variables
R1_fastq="$1"
R2_fastq="$2"
seqspec_file="$3"
modality="$4"
output_file="$5"

# Run the command and write the output to the specified file
seqspec_command="seqspec index -t kb -m $modality -r $R1_fastq,$R2_fastq $seqspec_file > $output_file"
echo "Running command: $seqspec_command"
eval "$seqspec_command"
