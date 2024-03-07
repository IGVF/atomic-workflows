// Enable DSL2
nextflow.enable.dsl=2


process run_cellatlas_build {

  // Set debug to true
  debug true
  
  // Label the process as 'cellatlas'
  label 'cellatlas'

  // Define input parameters
  input:
    val script_name
    val modality
    path genome_fasta_gz
    path genes_gtf
    tuple path(fastq1), path(fastq2), path(spec_yaml), path(whitelist_file), val(seqspec_rna_region_id), val(subpool)

  // Define output files
  output:
    path 'cellatlas_out', emit: cellatlas_out
    path 'cellatlas_out/cellatlas_info.json', emit: cellatlas_run_info_out_json

  script:
  """
    echo 'calling cellatlas build'
    /usr/local/bin/$script_name cellatlas_out $modality $spec_yaml $genome_fasta_gz $genes_gtf $fastq1 $fastq2
    ls
  """
}

process run_jq_on_cellatlas {

  // Set debug to true
  debug true
  
  // Label the process as 'cellatlas'
  label 'jq'

  // Define input parameters
  input:
    val script_name
    path cellatlas_out_json

  // Define output files
  output:
    path 'jq_commands.txt', emit: jq_commands_out

  script:
  """
    echo 'calling run_jq_on_cellatlas'
    /usr/local/bin/$script_name $cellatlas_out_json
    ls
  """
}

