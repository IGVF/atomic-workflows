// Enable DSL2
nextflow.enable.dsl=2

process run_whitelist_gunzip {
  debug true
  label 'gunzip'
  input:
    tuple path(fastq1), path(fastq2), path(fastq3), path(spec_yaml), path(whitelist_file)
  output:
    path "${whitelist_file.baseName}", emit: whitelist_file_out
  script:
  """
    echo start run_whitelist_gunzip
    echo 'gunzip file is: $whitelist_file'
    echo 'Files before processing:'
    ls -lt
    if [[ -e $whitelist_file && $whitelist_file == *.gz ]]; then
      zcat $whitelist_file > ${whitelist_file.baseName}
    elif [[ -e $whitelist_file ]]; then
      cp $whitelist_file ${whitelist_file.baseName}
    else
      echo "Error: File $whitelist_file not found."
      exit 1
    fi
    echo 'Files after processing:'
    ls -lt
    echo finished run_whitelist_gunzip
  """
}
