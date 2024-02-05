// Enable DSL2
nextflow.enable.dsl=2

process run_bgzip_on_chromap_fragments_output {

  // Set debug to true
  debug true
  
  // Label the process as 'bgzip'
  label 'bgzip'

  // Define input path
  input:
    path fragment_file

  // Define output path
  output:
    path "${fragment_file.baseName}.gz", emit: bgzip_chromap_fragments_out

  // Script section
  script:
  """
    echo 'Start run_bgzip_on_chromap_fragments_output'
    echo "Fragment file is: $fragment_file"
    bgzip -c $fragment_file > ${fragment_file.baseName}.gz 2>&1
    ls -lt
    echo 'Finished run_bgzip_on_chromap_fragments_output'
  """
}
