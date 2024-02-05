#!/bin/bash

if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <input_chromap_bzip_fragments_tsv> <output_file_name>"
  exit 1
fi

input_file="$1"
output_file="$2"

echo "start run_generate_insert_size_plot"
echo "insert_size" > "$output_file"
awk '{print $3-$2}' <(zcat "$input_file") | sort --parallel 4 -n | uniq -c | awk -v OFS="\t" '{print $2,$1}' >> "$output_file"
echo "finished run_generate_insert_size_plot"
