// Enable DSL2
nextflow.enable.dsl=2


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
    tuple path(fastq1), path(fastq2), path(fastq3), path(fastq4), path(barcode1_fastq), path(barcode2_fastq), path(spec_yaml), path(whitelist_file), val(subpool), path(barcode_conversion_dict_file), val(prefix)
  
  // Define output paths
  output:
    path "${chromap_filter_fragments_tsv}", emit: chromap_filter_fragments_tsv_pool_out
    path "${barcode_summary_csv}", emit: barcode_summary_csv_out_pool_out

  // Script section
  script:
  """
    echo 'start run_add_pool_prefix_to_fragment_table'
    echo 'input chromap_filter_fragments_tsv is $chromap_filter_fragments_tsv'
    echo 'input barcode_summary_csv is $barcode_summary_csv'
    if $subpool != "none"
      /usr/local/bin/$subpool_script $chromap_filter_fragments_tsv $barcode_summary_csv
    fi
    echo 'finished run_add_pool_prefix_to_fragment_table'
  """
}

process run_process_conversion_to_barcode {

  // Set debug to true
  debug true
  
  // Label the process as 'pool_prefix'
  label 'pool_dictionary'

  // Define input paths
  input:
    val subpool_script
    tuple path(fastq1), path(fastq2), path(fastq3), path(fastq4), path(barcode1_fastq), path(barcode2_fastq), path(spec_yaml), path(whitelist_file), val(subpool), path(barcode_conversion_dict_file), val(prefix)
    path barcode_summary_csv
  // Define output paths
  output:
    path temp_conversion, emit: temp_dict_conversion

  // Script section
  script:
  """
    echo 'start run_process_conversion_to_barcode'
    echo 'input barcode_summary_csv is $barcode_summary_csv'
    /usr/local/bin/$subpool_script $barcode_conversion_dict_file $subpool $barcode_summary_csv
    ls
    echo 'finished run_process_conversion_to_barcode'
  """
}


process run_filter_align_fragments {
  // Set debug to true
  debug true
  // Label the process as 'pool_prefix'
  label 'pool_filter'
  // Input parameters
  input:
    val filter_script
    path tempConversionOutput
    path barcodeFragmentsTsv
    val threshold
  // Output parameters
  output:
    path "no_singleton_bed.gz", emit:  no_singleton_bed_gz

  // Script to execute
  script:
  """
    echo 'start run_filter_align_fragments'
    echo 'input barcodeFragmentsTsv is $barcodeFragmentsTsv'
    /usr/local/bin/$filter_script $tempConversionOutput $barcodeFragmentsTsv $threshold no_singleton_bed.gz
    ls
    echo 'finished run_filter_align_fragments'
  """
}
