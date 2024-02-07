// Enable DSL2
nextflow.enable.dsl=2
// # debug 
//     ##echo 'TODO: remove this from the code when you work with real data'
//     ##touch ${fragment_rank_plot_file_output}

process run_atac_barcode_rank_plot {
  label 'scrna_atac_plot'
  debug true 
  input:
    val r_qc_plot_script
    val r_qc_plot_helper_script
    path barcode_metadata_file 
    val fragment_cutoff
    val fragment_rank_plot_file_output
  output:
    path "${fragment_rank_plot_file_output.base_name}.png", emit: fragment_rank_plot_file_output_file
  script:
  """
    # Print start of run_scrna_atac_plot_qc_metrics
    echo 'Starting run_scrna_atac_plot_qc_metrics...'
    
    # Print input values for validation
    echo 'ATAC: R QC ATAC Plot Script: $r_qc_plot_script, probably scrna_plot_atac_qc_metrics.R'
    echo 'ATAC: R QC ATAC Plot Helper Script: $r_qc_plot_helper_script, probably barcode_rank_functions.R'
    echo 'ATAC: barcode_metadata_file: $barcode_metadata_file, probably barcode_metadata.txt'
    echo 'ATAC: fragment_cutoff: $fragment_cutoff'  # Typo fixed here
    echo 'ATAC: fragment_rank_plot_file_output: $fragment_rank_plot_file_output'  # Typo fixed here
    
    # Determine the script path directly at the point of use
    script_path=\$(command -v $r_qc_plot_script)
    echo "Script path: \$script_path"
    echo "ls \$script_path"
 
    # Run Rscript using conda
    echo 'Running conda command...'
    conda run -n rna_atac_plot_qc_env Rscript \$script_path $r_qc_plot_helper_script $barcode_metadata_file $fragment_cutoff ${fragment_rank_plot_file_output.base_name}
    
    # Print finish of scrna_atac_plot_qc_metrics_prcs
    echo 'Finished run_scrna_atac_plot_qc_metrics.'
  """
}

// process run_atac_barcode_rank_plot {
//   label 'scrna_atac_plot'
//   debug true 
//   input:
//     val r_qc_plot_script
//     val r_qc_plot_helper_script
//     path barcode_metadata_file 
//     val fragment_cutoff
//     val fragment_rank_plot_file_output
//   output:
//     path "${fragment_rank_plot_file_output.base_name}", emit: fragment_rank_plot_file_output_file
//   script:
//   """
//     # Print start of run_scrna_atac_plot_qc_metrics
//     echo 'Starting run_scrna_atac_plot_qc_metrics...'
    
//     # Print input values for validation
//     echo 'ATAC: R QC ATAC Plot Script: $r_qc_plot_script, probably scrna_plot_atac_qc_metrics.R'
//     echo 'ATAC: R QC ATAC Plot Helper Script: $r_qc_plot_helper_script, probably barcode_rank_functions.R'
//     echo 'ATAC: barcode_metadata_file: $barcode_metadata_file, probably barcode_metadata.txt'
//     echo 'ATAC: fragment_cutoff: $fragment_cutoff'
//     echo 'ATAC: fragment_rank_plot_file_output: $fragment_rank_plot_file_output'
    
//     # Determine the script path directly at the point of use
//     script_path=\$(command -v "$r_qc_plot_script")
//     echo "Script path: \$script_path"
 
//     # Run Rscript using conda
//     echo 'Running conda command...'
//     conda run -n rna_atac_plot_qc_env Rscript \$script_path "$r_qc_plot_helper_script" "$barcode_metadata_file" "$fragment_cutoff" "${fragment_rank_plot_file_output.base_name}"
    
//     # Print finish of scrna_atac_plot_qc_metrics_process
//     echo 'Finished run_scrna_atac_plot_qc_metrics.'
//   """
// }

// process run_atac_barcode_rank_plot {
//   label 'scrna_atac_plot'
//   debug true 
//   input:
//     val r_qc_plot_script
//     val r_qc_plot_helper_script
//     path barcode_metadata_file 
//     val fragment_cutoff
//     val fragment_rank_plot_file_output
//   output:
//     path "${fragment_rank_plot_file_output.base_name}", emit: fragment_rank_plot_file_output_file
//   script:
//   """
//     # Print start of run_scrna_atac_plot_qc_metrics
//     echo 'Starting run_scrna_atac_plot_qc_metrics...'
    
//     # Print input values for validation
//     echo 'ATAC: R QC ATAC Plot Script: $r_qc_plot_script, probably scrna_plot_atac_qc_metrics.R'
//     echo 'ATAC: R QC ATAC Plot Helper Script: $r_qc_plot_helper_script, probably barcode_rank_functions.R'
//     echo 'ATAC: barcode_metadata_file: $barcode_metadata_file, probably barcode_metadata.txt'
//     echo 'ATAC: fragment_cutoff: $fragment_cutoff'
//     echo 'ATAC: fragment_rank_plot_file_output: $fragment_rank_plot_file_output'
    
//     # Determine the script path directly at the point of use
//     script_path=\$(command -v "$r_qc_plot_script")
//     echo "Script path: \$script_path"
 
//     # Run Rscript using conda
//     echo 'Running conda command...'
//     conda run -n rna_atac_plot_qc_env Rscript \$script_path "$r_qc_plot_helper_script" "$barcode_metadata_file" "$fragment_cutoff" "${fragment_rank_plot_file_output.base_name}"
    
//     # Print finish of scrna_atac_plot_qc_metrics_process
//     echo 'Finished run_scrna_atac_plot_qc_metrics.'
//   """
// }



process run_barcode_metadata_stats {

  input:
    path temp_dict_conversion
    path tss_enrichment_barcode_stats
    val script_name
  output:
    path "tmp_barcode_stats", emit: tmp_barcode_stats_out
    path "barcodes_passing_threshold", emit: barcodes_passing_threshold

  script:
  """
    echo '------ START: Run Barcode Metadata Stats Script ------'
    /usr/local/bin/$script_name $temp_dict_conversion $tss_enrichment_barcode_stats tmp_barcode_stats barcodes_passing_threshold
    echo '------ FINISH: Run Barcode Metadata Stats Script ------'
  """
}