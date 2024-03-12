// Enable DSL2
nextflow.enable.dsl=2

process run_add_subpool_to_chromap_output {

  // Set debug to true
  debug true
  
  // Label the process as 'pool_prefix'
  label 'pool_fragments'

  // Define input paths
  input:
    val subpool_script
    path chromap_fragments_tsv
    path barcode_summary_csv
    tuple path(fastq1), path(fastq2),path(fastq3),path(fastq4),path(barcode1_fastq),path(barcode2_fastq), path(spec_yaml), path(whitelist_file),val(subpool),path(conversion_dict),val(prefix),val(seqspec_atac_region_id)
  
  // Define output paths
  // TODO: change the output name of the files with / without subpool - even if it is identical
  output:
    path "${chromap_fragments_tsv}", emit: chromap_fragments_tsv_pool_out
    path "${barcode_summary_csv}", emit: barcode_summary_csv_out_pool_out

  // Script section
  script:
  """
    echo '------ Start run_add_subpool_to_chrompap_output ------'
    echo 'Input chromap_fragments_tsv is $chromap_fragments_tsv'
    echo 'Input barcode_summary_csv is $barcode_summary_csv'
    echo 'Input subpool is $subpool'
    echo 'Input subpool_script is $subpool_script'
    if [ "$subpool" != "none" ]; then
      /usr/local/bin/$subpool_script $chromap_fragments_tsv $barcode_summary_csv
    else
      echo 'No subpool specified. Skipping subpool addition.'
    fi
    echo '------ Finished run_add_subpool_to_chrompap_output ------'
  """
}


process run_process_create_temp_summary_dict {

  // Set debug to true
  debug true
  
  // Label the process as 'pool_dictionary'
  label 'create_temp_summary_dict'

  // Define input paths
  input:
    val subpool_script
    tuple path(fastq1), path(fastq2), path(fastq3), path(fastq4), path(barcode1_fastq), path(barcode2_fastq), path(spec_yaml), path(whitelist_file), val(subpool), path(barcode_conversion_dict_file), val(prefix),val(seqspec_atac_region_id)
    path barcode_summary_csv
  // Define output paths
  output:
    path "temp_summary", emit:  temp_summary_dict

  // Script section
  script:
  """
    echo 'start run_process_create_temp_summary_dict'
    echo 'input barcode_summary_csv is $barcode_summary_csv'
    /usr/local/bin/$subpool_script $barcode_conversion_dict_file $subpool $barcode_summary_csv "temp_summary"
    wc -l temp_summary
    echo 'finished run_process_create_temp_summary_dict'
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

