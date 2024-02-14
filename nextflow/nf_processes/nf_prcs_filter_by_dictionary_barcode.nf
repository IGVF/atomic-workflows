// Enable DSL2
nextflow.enable.dsl=2

process run_filter_aligned_fragments_gz {
  debug true
  label 'filter_dictionary_sort'

  input:
    path temp_summary_dict
    val filter_script
    path barcodeFragmentsTsvGz
    val threshold

  output:
    path "no-singleton.bed.gz", emit: no_singleton_bed_gz
  script:
  """
  echo 'start run_filter_aligned_fragments_sort_gz'
  echo 'input barcodeFragmentsTsvGz is $barcodeFragmentsTsvGz'
  echo 'input threshold is $threshold'
  echo 'input temp_summary_dict is $temp_summary_dict'
  
  echo '------ Number of barcodes BEFORE filtering------'
  wc -l $temp_summary_dict

  echo '------ Filtering fragments ------'
  /usr/local/bin/$filter_script $threshold $temp_summary_dict no-singleton.bed.gz $barcodeFragmentsTsvGz

  echo 'finished run_filter_aligned_fragments_sort_gz'
  """

}

