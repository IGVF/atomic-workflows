// Enable DSL2
nextflow.enable.dsl=2

process run_zcat {

  // Set debug to true
  debug true
  
  // Label the process as 'zcat'
  label 'zcat'

  // Define input path
  input:
    path zcat_file

  // Define output path
  output:
    path "${zcat_file.baseName}", emit: zcat_file_out

  // Script section
  script:
  """
    echo 'Start run_zcat'
    echo "Zcat file is: $zcat_file"
    echo 'Files before processing:'
    ls -lt
    
    # Check if the file exists and is a gzipped file
    if [[ -e $zcat_file && $zcat_file == *.gz ]]; then
      zcat $zcat_file > ${zcat_file.baseName}
    elif [[ -e $zcat_file ]]; then
      # If the file exists but is not gzipped, copy it
      cp $zcat_file ${zcat_file.baseName}
    else
      # If the file doesn't exist, print an error and exit
      echo "Error: File $zcat_file not found."
      exit 1
    fi
    
    echo 'Files after processing:'
    ls -lt
    echo 'Finished run_zcat'
  """
}
