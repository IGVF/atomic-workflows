// Enable DSL2
nextflow.enable.dsl=2

// print

process run_bgzip {
  debug true
  label 'bgzip'
  input:
    path fragment_file
  output:
    path "${fragment_file}.gz" , emit: bgzip_fragments_out
  script:
  """
    echo start run_bgzip_fragment_file
    echo 'fragment_file is: $fragment_file'
    ls -lt
    bgzip $fragment_file
    ls -lt
    echo finished run_bgzip_fragment_file
  """
}

