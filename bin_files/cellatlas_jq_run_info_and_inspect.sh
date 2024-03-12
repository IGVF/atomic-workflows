#!/bin/bash

# Check if the correct number of parameters is provided
if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <input_run_info_json> <input_inspect_json> <output_log_file>"
    exit 1
fi

input_run_info_json=$1
input_inspect_json=$2
output_log_file=$3

# Fixed pattern
pattern='^\(n_\|p_\)'

# First Command
jq -r 'to_entries | map("\(.key),\(.value)") | .[]' < "$input_run_info_json" | grep "^$pattern" >> "$output_log_file"

# Second Command
jq -r 'to_entries | map("\(.key),\(.value)") | .[]' < "$input_inspect_json" >> "$output_log_file"
