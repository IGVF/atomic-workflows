// Enable DSL2
nextflow.enable.dsl=2


process run_merge_chromap_logs {
  debug true
  label 'merge_log'
  input:
    val  script_name
    path chromap_alignment_log
    path chromap_barcode_log
  output:
    path "merged_log.txt", emit: merged_logs_out
  script:
  """
    echo start run_merge_logs
    echo 'input script_name is $script_name'
    echo 'input chromap_alignment_log is $chromap_alignment_log'
    echo 'input chromap_barcode_log is $chromap_barcode_log'
    ls /usr/local/bin/ > ls_files.txt
    /usr/local/bin/$script_name $chromap_alignment_log $chromap_barcode_log "merged_log.txt"
    echo finished run_merge_logs
  """
}
