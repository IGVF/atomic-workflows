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
    path "${fragment_rank_plot_file_output}", emit: fragment_rank_plot_file_output_file
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
    conda run -n rna_atac_plot_qc_env Rscript \$script_path $r_qc_plot_helper_script $barcode_metadata_file $fragment_cutoff $fragment_rank_plot_file_output
    
    # Print finish of scrna_atac_plot_qc_metrics_prcs
    echo 'Finished run_scrna_atac_plot_qc_metrics.'
  """
}

process run_barcode_metadata_stats {
  input:
    path temp_dict_conversion
    path snapatac_tss_fragments_stats_out
  output:
    path "tmp_barcode_stats", emit: tmp_barcode_stats_out
    path "barcodes_passing_threshold", emit: barcodes_passing_threshold
    path "${snapatac_tss_fragments_stats_out.baseName.replaceAll('tss_enrichment_barcode_stats', 'metadata')}.tsv", emit: snapatac_tss_fragments_barcode_metadata_out
  script:
  """
    echo 'run_barcode_metadata_stats'
  """
}


//  # Run the AWK and sed commands on temp_summary
//     # awk -v FS=',' -v OFS=" " 'NR==1{$1=$1;print $0,"unique","pct_dup","pct_unmapped";next}{$1=$1;if ($2-$3-$4-$5>0){print $0,($2-$3-$4-$5),$3/($2-$4-$5),($5+$4)/$2} else { print $0,0,0,0}}' $temp_summary | sed 's/ /\t/g' > tmp_barcode_stats

//     # OUTPUT from snapatac2-tss-enrichment.py (assuming a file named BMMC-single-donor.atac.qc.hg38.tss_enrichment_barcode_stats.tsv is generated)
//     # cut -f 1 $tss_enrichment_stats > barcodes_passing_threshold

//     # Join and calculate percentage reads
//     # join -j 1 <(cat $tss_enrichment_stats | (sed -u 1q;sort -k1,1)) <(grep -wFf barcodes_passing_threshold tmp_barcode_stats | (sed -u 1q;sort -k1,1)) | 
//     # awk -v FS=" " -v OFS=" " 'NR==1{print $0,"pct_reads_promoter"}NR>1{print $0,$4*100/$7}' | sed 's/ /\t/g' > BMMC-single-donor.atac.qc.hg38.metadata.tsv

