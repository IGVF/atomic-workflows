#!/bin/bash

# Extract input paths from command-line arguments
ref_fa=$1
output_index=$2

echo 'run_create_chromap_idx'
# create an index first and then map
chromap -i -r "$ref_fa" -o "$output_index"
