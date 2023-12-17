#!/bin/bash

# Create a sample BED file
echo -e "chr1\t100\t200\tfragment1\t1\t+" > filtered_fragment_file.bed
echo -e "chr2\t300\t400\tfragment2\t2\t-" >> filtered_fragment_file.bed
echo -e "chr3\t500\t600\tfragment3\t3\t+" >> filtered_fragment_file.bed

# Display the content of the generated file
cat filtered_fragment_file.bed
