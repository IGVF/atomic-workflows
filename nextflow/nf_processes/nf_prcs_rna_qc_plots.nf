// Enable DSL2
nextflow.enable.dsl=2
//  //$gene_umi_plot_file_output
    
// TODO: the docker was updated. check the nf_prcs_atac_qc_plots.nf
// might need to add 
// script_path=\$(command -v $r_qc_plot_script)
//    echo "Script path: \$script_path"
//    echo "ls \$script_path"
    
process scrna_plot_qc_metrics_prcs {
  label 'scrna_qc_plot'
  debug true 
  input:
    val r_qc_plot_script
    val r_qc_plot_helper_script
    path rna_qc_metrics_tsv
    val umi_cutoff
    val gene_cutoff
    val umi_rank_plot_all_output
    val umi_rank_plot_top_output
    val gene_umi_plot_file_output
  output:
    path "umi_rank_plot_all_output.png", emit: umi_rank_plot_all
    path "umi_rank_plot_top_output.png", emit: umi_rank_plot_top
    path "gene_umi_plot_file_output.png", emit: gene_umi_plot_file
  script:
  """
    # Print start of scrna_plot_qc_metrics_prcs
    echo "Starting scrna_plot_qc_metrics_prcs..."
    
    # Print input values for validation
    echo "R QC Plot Script: $r_qc_plot_script"
    echo "R QC Plot Helper Script: $r_qc_plot_helper_script"
    echo "RNA QC Metrics TSV: $rna_qc_metrics_tsv"
    echo "UMI Cutoff: $umi_cutoff"
    echo "Gene Cutoff: $gene_cutoff"
    
    echo "UMI Rank Plot All Output: $umi_rank_plot_all_output"
    echo "UMI Rank Plot Top Output: $umi_rank_plot_top_output"
    echo "Gene UMI Plot File Output: $gene_umi_plot_file_output"
    
    # Determine the script path
    script_path=\$(which $r_qc_plot_script)
    echo "Script path: \$script_path"
  
    echo "Executing main script..."
    conda run -n rna_atac_plot_qc_env Rscript \$script_path $r_qc_plot_helper_script $rna_qc_metrics_tsv $umi_cutoff $gene_cutoff $umi_rank_plot_all_output $umi_rank_plot_top_output $gene_umi_plot_file_output
    # Print finish of scrna_plot_qc_metrics_prcs
    echo "Finished scrna_plot_qc_metrics_prcs."
  """
}
