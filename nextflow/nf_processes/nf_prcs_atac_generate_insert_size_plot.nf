// Enable DSL2
nextflow.enable.dsl=2

// Define the process
// TODO: copy from merge_log docker where the conda envirnment is initiated when the container is executed
process run_generate_insert_size_plot {
  label 'insert_size' // copy from tss_bulk
  debug true
  input:
    path calculation_script
    val qc_python_script
    path histogram_file
    val pkr_id //BMMC-single-donor
    path filtered_file
    path filtered_file_index
    path filtered_fragmented_file_tsv_gz // BMMC-single-donor.atac.filter.fragments.hg38.tsv.gz
    path filtered_fragmented_file_gz_tsv_index // BMMC-single-donor.atac.filter.fragments.hg38.tsv.gz.tbi
  output:
    path '${histogram_file.base_name}.png', emit: histogram_png_insert_size_out
    path '${histogram_file.base_name}.log.txt', emit:insert_size_log_txt
    path '${filtered_fragmented_file_gz.base_name}.log.txt', emit insert_log_txt
  script:
  """
    echo 'start run_generate_insert_size_plot'
    echo 'calculation_script is $calculation_script. check that it is: compute_tss_script.py'
    echo 'qc_python_script: $qc_python_script'
    echo 'histogram_file: $histogram_file'
    echo 'pkr_id: $pkr_id'

    insert_log_txt_file_name='${filtered_fragmented_file_gz.base_name}.log.txt'
    insert_log_png_file_name = '${histogram_file.base_name}.png'
    echo "insert_size" > $insert_log_txt_file_name
    awk '{print $3-$2}' <(zcat $filtered_fragmented_file_tsv_gz ) | sort --parallel 4 -n | uniq -c | awk -v OFS="\t" '{print $2,$1}' >> $insert_log_txt_file_name
    python3 /usr/local/bin/$calculation_script $insert_log_txt_file_name $pkr_id $insert_log_png_file_name

    sed 's/ /\t/g' > BMMC-single-donor.atac.qc.hg38.metadata.tsv

    head BMMC-single-donor.atac.qc.hg38.metadata.tsv
    head BMMC-single-donor.atac.qc.hg38.metadata.tsv | awk '{print NF}'
    echo 'finished run_generate_insert_size_plot'
  """
}
