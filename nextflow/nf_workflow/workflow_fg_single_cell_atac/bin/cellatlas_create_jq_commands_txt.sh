#!/bin/bash

# Check if the correct number of arguments is provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <cellatlas_info.json>"
    exit 1
fi

# Assign input parameter to a variable
cellatlas_info_json="$1"

# Use jq to extract and join commands with newline, then write to jq_commands.txt
jq -r '.commands[] | values[] | join("\n")' "$cellatlas_info_json" > jq_commands.txt
