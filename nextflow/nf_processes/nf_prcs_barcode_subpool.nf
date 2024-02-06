// Enable DSL2
nextflow.enable.dsl=2

// Define a channel to pass the file path between processes
temp_conversion_ch = file("temp_conversion")

process run_add_subpool_prefix_to_fragment_table {

  // Set debug to true
  debug true
  
  // Label the process as 'pool_prefix'
  label 'pool_fragments'

  // Define input paths
  input:
    val subpool_script
    path chromap_filter_fragments_tsv
    path barcode_summary_csv
    tuple path(fastq1), path(fastq2),path(fastq3),path(fastq4),path(barcode1_fastq),path(barcode2_fastq), path(spec_yaml), path(whitelist_file),val(subpool),path(conversion_dict),val(prefix)
  
  // Define output paths
  output:
    path "${chromap_filter_fragments_tsv}", emit: chromap_filter_fragments_tsv_pool_out
    path "${barcode_summary_csv}", emit: barcode_summary_csv_out_pool_out

  // Script section
  script:
  """
    echo '------ Start run_add_pool_prefix_to_fragment_table ------'
    echo 'Input chromap_filter_fragments_tsv is $chromap_filter_fragments_tsv'
    echo 'Input barcode_summary_csv is $barcode_summary_csv'
    echo 'Input subpool is $subpool'
    echo 'Input subpool_script is $subpool_script'
    if [ "$subpool" != "none" ]; then
      /usr/local/bin/$subpool_script $chromap_filter_fragments_tsv $barcode_summary_csv
    else
      echo 'No subpool specified. Skipping subpool addition.'
    fi
    echo '------ Finished run_add_pool_prefix_to_fragment_table ------'
  """
}


process run_process_conversion_to_barcode {

  // Set debug to true
  debug true
  
  // Label the process as 'pool_dictionary'
  label 'pool_dictionary'

  // Define input paths
  input:
    val subpool_script
    tuple path(fastq1), path(fastq2), path(fastq3), path(fastq4), path(barcode1_fastq), path(barcode2_fastq), path(spec_yaml), path(whitelist_file), val(subpool), path(barcode_conversion_dict_file), val(prefix)
    path barcode_summary_csv
  // Define output paths
  output:
    path "temp_conversion", emit:  temp_dict_conversion

  // Script section
  script:
  """
    echo 'start run_process_conversion_to_barcode'
    echo 'input barcode_summary_csv is $barcode_summary_csv'
    /usr/local/bin/$subpool_script $barcode_conversion_dict_file $subpool $barcode_summary_csv "temp_conversion"
    wc -l temp_conversion
    echo 'finished run_process_conversion_to_barcode'
  """
}

process run_filter_aligned_fragments {
  debug true
  label 'pool_filter'

  input:
    path temp_dict_conversion
    val filter_script
    path barcodeFragmentsTsv
    val threshold

  output:
    path "no-singleton.bed.gz", emit: no_singleton_bed_gz
    path tmp_file
  script:
  """
  echo 'start run_filter_aligned_fragments'
  echo 'input barcodeFragmentsTsv is $barcodeFragmentsTsv'
  echo 'input threshold is $threshold'
  echo 'input temp_dict_conversion is $temp_dict_conversion'

  echo '------ Number of barcodes BEFORE filtering------'
  wc -l $temp_dict_conversion

  echo '------ Filtering fragments ------'
  /usr/local/bin/$filter_script $threshold $temp_dict_conversion no-singleton.bed.gz $barcodeFragmentsTsv

  echo 'finished run_filter_aligned_fragments'
  """

}

