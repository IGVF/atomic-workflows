// Enable DSL2
nextflow.enable.dsl=2


process run_chromap_map_to_idx {
  label 'chromap_map_idx'
  debug true
  input:
    val script_name
    tuple path(fastq1), path(fastq2),path(fastq3),path(fastq4),path(barcode1_fastq),path(barcode2_fastq), path(spec_yaml), path(whitelist_file),val(subpool),path(conversion_dict),val(prefix),val(seqspec_atac_region_id)
    path genome_fasta
    path genome_chromap_idx
    val CHROMAP_QUALITY_THRESHOLD
    val CHROMAP_DROP_REPETITIVE_READS
    val CHROMAP_READ_FORMAT
    val CHROMAP_BC_PROBABILITY_THRESHOLD
    val CHROMAP_BC_ERROR_THRESHOLD
    val CHROMAP_READ_LENGTH
    val CPUS_TO_USE
  output:
    path "${prefix}.atac.filter.fragments.tsv", emit: chromap_fragments_tsv_out
    path "${prefix}.atac.align.barcode.summary.csv", emit: barcode_summary_csv_out
    path "${prefix}.atac.align.k4.hg38.log.txt", emit: chromap_alignment_log_out
  script:
  """
  echo 'start run_chromap_map_to_idx'
  echo 'fastq1 is $fastq1'
  echo 'fastq2 is $fastq2'
  echo 'fastq3 is $fastq3'
  echo 'fastq4 is $fastq4'
  echo 'barcode1_fastq is $barcode1_fastq'
  echo 'barcode2_fastq is $barcode2_fastq'
  echo 'genome_fasta is $genome_fasta'
  echo 'genome_chromap_idx is $genome_chromap_idx'
  echo 'CHROMAP_READ_LENGTH is $CHROMAP_READ_LENGTH'
  echo 'CHROMAP_BC_ERROR_THRESHOLD is $CHROMAP_BC_ERROR_THRESHOLD'
  echo 'CHROMAP_BC_PROBABILITY_THRESHOLD is $CHROMAP_BC_PROBABILITY_THRESHOLD'
  echo 'CHROMAP_READ_FORMAT is $CHROMAP_READ_FORMAT'
  echo 'CHROMAP_DROP_REPETITIVE_READS is $CHROMAP_DROP_REPETITIVE_READS'
  echo 'CHROMAP_QUALITY_THRESHOLD is $CHROMAP_QUALITY_THRESHOLD'
  echo 'whitelist_file is $whitelist_file'
  echo 'CPUS_TO_USE is $CPUS_TO_USE'
  echo 'prefix is $prefix'
  echo 'tsv is ${prefix}.atac.filter.fragments.tsv'
  echo 'csv is ${prefix}.atac.align.barcode.summary.csv'
  echo 'log out is ${prefix}.atac.align.k4.hg38.log.txt'
  
  /usr/local/bin/$script_name $fastq1 $fastq2 $fastq3 $fastq4 $barcode1_fastq $barcode2_fastq $genome_fasta $genome_chromap_idx $CHROMAP_READ_LENGTH $CHROMAP_BC_ERROR_THRESHOLD $CHROMAP_BC_PROBABILITY_THRESHOLD $CHROMAP_READ_FORMAT $CHROMAP_DROP_REPETITIVE_READS $CHROMAP_QUALITY_THRESHOLD $whitelist_file $CPUS_TO_USE $prefix

  echo 'finished run_chromap_map_to_idx'
  """
}

process run_create_chromap_idx {
  label 'chromap_map_idx'
  debug true
  input: 
    val script_name
    path ref_fa
  output:
    path "ref.index", emit: chromap_idx_out
  script:
  """
    echo 'run_create_chromap_idx'
    # create an index first and then map
    /usr/local/bin/$script_name $ref_fa ref.index
  """
}

process run_chromap_test {
  label 'chromap_local'
  debug true
  script:
  """
  echo run_chromap_test
  chromap
  echo run_chromap_test_end
  """
}
