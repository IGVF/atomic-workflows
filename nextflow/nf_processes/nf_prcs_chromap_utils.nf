// Enable DSL2
nextflow.enable.dsl=2

// path genome_chromap_idx,
//     path genome_fasta_zcat_out,
//     path barcode_whitelist_inclusion_list,
//     val CHROMAP_READ_LENGTH,
//     val CHROMAP_BC_ERROR_THRESHOLD,
//     val CHROMAP_BC_PROBABILITY_THRESHOLD,
//     val CHROMAP_READ_FORMAT,
//     val CHROMAP_DROP_REPETITIVE_READS,
//     path ref_fa,
//     val CHROMAP_QUALITY_THRESHOLD,

// echo 'genome_chromap_idx is $genome_chromap_idx'
//   echo 'genome_fasta_zcat_out is $genome_fasta_zcat_out'
//   echo 'barcode_whitelist_inclusion_list is $barcode_whitelist_inclusion_list'
//   echo 'CHROMAP_READ_LENGTH is $CHROMAP_READ_LENGTH'
//   echo 'CHROMAP_BC_ERROR_THRESHOLD is $CHROMAP_BC_ERROR_THRESHOLD'
//   echo 'CHROMAP_BC_PROBABILITY_THRESHOLD is $CHROMAP_BC_PROBABILITY_THRESHOLD'
//   echo 'CHROMAP_READ_FORMAT is $CHROMAP_READ_FORMAT'
//   echo 'CHROMAP_DROP_REPETITIVE_READS is $CHROMAP_DROP_REPETITIVE_READS'
//   echo 'ref_fa is $ref_fa'
//   echo 'CHROMAP_QUALITY_THRESHOLD is $CHROMAP_QUALITY_THRESHOLD'
// process run_chromap_map_to_idx {
//   label 'chromap_map_idx'
//   debug true
//   input:
//     tuple path(fastq1), path(fastq2), path(fastq_barcode), path(spec_yaml), path(whitelist_file)
//   output:
//     path "${fastq1.baseName}.atac.filter.fragments.tsv", emit: chromap_filter_fragments_tsv
//     path "${fastq1.baseName}.atac.align.barcode.summary.csv", emit: barcode_summary_csv

//   script:
//   """
  
//   echo 'fastq1 is $fastq1'
//   echo 'fastq2 is $fastq2'
//   echo 'fastq_barcode is $fastq_barcode'
//   echo 'task.cpus is $task.cpus. should be 32. TODO: check what is the issue'
  
//   echo 'finished run_chromap_map_to_idx'
//   """
// }

process run_chromap_map_to_idx {
  label 'chromap_map_idx'
  debug true
  script:
  """
  echo run_chromap_test
  chromap
  echo run_chromap_test_end
  """
}

process run_create_chromap_idx {
  label 'chromap_map_idx'
  debug true
  input: 
    path ref_fa 
  output:
    path "ref.index", emit: chromap_idx_out
  script:
  """
  echo 'run_create_chromap_idx'
  # create an index first and then map
  chromap -i -r $ref_fa -o ref.index
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
