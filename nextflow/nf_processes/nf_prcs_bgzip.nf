// Enable DSL2
nextflow.enable.dsl=2

process run_bgzip_on_chromap_fragments_output {

  // Set debug to true
  debug true
  
  // Label the process as 'bgzip_chromap'
  label 'bgzip_chromap'

  // Define input path
  input:
    path fragment_file

  // Define output path
  output:
    path "${fragment_file}.gz", emit: bgzip_chromap_fragments_tsv_out

  // Script section
  script:
  """
    echo 'Start run_bgzip_on_chromap_fragments_output'
    echo "Fragment file is: $fragment_file"
    bgzip -c $fragment_file > "${fragment_file}.gz"
    ls -lt
    echo 'Finished run_bgzip_on_chromap_fragments_output'
  """
}
