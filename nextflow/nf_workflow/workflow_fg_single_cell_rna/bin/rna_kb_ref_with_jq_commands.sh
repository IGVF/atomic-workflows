#!/bin/bash

# Check if the correct number of arguments is provided
if [ "$#" -ne 6 ]; then
    echo "Usage: $0 <index_file> <t2g_file> <transcriptome_file> <genome_fasta> <gene_gtf> <jq_commands_file>"
    exit 1
fi

# Assign input parameters to variables
index_file="$1"
t2g_file="$2"
transcriptome_file="$3"
genome_fasta="$4"
gene_gtf="$5"
jq_commands_file="$6"

# Debug prints
echo "Index File: $index_file"
echo "T2G File: $t2g_file"
echo "Transcriptome File: $transcriptome_file"
echo "Genome Fasta: $genome_fasta"
echo "Gene GTF: $gene_gtf"
echo "JQ Commands File: $jq_commands_file"

# Use the contents of jq_commands.txt as arguments for kb ref
kb ref -i "$index_file" -g "$t2g_file" -f1 "$transcriptome_file" "$genome_fasta" "$gene_gtf" < "$jq_commands_file"
