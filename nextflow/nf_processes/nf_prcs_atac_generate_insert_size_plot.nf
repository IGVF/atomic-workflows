// Enable DSL2
nextflow.enable.dsl=2


process run_generate_insert_size_plot {
  label 'atac_insert_plot'
  debug true
  input:
    path plot_script
    path histogram_file
    val pkr_id
  output:
    path "${histogram_file.base_name}.png", emit: histogram_png_insert_size_out
    path "${histogram_file.base_name}.metadata.tsv", emit: histogram_metadata_tsv_insert_size_out
  script:
  """
    echo 'start run_generate_insert_size_plot'
    echo 'plot_script is $plot_script'
    echo 'histogram_file: $histogram_file'
    echo 'pkr_id: $pkr_id'
    
    ls > ls.txt
    ls /usr/local/bin/ > ls_bin.txt
    python /usr/local/bin/$plot_script --histogram_file $histogram_file --out_file "${histogram_file.base_name}.png" --pkr $pkr_id
    
    # Command 4
    echo "Formatting metadata..."
    sed 's/ /\t/g' > "${histogram_file.base_name}.metadata.tsv"

    # Command 5
    echo "Displaying the head of the metadata file..."
    head "${histogram_file.base_name}.metadata.tsv"

    # Command 6
    echo "Counting the fields in the metadata..."
    head "${histogram_file.base_name}.metadata.tsv" | awk '{print NF}'
    
    echo 'finished run_generate_insert_size_plot'
  """
}


process run_generate_insert_size_histogram_data {
  label 'zcat_insert'
  debug true
  input:
    val script_name
    path in_chromap_bzip_fragments_tsv
  output:
    path "${in_chromap_bzip_fragments_tsv.baseName}.hist.log.txt", emit: histogram_data_file_out
    path "ls_files.txt"
  script:
  """
    echo 'start run_generate_insert_size_histogram_data'
    echo 'script_name is $script_name'
    echo 'in_chromap_bzip_fragments_tsv is $in_chromap_bzip_fragments_tsv'
    /usr/local/bin/$script_name $in_chromap_bzip_fragments_tsv ${in_chromap_bzip_fragments_tsv.baseName}.hist.log.txt
    ls > ls_files.txt
    echo 'finished run_generate_insert_size_histogram_data'
  """
}
