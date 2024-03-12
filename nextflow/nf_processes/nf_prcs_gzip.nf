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
    val script_name
    path raw_file

  // Define output path using output directive
  output:
    path "${raw_file}.gz", emit: genes_gtf_gzip_file_out

  // Script section
  script:
  """
    echo 'Start run_gzip'
    echo "Gzip output file is: ${raw_file}.gz"

    /usr/local/bin/$script_name $raw_file
    
    echo 'Finished run_gzip'
  """
}

