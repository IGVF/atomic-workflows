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
    tuple path(fastq1), path(fastq2), path(spec_yaml), path(whitelist_file), val(seqspec_rna_region_id), val(subpool)

  output:
    path "${kb_count_h5ad_file.baseName}_${subpool}.h5ad", emit: kb_count_h5ad_file_subpool
    path "${kb_count_fragments_file.baseName}_${subpool}.txt", emit: kb_count_fragments_file_subpool

  // Declare variables used in the output section
  script:
  """

    echo '------ Start run_add_subpool_to_rna_kb_cout_outputs ------'
    echo 'Input subpool_script_modify_h5ad: $subpool_script_modify_h5ad'
    echo 'Input subpool_script_cell_gene: $subpool_script_cell_gene'
    echo 'Input kb_count_h5ad_file: $kb_count_h5ad_file'
    echo 'Input kb_count_fragments_file: $kb_count_fragments_file'
    echo 'Input fastq1: $fastq1'
    echo 'Input fastq2: $fastq2'
    echo 'Input spec_yaml: $spec_yaml'
    echo 'Input whitelist_file: $whitelist_file'
    echo 'Input seqspec_rna_region_id: $seqspec_rna_region_id'
    echo 'Input subpool: $subpool'

    /usr/local/bin/$subpool_script_modify_h5ad $kb_count_h5ad_file $subpool ${kb_count_h5ad_file.baseName}_${subpool}.h5ad
    
    echo 'Output H5AD file: ${kb_count_h5ad_file.baseName}_${subpool}.h5ad'
    echo 'Output Fragments file: ${kb_count_fragments_file.baseName}_${subpool}.txt'

    # <filename> <subpool> <output_file_subpool>
    /usr/local/bin/$subpool_script_cell_gene $kb_count_fragments_file $subpool ${kb_count_fragments_file.baseName}_${subpool}.txt

    echo '------ Finished run_add_subpool_to_rna_kb_cout_outputs ------'
  """
}
