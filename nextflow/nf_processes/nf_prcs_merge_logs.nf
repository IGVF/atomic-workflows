// Enable DSL2
nextflow.enable.dsl=2


process run_merge_logs {
  debug true
  label 'merge_log'
  input:
    path chromap_alignment_log
    path chromap_barcode_log
  output:
    path "merged_log.txt", emit: merged_logs_out
  script:
  """
    echo start run_merge_logs
    grep 'Number of' $chromap_alignment_log | grep -v threads| tr -d '.' | sed 's/ /_/g' | sed 's/:_/,/g'> merged_log.txt
    cat merged_log.txt
    echo ********1***********
    grep '#' $chromap_alignment_log  | sed 's/, /\n/g' | tr -d '# ' | sed 's/:/,/g' | tr -d '.' >> merged_log.txt
    echo ********2***********
    cat merged_log.txt
    awk -v FS=',' 'NR>1{unique+= \$2; dups+=\$3}END{printf "percentage_duplicates,%5.1f", 100*dups/(unique+dups)}' $chromap_barcode_log >> merged_log.txt
    echo ********3***********
    echo finished run_merge_logs
  """
}
