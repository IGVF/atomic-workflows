// Enable DSL2
nextflow.enable.dsl=2

process run_filter_fragments {
  debug true
  label 'filter_fragments'
  input:
    val atac_and_pool_bash_script
    path fragments_file
    path barcode_conversion_dict_file
    val subpool_in
    path barcode_summary
    val fragments_cutoff
  output:
    path 'filtered_fragment_file.bed', emit: filtered_fragment_file_out
  script:
  """
  echo 'start run_filter_fragments'
  echo 'barcode_conversion_dict_file is $barcode_conversion_dict_file'
  echo 'atac_and_pool_bash_script is $atac_and_pool_bash_script'
  echo 'call to ls usr local bin'
  
  # Determine the script path
  script_path=\$(command -v $atac_and_pool_bash_script)
  echo "Script path: \$script_path"

  \$script_path $barcode_conversion_dict_file $subpool_in $barcode_summary $fragments_cutoff $fragments_file $task.cpus filtered_fragment_file.bed

  echo 'TODO:comment out when execute with real data'
  /usr/local/bin/create_sample_filtered_fragment_file.sh
  
  echo 'ls after the execution of the script'
  ls
  echo 'end run_filter_fragments'
  """
}
