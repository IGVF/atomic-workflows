include {run_joint_barcode_cell_plotting} from './../../nf_processes/nf_prcs_joint_barcode_cell_plotting.nf'
include {run_joint_cell_plotting_density} from './../../nf_processes/nf_prcs_joint_barcode_cell_plotting_density.nf'
include {run_joint_metrics_html_report} from './../../nf_processes/nf_prcs_joint_metrics_html_report.nf'



workflow {

  // JOIN QC
  // STEP 1: nf_prcs_joint_barcode_cell_plotting
  println "Before calling run_joint_barcode_cell_plotting"
  rna_metrics_ch = file(params.SC_JOINT_CELL_BARCODE_PLOT_RNA_METRICS)
  atac_metrics_ch = file(params.SC_JOINT_CELL_BARCODE_PLOT_ATAC_METRICS)
  barcode_metadata_file_ch = file(params.SC_JOINT_CELL_BARCODE_PLOT_METADATA_FILE)
  println "RNA Metrics: $rna_metrics_ch"
  println "ATAC Metrics: $atac_metrics_ch"

  joint_qc_plot_out_ch = run_joint_barcode_cell_plotting(
    params.SC_JOINT_CELL_BARCODE_PLOT_SCRIPT_PY,
    params.SC_JOINT_CELL_BARCODE_PLOT_PKR,
    rna_metrics_ch,
    atac_metrics_ch,
    params.SC_JOINT_CELL_BARCODE_PLOT_REMOVE_LOW_YIELDING_CELLS,
    barcode_metadata_file_ch,
    params.SC_JOINT_CELL_BARCODE_PLOT_MIN_UMIS,
    params.SC_JOINT_CELL_BARCODE_PLOT_MIN_GENES,
    params.SC_JOINT_CELL_BARCODE_PLOT_MIN_TSS,
    params.SC_JOINT_CELL_BARCODE_PLOT_MIN_FRAGS
  )
  
  println "After calling run_joint_barcode_cell_plotting"
  
  println "Before calling run_joint_cell_plotting_density"
  run_joint_cell_plotting_density(params.SC_JOINT_CELL_BARCODE_PLOT_SCRIPT_R, params.SC_JOINT_CELL_BARCODE_PLOT_PKR, barcode_metadata_file_ch)
  println "After calling run_joint_cell_plotting_density"
  
  
  println "Before run_joint_metrics_html_report"
  html_atac_metrics_ch = file(params.SC_JOINT_CELL_BARCODE_PLOT_HTML_ATAC_METRICS)
  html_rna_metrics_ch = file(params.SC_JOINT_CELL_BARCODE_PLOT_HTML_RNA_METRICS)
  images_files_ch = file(params.SC_JOINT_CELL_BARCODE_PLOT_HTML_IMAGE_FILES)
  log_files_ch = file(params.SC_JOINT_CELL_BARCODE_PLOT_HTML_LOG_FILES)

  println "Before run_joint_metrics_html_report"
  run_joint_metrics_html_report(params.SC_JOINT_CELL_BARCODE_PLOT_HTML_SCRIPT,html_atac_metrics_ch,html_rna_metrics_ch,images_files_ch,log_files_ch)
  println "After run_joint_metrics_html_report"
}