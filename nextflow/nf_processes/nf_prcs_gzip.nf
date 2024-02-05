// Enable DSL2
nextflow.enable.dsl=2
// Process to gzip the input file
// Define the process
process run_gzip_on_genes_gtf {

  // Set debug to true
  debug true
  
  // Label the process as 'gzip'
  label 'gzip'

  // Define input paths
  input:
    path raw_file

  // Define output path using output directive
  output:
    path "${raw_file}.gz", emit: genes_gtf_gzip_file_out

  // Script section
  script:
  """
    echo 'Start run_gzip'
    echo "Gzip file is: ${raw_file}.gz"
    
    # Check if the input file exists
    if [[ -e $raw_file ]]; then
      gzip < $raw_file > "${raw_file}.gz"
      echo 'Files after processing:'
      ls -lt
    else
      # If the file doesn't exist, print an error and exit
      echo "Error: File $raw_file not found."
      exit 1
    fi
    
    echo 'Finished run_gzip'
  """
}
