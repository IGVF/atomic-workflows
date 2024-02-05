// Enable DSL2
nextflow.enable.dsl=2

process run_atac_merge_barcode_metadata {
  debug true
  label 'generate_barcode_metadata'
  input:
    path filtered_barcode_stats
    path tss_enrichment_barcode_stats
    val script_name
  output:
    path "barcode_merged_metadata.tsv", emit: barcode_merged_metadata_out
  script:
  """
    echo 'start run_atac_merge_barcode_metadata'
    # Determine the script path directly at the point of use
    script_path=\$(command -v $script_name)
    echo "Script path: \$script_path"
    \$script_path -i $filtered_barcode_stats -t $tss_enrichment_barcode_stats -o barcode_merged_metadata.tsv
    echo 'finished run_atac_merge_barcode_metadata'
  """
}
