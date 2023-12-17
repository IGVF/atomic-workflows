// Enable DSL2
nextflow.enable.dsl=2

process run_joint_cell_plotting_density {
  label 'joint_barcode_metadata_r'
  debug true 
  input:
    val script_name
    val pkr
    path barcode_metadata_file
  output:
    path "joint_density_plot.png", emit: joint_density_plot_file

  script:
  """
    # Print start of run_joint_cell_plotting_density
    echo 'Starting run_joint_cell_plotting_density...'

    # Determine the script path
    script_path=\$(command -v $script_name)
    echo "Script path: \$script_path"
    
    # execute R script
    echo 'Running R script...'
    Rscript \$script_path $pkr $barcode_metadata_file joint_density_plot.png

    echo 'TODO: Delete wehn you have real data '
    touch joint_density_plot.png
    # Print finish of run_joint_cell_plotting_density
    echo 'Finished run_joint_cell_plotting_density.'
  """
}
