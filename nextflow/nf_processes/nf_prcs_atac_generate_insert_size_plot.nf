// Enable DSL2
nextflow.enable.dsl=2

// Define the process
// TODO: copy from merge_log docker where the conda envirnment is initiated when the container is executed

// python3 \$script_path \$histogram_file_arg  \$pkr_arg \$out_file_arg
process run_generate_insert_size_plot {
  label 'plot_script'
  debug true
  input:
    path plot_script
    path histogram_file
    val pkr_id
  output:
    path "${histogram_file.base_name}.png", emit: histogram_png_insert_size_out
  script:
  """
    echo 'start run_generate_insert_size_plot'
    echo 'plot_script is $plot_script'
    echo 'histogram_file: $histogram_file'
    echo 'pkr_id: $pkr_id'

    python3 /usr/local/bin/$plot_script $histogram_file $pkr_id "${histogram_file.base_name}.png"
    echo 'finished run_generate_insert_size_plot'
  """
}


process run_generate_insert_size_histogram_data {
  label 'zcat_insert'
  debug true
  input:
    path script_name
    path in_chromap_bzip_fragments_tsv
  output:
    path "${in_chromap_bzip_fragments_tsv.baseName}.hist.hg38.log.txt", emit: histogram_data_file_out
  script:
  """
    echo 'start run_generate_insert_size_histogram_data'
    echo 'script_name is $script_name'
    echo 'in_chromap_bzip_fragments_tsv is $in_chromap_bzip_fragments_tsv'
    /usr/local/bin/$script_name $in_chromap_bzip_fragments_tsv "${in_chromap_bzip_fragments_tsv.baseName}.hist.hg38.log.txt"
    echo 'finished run_generate_insert_size_histogram_data'
  """
}

// process run_atac_barcode_rank_plot {
//   label 'atac_barcode_rank_plot'
//   debug true 
//   input:
//     val py_barcode_rank_plot_script
//     path filtered_fragment_file
//     val pkr 
//   output:
//     path "${filtered_fragment_file}.hist_log.png", emit: hist_log_png

//   script:
//   """
//     # Print start of run_atac_barcode_rank_plot
//     echo "Starting run_atac_barcode_rank_plot..."
    
//     # Determine the script path using backticks
//     script_path=\$(command -v $py_barcode_rank_plot_script)
//     echo "Script path: \$script_path"

//     # Execute the Python script
//     echo "Filtered fragment file path: $filtered_fragment_file"
//     histogram_file_arg="--histogram_file $filtered_fragment_file"
//     echo "histogram_file_arg val is: \$histogram_file_arg"
    
//     pkr_arg="--pkr $pkr"
//     echo "pkr_arg val is: \$pkr_arg"
    
//     out_file_arg="--out_file ${filtered_fragment_file}_hist_log.png"
//     echo "out_file_arg val is: \$out_file_arg"
    
//     # Execute the Python script and capture the result file path
//     python3 \$script_path \$histogram_file_arg  \$pkr_arg \$out_file_arg

//     echo 'TODO: remove the next line when running with real data'
//     touch ${filtered_fragment_file}.hist_log.png
    
//     # Print finish of run_atac_barcode_rank_plot
//     echo "Finished run_atac_barcode_rank_plot."
//   """
// }