// Enable DSL2
nextflow.enable.dsl=2

process run_tabix_on_sorted_bgzip_chromap {
  debug true
  label 'tabix_chromap'
  input:
    val tabix_script
    path tabix_fragments_gz
  output:
    path "${tabix_fragments_gz}.tbi", emit: tbi_chromap_fragments_out
  script:
  """
    echo 'Start run_tabix_on_sorted_bgzip_chromap'
    echo 'Input tabix_fragments_gz is $tabix_fragments_gz'
    /usr/local/bin/$tabix_script $tabix_fragments_gz
    echo 'Finished run_tabix_on_sorted_bgzip_chromap'
  """
}

process run_tabix_filtered_fragments_no_singleton {
  debug true
  label 'tabix_singleton'
  input:
    val tabix_script
    path no_singleton_gz
  output:
    path "${tbi_no_singleton_bed_sort_gz_out}.tbi", emit: tbi_no_singleton_bed_sort_gz_out
  script:
  """
    echo 'Start run_tabix_filtered_fragments_no_singleton'
    echo 'Input no_singleton_gz is $no_singleton_gz'
    /usr/local/bin/$tabix_script $no_singleton_gz
    echo 'Finished run_tabix_filtered_fragments_no_singleton'
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
    echo 'Start run_tabix_filtered_fragments'
    echo 'Input tabix_fragments is $tabix_fragments'
    /usr/local/bin/$tabix_script $tabix_fragments
    ls
    echo 'Finished run_tabix_filtered_fragments'
  """
}
