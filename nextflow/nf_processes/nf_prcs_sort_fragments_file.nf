// Enable DSL2
nextflow.enable.dsl=2

process run_sort_on_chromap_fragments_output {

  // Set debug to true
  debug true
  
  // Label the process as 'bgzip_chromap'
  label 'sort_chromap_tsv'

  // Define input path
  input:
    path fragment_file

  // Define output path
  output:
    path "${fragment_file}.sorted.tsv", emit: sorted_chromap_fragments_tsv_out

  // Script section
  script:
  """
    echo 'Start run_sort_on_chromap_fragments_output'
    echo "Fragment file is: $fragment_file"
    sort -k1,1 -k2,2n -k3,3n -o ${fragment_file}.sorted.tsv $fragment_file
    ls -lt
    echo 'Finished run_sort_on_chromap_fragments_output'
  """
}
