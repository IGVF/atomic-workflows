// Enable DSL2
nextflow.enable.dsl=2

// Define the process
// TODO: copy from merge_log docker where the conda envirnment is initiated when the container is executed
process scrna_calculate_qc_metrics {
  label 'scrna_qc_calculate'
  debug true
  input:
    val qc_python_script
    path anndata_file
    val subpool_val
  output:
    path 'sc_rna_qc_calculate.tsv', emit: rna_qc_metrics_tsv
  script:
  """
    # Print Conda environment
    echo "Conda environment: \$(conda info --env)"

    # Determine the script path
    script_path=\$(which $qc_python_script)
    echo "Script path: \$script_path"

    # Execute the Python script
    adata_file=$anndata_file
    subpool_arg="--subpool $subpool_val"  # Add --subpool argument
    echo "Adata path: \$adata_file"
    echo "Subpool argument: \$subpool_arg"

    # Print start of scrna_calculate_qc_metrics
    echo "Starting scrna_calculate_qc_metrics..."

    # Redirect detailed debugging information to a file
    detailed_debug_info="detailed_debug_info_rna_metrics.log"

    # Execute the Python script and capture the result file path
    result_file_path=\$(conda run -n rna_qc_env python \$script_path --adata \$adata_file \$subpool_arg > \$detailed_debug_info 2>&1)

    # Print the result file path
    echo "Result file path: \$result_file_path"

    # Print finish of scrna_calculate_qc_metrics
    echo "Finished scrna_calculate_qc_metrics."
  """
}
