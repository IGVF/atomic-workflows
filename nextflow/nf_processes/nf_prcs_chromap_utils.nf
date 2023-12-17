// Enable DSL2
nextflow.enable.dsl=2

process run_create_chromap_idx {
  label 'chromap_idx'
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

//-b ~{sep="," input.fastq_barcode}
process run_chromap_map_to_idx {
  label 'chromap_map_idx'
  debug true
  input:
    path chromap_idx
    path ref_fa
    tuple path(fastq1), path(fastq2), path(fastq3), path(spec_yaml),path(whitelist_file)
    val  chromap_trim_adaptor
  output:
    path "map_bed_file.bed", emit: chromap_map_bed_path
    path "summary_file.csv", emit: chromap_map_summary_mapping_statistics
    path "alignment_log", emit: chromap_map_alignment_log
  script:
    """
    echo $chromap_idx
    echo $ref_fa
    echo 'fastq1 is $fastq1'
    echo 'fastq2 is $fastq2'
    echo 'fastq3 is $fastq3'
    echo 'spec_yaml is $spec_yaml'
    echo 'chromap_trim_adaptor is $chromap_trim_adaptor'
    echo 'task.cpus is $task.cpus. should be 32. TODO: check what is the issue'
    chromap -x $chromap_idx -r $ref_fa -t ${task.cpus} -1 $fastq1 -2 $fastq3 -o map_bed_file.bed --summary summary_file.csv > alignment_log 2>&1
    echo 'finished run_chromap_map_to_idx'
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
