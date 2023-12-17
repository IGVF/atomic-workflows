// Enable DSL2
nextflow.enable.dsl=2

process run_joint_metrics_html_report {
  label 'joint_metrics_html_report'
  debug true 
  input:
    val script_name
    path atac_metrics
    path rna_metrics
    path image_files
    path log_files
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
    
    echo "~{sep=\"\\n\" $image_files}" > image_list.txt
    echo "~{sep=\"\\n\" $log_files}" > log_list.txt        
    
    echo "TODO: uncomment with data"
    python3 \$script_path html_report_file.html image_list.txt log_list.txt csv_summary_file.csv $atac_metrics $rna_metrics

    echo "TODO: delete these two commands"
    touch html_report_file.html
    touch csv_summary_file.csv
    # Print finish of run_joint_metrics_html_report
    echo 'Finished run_joint_metrics_html_report.'
  """
}
