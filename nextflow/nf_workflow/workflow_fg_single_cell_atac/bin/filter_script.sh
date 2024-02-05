#!/bin/bash

# Input: temp_dict_conversion, threshold
awk -v FS=',' -v threshold="$1" '($2-$3-$4-$5) > threshold' "$2" | wc -l
