#!/bin/bash

# Check if the correct number of arguments is provided
if [ "$#" -ne 7 ]; then
    echo "Usage: $0 <output_directory> <mode> <spec_file> <genome_fasta_gz> <gene_gtf> <fastq1> <fastq2>"
    exit 1
fi

# Assign input parameters to variables
output_directory="$1"
mode="$2"
spec_file="$3"
genome_fasta_gz="$4"
gene_gtf="$5"
fastq1="$6"
fastq2="$7"

# Create output directory if it doesn't exist
mkdir -p "$output_directory"

# Print input parameters
echo "Output Directory: $output_directory"
echo "Mode: $mode"
echo "Spec File: $spec_file"
echo "Genome Fasta Gz: $genome_fasta_gz"
echo "Gene GTF: $gene_gtf"
echo "Fastq1: $fastq1"
echo "Fastq2: $fastq2"

# Build command
cellatlas build \
    -o "$output_directory" \
    -m "$mode" \
    -s "$spec_file" \
    -fa "$genome_fasta_gz" \
    -g "$gene_gtf" \
    "$fastq1" "$fastq2"

# List contents of the output directory
echo "Contents of Output Directory:"
ls "$output_directory"
