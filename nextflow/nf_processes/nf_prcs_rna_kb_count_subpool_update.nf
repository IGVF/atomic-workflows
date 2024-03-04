// Enable DSL2
nextflow.enable.dsl=2

process run_add_subpool_to_rna_kb_cout_outputs {

  // Set debug to true
  debug true
  
  // Label the process as 'pool_prefix'
  label 'pool_count'

  // Define input paths
  input:
    val subpool_script_modify_h5ad
    val subpool_script_cell_gene
    path kb_count_h5ad_file
    path kb_count_fragments_file
    tuple path(fastq1), path(fastq2),path(fastq3),path(fastq4),path(barcode1_fastq),path(barcode2_fastq), path(spec_yaml), path(whitelist_file),val(subpool),path(conversion_dict),val(prefix)
  
  output:
    path "${input_h5ad_file.baseName}_${suffix}.h5ad", emit: kb_count_h5ad_file_subpppl
    path "${kb_count_fragments_file.baseName}_${suffix}.txt", emit: kb_count_fragments_file_subpool

  // Script section
  script:
  """
    echo '------ Start run_add_subpool_to_rna_kb_cout_outputs ------'
    echo 'Input count_fragments_out is $count_fragments_out'
    echo 'Input subpool is $subpool'
    echo 'Input subpool_script is $subpool_script'
    parser.add_argument("input_h5ad_file", help="Path to the input h5ad file")
    parser.add_argument("suffix", help="Suffix to append")
    parser.add_argument("output_h5ad_file", help="Path to the output h5ad file")
    /usr/local/bin/$subpool_script_modify_h5ad --input_h5ad_file $kb_count_h5ad_file --suffix subpool --output_h5ad_file ${input_h5ad_file.baseName}_${suffix}.h5ad
    
    echo 'call for the update of the cells_x_genes.barcodes.txt'
    /usr/local/bin/$subpool_script_cell_gene $kb_count_fragments_file ${kb_count_fragments_file.baseName}_${suffix}.txt
    
    echo '------ Finished run_add_subpool_to_rna_kb_cout_outputs ------'
  """
}

