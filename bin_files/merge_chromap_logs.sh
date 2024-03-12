#!/bin/bash

if [ "$#" -ne 3 ]; then
  echo "Usage: $0 <chromap_alignment_log> <chromap_barcode_log> <output_file>"
  exit 1
fi

chromap_alignment_log="$1"
chromap_barcode_log="$2"
output_file="$3"

echo "start run_merge_chromap_logs shell script"
grep 'Number of' "$chromap_alignment_log" | grep -v threads | tr -d '.' | sed 's/ /_/g' | sed 's/:_/,/g' > "$output_file"
cat "$output_file"
echo "********1***********"
grep '#' "$chromap_alignment_log" | sed 's/, /\n/g' | tr -d '# ' | sed 's/:/,/g' | tr -d '.' >> "$output_file"
echo "********2***********"
cat "$output_file"
awk -v FS=',' 'NR>1{unique+= $2; dups+=$3}END{printf "percentage_duplicates,%5.1f", 100*dups/(unique+dups)}' "$chromap_barcode_log" >> "$output_file"
echo "********3***********"
echo "finished run_merge_chromap_logs shell script"
