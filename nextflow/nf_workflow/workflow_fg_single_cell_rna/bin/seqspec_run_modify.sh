#!/bin/bash

# Check if the correct number of arguments is provided
if [ "$#" -ne 5 ]; then
    echo "Usage: $0 <fastq1> <fastq2> <spec_yaml> <output_yaml> <modality_tag_on_seqspec>"
    exit 1
fi

# Assign command line arguments to variables
fastq1="$1"
fastq2="$2"
spec_yaml="$3"
output_yaml="$4"
modality_tag_on_seqspec="$5"

# Run seqspec modify commands
seqspec_command1="seqspec modify -m $modality_tag_on_seqspec -o modrna1.yaml -r \"rna_R1.fastq.gz\" --region-id \"$fastq1\" $spec_yaml"
echo "Running command: $seqspec_command1"
eval "$seqspec_command1"

seqspec_command2="seqspec modify -m $modality_tag_on_seqspec -o modrna2.yaml -r \"rna_R2.fastq.gz\" --region-id \"$fastq2\" modrna1.yaml"
echo "Running command: $seqspec_command2"
eval "$seqspec_command2"

seqspec_command3="seqspec modify -m $modality_tag_on_seqspec -o \"$output_yaml\" -r \"rna_R2.fastq.gz\" --region-id \"$fastq2\" modrna2.yaml"
echo "Running command: $seqspec_command3"
eval "$seqspec_command3"
