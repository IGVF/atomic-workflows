// Enable DSL2
nextflow.enable.dsl=2
//  # Use gunzip to handle both compressed and uncompressed files
//     gunzip -c $whitelist_file > ${whitelist_file.baseName}
process run_whitelist_gunzip {

  // Set debug to true
  debug true
  
  // Label the process as 'gunzip'
  label 'gunzip'

  // Define input paths
  input:
    tuple path(fastq1), path(fastq2), path(fastq3), path(fastq4), path(barcode1_fastq), path(barcode2_fastq), path(spec_yaml), path(whitelist_file),val(subpool),path(conversion_dict),val(prefix)

  // Define output path
  output:
    path "${whitelist_file.baseName}", emit: whitelist_inclusion_file_out

  // Script section
  script:
  """
    echo 'Start run_whitelist_gunzip'
    echo "Gunzip file is: $whitelist_file"
    echo 'Files before processing:'
    ls -lt
    
    # Check if the file exists and is a gzipped file
    if [[ -e $whitelist_file && $whitelist_file == *.gz ]]; then
      zcat $whitelist_file > ${whitelist_file.baseName}
    elif [[ -e $whitelist_file ]]; then
      # If the file exists but is not gzipped, copy it
      cp $whitelist_file ${whitelist_file.baseName}
    else
      # If the file doesn't exist, print an error and exit
      echo "Error: File $whitelist_file not found."
      exit 1
    fi
    
    echo 'Files after processing:'
    ls -lt
    echo 'Finished run_whitelist_gunzip'
  """
}

