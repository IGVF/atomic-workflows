include {run_joint_barcode_cell_plotting} from './../../nf_processes/nf_prcs_joint_barcode_cell_plotting.nf'
include {run_joint_cell_plotting_density} from './../../nf_processes/nf_prcs_joint_barcode_cell_plotting_density.nf'
include {run_joint_metrics_html_report} from './../../nf_processes/nf_prcs_joint_metrics_html_report.nf'



workflow {

  // JOIN QC
  // STEP 1: nf_prcs_joint_barcode_cell_plotting
  println "Before calling run_joint_barcode_cell_plotting"
  // step 1: load the rna and the atac qc files:
  // rna_metrics_ch = file(params.SC_JOINT_CELL_BARCODE_PLOT_RNA_METRICS)
  // atac_metrics_ch = file(params.SC_JOINT_CELL_BARCODE_PLOT_ATAC_METRICS)
  barcode_metadata_file_ch = Channel
    .fromPath( params.SC_JOINT_CELL_BARCODE_PLOT_METADATA_FILES )
    .splitCsv( header: true, sep: '\t')
    .map { row -> tuple( file(row.qc_rna), file(row.qc_atac), file(row.barcode_metadata_file)) }
    .set { sample_run_ch } 
  

  joint_qc_plot_out_ch = run_joint_barcode_cell_plotting(
    params.SC_JOINT_CELL_BARCODE_PLOT_SCRIPT_PY,
    params.SC_JOINT_CELL_BARCODE_PLOT_PKR,
    sample_run_ch,
    params.SC_JOINT_CELL_BARCODE_PLOT_REMOVE_LOW_YIELDING_CELLS,
    params.SC_JOINT_CELL_BARCODE_PLOT_MIN_UMIS,
    params.SC_JOINT_CELL_BARCODE_PLOT_MIN_GENES,
    params.SC_JOINT_CELL_BARCODE_PLOT_MIN_TSS,
    params.SC_JOINT_CELL_BARCODE_PLOT_MIN_FRAGS
  )

  //joint_qc_plot_out=run_joint_barcode_cell_plotting.out.joint_qc_plot_out
  //joint_cell_plotting=run_joint_barcode_cell_plotting.out.joint_cell_plotting
  println "After calling run_joint_barcode_cell_plotting"
  
  println "Before calling run_joint_cell_plotting_density"
  run_joint_cell_plotting_density(params.SC_JOINT_CELL_BARCODE_PLOT_SCRIPT_R, params.SC_JOINT_CELL_BARCODE_PLOT_PKR, sample_run_ch)
  println "After calling run_joint_cell_plotting_density"

  //joint_density_plot_file=run_joint_cell_plotting_density.out.joint_density_plot_file
  //html_logs_file_ch = Channel
  //  .fromPath( params.SC_JOINT_CELL_BARCODE_PLOT_HTML_FILES )
  //  .splitCsv( header: true, sep: '\t')
  //  .map { row -> tuple( file(row.rna_metrics_log), file(row.atac_metrics_log), row.image_list_files,row.log_list_files) }
  //  .set { sample_run_logs_ch }

  html_logs_file_ch = Channel
    .fromPath(params.SC_JOINT_CELL_BARCODE_PLOT_HTML_FILES)
    .splitCsv(header: true, sep: '\t')
    .map { row ->
        def imageFiles = file(row.image_list_files).text.split('\n').collect { it.trim() }
        def logFiles = file(row.log_list_files).text.split('\n').collect { it.trim() }
        tuple(file(row.rna_metrics_log), file(row.atac_metrics_log), imageFiles, logFiles)
    }
    .set { sample_run_logs_ch }



  
  println "Before run_joint_metrics_html_report"
  run_joint_metrics_html_report(params.SC_JOINT_CELL_BARCODE_PLOT_HTML_SCRIPT,sample_run_logs_ch)
  println "After run_joint_metrics_html_report"
}