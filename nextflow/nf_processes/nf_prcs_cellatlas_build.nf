// Enable DSL2
nextflow.enable.dsl=2

process run_cellatlas_build_full {
  debug true
  cpus 4
  cache 'lenient'
  container 'eilalan/atomic_update:latest'

  input:
    val modality
    val feature_barcodes
    val genome_fasta
    path genome_gtf
    path seqspec_yaml
    tuple val(sample_id), path(fastq1), path(fastq2)
    
  output:
    path '*_seqspec_out', emit: seqspec_out
    path 'rna_output', emit: cellatlas_built_rna_output
    path 'rna_alignment_log.json', emit: cellatlas_built_rna_align_log

  script:
  """
    # TODO: add random string to the sample_id (to avoid duplication in case the values are not unique)
    # we can thake the numbers from nextflow ID string
    echo "sample_id is $sample_id"
    echo "fastq1 is $fastq1"
    echo "fastq2 is $fastq2"
    echo "seqspec_yaml is $seqspec_yaml"
    echo "genome_gtf is $genome_gtf"
    echo "genome_fasta is $genome_fasta"
    echo "feature_barcodes is $feature_barcodes"

    # STEP 1: create sample_id_folder
    echo "STEP 2: create out folder "
    mkdir -p out/$sample_id
  
    echo "STEP 3: execute seqspec"
    seqspec print $seqspec_yaml > out/$sample_id/${sample_id}_seqspec_out

    echo "STEP 4: cellatlas"
    echo "cellatlas build -o out/$sample_id/ -m $modality -s $seqspec_yaml -fa $genome_fasta -g $genome_gtf -fb $feature_barcodes $fastq1 $fastq2"
    cellatlas build -o out/$sample_id/ -m $modality -s $seqspec_yaml -fa $genome_fasta -g $genome_gtf -fb $feature_barcodes $fastq1 $fastq2
    
    echo "STEP 5: jq commands"
    jq -r '.commands[] | values[] | join(";")' out/$sample_id/cellatlas_info.json > out/$sample_id/${sample_id}_jq_commands.txt
    chmod +x out/$sample_id/${sample_id}_jq_commands.txt
    echo "source out/$sample_id/${sample_id}_jq_commands.txt"
    source out/$sample_id/${sample_id}_jq_commands.txt

    echo "STEP 6: tree output"
    echo "out/$sample_id > out/$sample_id/${sample_id}_tree_output"
    tree out/$sample_id > out/$sample_id/${sample_id}_tree_output

    ls > 1_seqspec_out
    ls > rna_output
    ls > rna_alignment_log.json
  """
}


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
    tuple path(fastq1), path(fastq2), path(spec_yaml), path(whitelist_file), val(seqspec_rna_region_id)

  // Define output files
  output:
    path 'cellatlas_out', emit: cellatlas_out
    path 'cellatlas_out/cellatlas_info.json', emit: cellatlas_out_json

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

