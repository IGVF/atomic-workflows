// Enable DSL2
nextflow.enable.dsl=2

//    path rna_metrics_file
//    path atac_metrics_file

process run_joint_barcode_cell_plotting {
  label 'joint_barcode_metadata_py'
  debug true 
  input:
    val script_name
    val pkr
    tuple path(rna_metrics_file), path(atac_metrics_file), path (barcode_metadata_file)
    val remove_low_yielding_cells
    val min_umis
    val min_genes
    val min_tss
    val min_frags
  output:
    path 'joint_barcode_cell_plotting.jpg', emit: joint_qc_plot_out
    path 'joint_cell_plotting.log', emit: joint_cell_plotting
  script:
  """
    # Print start of run_joint_barcode_cell_plotting
    echo "Starting run_joint_barcode_cell_plotting..."
    
    # Determine the script path
    script_path=\$(command -v $script_name)
    echo "Script path: \$script_path"

    echo "Parameters:"
    echo "- pkr: $pkr"
    echo "- rna_metrics_file: $rna_metrics_file"
    echo "- atac_metrics_file: $atac_metrics_file"
    echo "- remove_low_yielding_cells: $remove_low_yielding_cells"
    echo "- barcode_metadata_file: $barcode_metadata_file"
    echo "- min_umis: $min_umis"
    echo "- min_genes: $min_genes"
    echo "- min_tss: $min_tss"
    echo "- min_frags: $min_frags"

    python3 \$script_path --pkr $pkr --rna_metrics_file $rna_metrics_file --atac_metrics_file $atac_metrics_file --remove_low_yielding_cells $remove_low_yielding_cells --barcode_metadata_file $barcode_metadata_file --min_umis $min_umis --min_genes $min_genes --min_tss $min_tss --min_frags $min_frags --plot_file joint_barcode_cell_plotting.jpg

    echo 'Finished run_joint_barcode_cell_plotting.'
  """
}
