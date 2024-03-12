#!/bin/bash

# Check if the correct number of arguments is provided
if [ "$#" -ne 4 ]; then
    echo "Usage: $0 <R1_shard_0> <R2_shard_0> <R1_shard_1> <R2_shard_1>"
    exit 1
fi

# Assign command line arguments to variables
R1_shard_0="$1"
R2_shard_0="$2"
R1_shard_1="$3"
R2_shard_1="$4"

# Create interleaved_files_string
interleaved_files_string=$(paste -d' ' \
  <(printf "%s\n" "$R1_shard_0" "$R1_shard_1") \
  <(printf "%s\n" "$R2_shard_0" "$R2_shard_1") \
  | tr -s ' ')

# Print the resulting interleaved_files_string
echo "Interleaved Files String:"
echo "$interleaved_files_string"
