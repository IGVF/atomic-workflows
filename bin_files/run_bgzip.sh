#!/bin/bash

# Extract input path from command-line argument
fragment_file=$1

echo 'Start run_bgzip_on_chromap_fragments_output'
echo "Fragment file is: $fragment_file"
bgzip -c "$fragment_file" > "${fragment_file}.gz"
ls -lt
echo 'Finished run_bgzip_on_chromap_fragments_output'
