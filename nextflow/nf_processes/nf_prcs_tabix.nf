// Enable DSL2
nextflow.enable.dsl=2
    
process run_tabix {
  debug true
  label 'tabix'
  input:
    val tabix_script
    path tabix_fragments
  output:
    path "${tabix_fragments}.tbi", emit: tbi_fragments_out
  script:
  """
    echo 'start run_tabix'
    echo 'input tabix_fragments is $tabix_fragments'
    ls /usr/local/bin/
    /usr/local/bin/$tabix_script $tabix_fragments
    echo 'finished run_tabix'
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
    ls /usr/local/bin/
    /usr/local/bin/$tabix_script $tabix_fragments
    echo 'create the output file with the nextflow output variable'
    touch ${tabix_fragments}.tbi
    echo 'finished run_tabix_filtered_fragments'
  """
}
