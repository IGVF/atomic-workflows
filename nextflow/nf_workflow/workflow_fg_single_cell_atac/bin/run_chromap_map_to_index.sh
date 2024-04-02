#!/bin/bash

# Extract input paths and parameters from command-line arguments
fastq1=$1
fastq2=$2
fastq3=$3
fastq4=$4
barcode1_fastq=$5
barcode2_fastq=$6
genome_fasta=$7
genome_chromap_idx=$8
CHROMAP_READ_LENGTH=$9
CHROMAP_BC_ERROR_THRESHOLD=${10}
CHROMAP_BC_PROBABILITY_THRESHOLD=${11}
CHROMAP_READ_FORMAT=${12}
CHROMAP_DROP_REPETITIVE_READS=${13}
CHROMAP_QUALITY_THRESHOLD=${14}
whitelist_file=${15}
CPUS_TO_USE=${16}
prefix=${17}

echo 'run_chromap_map_to_idx'
echo "fastq1 is $fastq1"
echo "fastq2 is $fastq2"
echo "fastq3 is $fastq3"
echo "fastq4 is $fastq4"
echo "barcode1_fastq is $barcode1_fastq"
echo "barcode2_fastq is $barcode2_fastq"
echo "genome_fasta is $genome_fasta"
echo "genome_chromap_idx is $genome_chromap_idx"
echo "CHROMAP_READ_LENGTH is $CHROMAP_READ_LENGTH"
echo "CHROMAP_BC_ERROR_THRESHOLD is $CHROMAP_BC_ERROR_THRESHOLD"
echo "CHROMAP_BC_PROBABILITY_THRESHOLD is $CHROMAP_BC_PROBABILITY_THRESHOLD"
echo "CHROMAP_READ_FORMAT is $CHROMAP_READ_FORMAT"
echo "CHROMAP_DROP_REPETITIVE_READS is $CHROMAP_DROP_REPETITIVE_READS"
echo "CHROMAP_QUALITY_THRESHOLD is $CHROMAP_QUALITY_THRESHOLD"
echo "whitelist_file is $whitelist_file"
echo "CPUS_TO_USE is $CPUS_TO_USE"
echo "prefix is $prefix"
echo "tsv is ${prefix}.atac.filter.fragments.tsv"
echo "csv is ${prefix}.atac.align.barcode.summary.csv"
echo "log out is ${prefix}.atac.align.k4.hg38.log.txt"

echo 'start chromap execution'
chromap -x $genome_chromap_idx --trim-adapters --remove-pcr-duplicates --remove-pcr-duplicates-at-cell-level --Tn5-shift --low-mem --BED -l $CHROMAP_READ_LENGTH --bc-error-threshold $CHROMAP_BC_ERROR_THRESHOLD --bc-probability-threshold $CHROMAP_BC_PROBABILITY_THRESHOLD --read-format $CHROMAP_READ_FORMAT --drop-repetitive-reads $CHROMAP_DROP_REPETITIVE_READS -r $genome_fasta -q $CHROMAP_QUALITY_THRESHOLD -t $CPUS_TO_USE -1 $fastq1,$fastq2 -2 $fastq3,$fastq4 -b $barcode1_fastq,$barcode2_fastq --barcode-whitelist $whitelist_file -o ${prefix}.atac.filter.fragments.tsv --summary ${prefix}.atac.align.barcode.summary.csv > ${prefix}.atac.align.k4.hg38.log.txt 2>&1
echo 'finished run_chromap_map_to_idx'
