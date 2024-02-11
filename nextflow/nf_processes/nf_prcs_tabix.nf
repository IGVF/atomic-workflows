// Enable DSL2
nextflow.enable.dsl=2
    
process run_tabix_chromap {
  debug true
  label 'tabix_chromap'
  input:
    val tabix_script
    path tabix_fragments
  output:
    path "${tabix_fragments}.tbi", emit: tbi_chromap_fragments_out
  script:
  """
    echo 'start run_tabix_chromap'
    echo 'input tabix_fragments is $tabix_fragments'
    /usr/local/bin/$tabix_script $tabix_fragments
    echo 'finished run_tabix_chromap'
  """
}

process run_tabix_no_singleton {
  debug true
  label 'tabix_singelston'
  input:
    val tabix_script
    path no_singelton_gz
  output:
    path "${no_singelton_gz}.tbi", emit: tbi_no_singleton_bed_gz_out
  script:
  """
    echo 'start run_tabix_no_singleton'
    echo 'input no_singelton_gz is $no_singelton_gz'
    /usr/local/bin/$tabix_script $no_singelton_gz
    echo 'finished run_tabix_no_singleton'
  """
}

process run_tabix_filtered_fragments {
  debug true
  label 'tabix_after_fragments'
  input:
    val tabix_script
    path tabix_fragments
  output:
    path "${tabix_fragments}.tbi", emit: tbi_fragments_out
  script:
  """
    echo 'start run_tabix_filtered_fragments'
    echo 'input tabix_fragments is $tabix_fragments'
    /usr/local/bin/$tabix_script $tabix_fragments
    ls
    echo 'finished run_tabix_filtered_fragments'
  """
}