// Enable DSL2
nextflow.enable.dsl=2

process run_bgzip {

  // Set debug to true
  debug true
  
  // Label the process as 'bgzip'
  label 'bgzip'

  // Define input path
  input:
    path fragment_file

  // Define output path
  output:
    path "${fragment_file.baseName}.gz", emit: bgzip_fragments_out

  // Script section
  script:
  """
    echo 'Start run_bgzip_fragment_file'
    echo "Fragment file is: $fragment_file"
    ls -lt
    
    # Use bgzip to compress the fragment file
    bgzip $fragment_file
    
    ls -lt
    echo 'Finished run_bgzip_fragment_file'
  """
}
