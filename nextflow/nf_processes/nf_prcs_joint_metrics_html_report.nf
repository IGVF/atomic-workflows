// Enable DSL2
nextflow.enable.dsl=2

// enclosing variables within double quotes ensures that they are treated as a single argument,
// even if they contain spaces or special characters (See the python call in run_joint_metrics_html_report)
process run_joint_metrics_html_report {
  label 'joint_metrics_html_report'
  debug true 
  input:
    val script_name
    tuple path(rna_metrics), path(atac_metrics),path (image_files), path (log_files)
    
  output:
    path "html_report_file.html", emit: html_report_file_out
    path "csv_summary_file.csv", emit: csv_summary_file_out

  script:
  """
    # Print start of run_joint_metrics_html_report
    echo 'Starting run_joint_metrics_html_report...'

    # Determine the script path
    script_path=\$(command -v $script_name)
    echo "Script path: \$script_path"

    # Print parameters
    echo "RNA Metrics: $rna_metrics"
    echo "ATAC Metrics: $atac_metrics"
    echo "image_files: is $image_files"


    # Write image files to image_files.txt
    echo $image_files | tr ' ' '\n' > image_files.txt

    # Print the content of image_files.txt
    echo "Content of image_files.txt:"
    cat image_files.txt


    # Write log files to log_files.txt
    echo $log_files | tr ' ' '\n' > log_files.txt

    # Execute the Python script
    python3 \$script_path --atac_metric $atac_metrics --rna_metrics $rna_metrics html_report_file.html image_files.txt log_files.txt csv_summary_file.csv 

    # Print finish of run_joint_metrics_html_report
    echo 'Finished run_joint_metrics_html_report.'
  """
}
