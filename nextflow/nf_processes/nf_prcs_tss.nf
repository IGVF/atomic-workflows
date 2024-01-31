// Enable DSL2
nextflow.enable.dsl=2

// Define default values for parameters
// params.tss_bases_flank = 2000
params.tss_col_strand_info = 4
params.smoothing_window_size = 20
params.tss_bases_flank = 50
    
process run_calculate_tss_enrichment {
  debug true
  label 'tss'
  input:
    val calculation_script
    path fragments
    path tbi_fragments
    path regions
    val tss_bases_flank
    val tss_col_strand_info
    val smoothing_window_size
  output:
    path "${tbi_fragments}.tss", emit: tss_fragments_out
  script:
  """
    echo 'start run_tss'
    echo 'calculation_script is $calculation_script. check that it is: compute_tss_script.py'
    echo 'fragments: $fragments'
    echo 'tbi_fragments: $tbi_fragments'
    echo 'tss_bases_flank: $tss_bases_flank'
    echo 'tss_col_strand_info: $tss_col_strand_info'
    echo 'smoothing_window_size: $smoothing_window_size'
    echo 'ls /usr/local/bin/'
    ls /usr/local/bin/
    echo 'TODO: uncomment when I have data to test on'
    ####python3 /usr/local/bin/$calculation_script $tbi_fragments $tss_bases_flank $tss_col_strand_info $task.cpus $regions
    touch ${tbi_fragments}.tss
    echo 'finished run_tss'
  """
}
