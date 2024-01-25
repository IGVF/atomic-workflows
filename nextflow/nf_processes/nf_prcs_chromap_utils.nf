// Enable DSL2
nextflow.enable.dsl=2

// chromap -x chromap_index/index --trim-adapters --remove-pcr-duplicates --remove-pcr-duplicates-at-cell-level --Tn5-shift  \
//         --low-mem  \
//         --BED  \
//         -l $CHROMAP_READ_LENGTH \
//         --bc-error-threshold $CHROMAP_BC_ERROR_THRESHOLD \
//         --bc-probability-threshold $CHROMAP_BC_PROBABILITY_THRESHOLD \
//         --read-format $CHROMAP_READ_FORMAT \
//         --drop-repetitive-reads $CHROMAP_DROP_REPETITIVE_READS \
//         -x chromap_index/index \
//         -r $genome_fasta
//         -q $CHROMAP_QUALITY_THRESHOLD \
//         -t $task.cpus \
//         -1 $fastq1,$fastq2 \
//         -2 $fastq3,$fastq4 \
//         -b $barcode1_fastq,$barcode2_fastq \
//         --barcode-whitelist $barcode_whitelist_inclusion_list \
//          \
//         -o out.atac.filter.fragments.hg38.tsv \
//         --summary out.atac.align.k4.hg38.barcode.summary.csv


///   
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
// tuple path(fastq1), path(fastq2), path(fastq_barcode), path(spec_yaml), path(whitelist_file)

process run_chromap_map_to_idx {
  label 'chromap_map_idx'
  debug true
  input:
    // R1_fastq_gz	R2_fastq_gz	R3_fastq_gz	R4_fastq_gz	barcode1_fastq_gz	barcode2_fastq_gz	spec	whitelist
    tuple path(fastq1), path(fastq2),path(fastq3),path(fastq4),path(barcode1_fastq),path(barcode2_fastq), path(spec_yaml), path(whitelist_file)
    path genome_fasta
    path genome_chromap_idx
    path genome_fasta_zcat
    path barcode_whitelist_inclusion_list
    val CHROMAP_QUALITY_THRESHOLD
    val CHROMAP_DROP_REPETITIVE_READS
    val CHROMAP_READ_FORMAT
    val CHROMAP_BC_PROBABILITY_THRESHOLD
    val CHROMAP_BC_ERROR_THRESHOLD
    val CHROMAP_READ_LENGTH
  output:
    path "${fastq1.baseName}.atac.filter.fragments.tsv", emit: chromap_filter_fragments_tsv_out
    path "${fastq1.baseName}.atac.align.barcode.summary.csv", emit: barcode_summary_csv_out

  script:
  """
  echo run_chromap_map_to_idx
  echo 'fastq1 is $fastq1'
  echo 'fastq2 is $fastq2'
  echo 'fastq3 is $fastq3'
  echo 'fastq4 is $fastq4'
  echo 'barcode1_fastq is $barcode1_fastq'
  echo 'barcode2_fastq is $barcode2_fastq'
  echo 'genome_fasta is $genome_fasta'
  echo 'genome_chromap_idx is $genome_chromap_idx'
  echo 'genome_fasta_zcat_out is $genome_fasta_zcat'
  echo 'barcode_whitelist_inclusion_list is $barcode_whitelist_inclusion_list'
  echo 'CHROMAP_READ_LENGTH is $CHROMAP_READ_LENGTH'
  echo 'CHROMAP_BC_ERROR_THRESHOLD is $CHROMAP_BC_ERROR_THRESHOLD'
  echo 'CHROMAP_BC_PROBABILITY_THRESHOLD is $CHROMAP_BC_PROBABILITY_THRESHOLD'
  echo 'CHROMAP_READ_FORMAT is $CHROMAP_READ_FORMAT'
  echo 'CHROMAP_DROP_REPETITIVE_READS is $CHROMAP_DROP_REPETITIVE_READS'
  echo 'CHROMAP_QUALITY_THRESHOLD is $CHROMAP_QUALITY_THRESHOLD'
  echo 'task.cpus is $task.cpus. should be 32. TODO: check what is the issue'
  # Run chromap command
  chromap -x chromap_index/index --trim-adapters --remove-pcr-duplicates --remove-pcr-duplicates-at-cell-level --Tn5-shift --low-mem --BED  \
        -l $CHROMAP_READ_LENGTH --bc-error-threshold $CHROMAP_BC_ERROR_THRESHOLD --bc-probability-threshold $CHROMAP_BC_PROBABILITY_THRESHOLD \
        --read-format $CHROMAP_READ_FORMAT --drop-repetitive-reads $CHROMAP_DROP_REPETITIVE_READS \
        -x chromap_index/index -r $genome_fasta -q $CHROMAP_QUALITY_THRESHOLD -t $task.cpus \
        -1 $fastq1,$fastq2 \
        -2 $fastq3,$fastq4 \
        -b $barcode1_fastq,$barcode2_fastq \
        --barcode-whitelist $barcode_whitelist_inclusion_list \
         \
        -o ${fastq1.baseName}.atac.filter.fragments.tsv \
        --summary ${fastq1.baseName}.atac.align.barcode.summary.csv

  # Create placeholder output files
  # touch '${fastq1.baseName}.atac.filter.fragments.tsv'
  # touch '${fastq1.baseName}.atac.align.barcode.summary.csv'
  echo run_chromap_map_to_idx
  """
}

process run_add_pool_prefix {

  // Set debug to true
  debug true
  
  // Label the process as 'pool_prefix'
  label 'pool_prefix'

  // Define input paths
  input:
    tuple path(fastq1), path(fastq2), path(fastq3), path(fastq4), path(barcode1_fastq), path(barcode2_fastq), path(spec_yaml), path(whitelist_file), val (pool_prefix)
    val chromap_filter_fragments_tsv
    val barcode_summary_csv

  // Define output paths
  output:
    path "${chromap_filter_fragments_tsv.baseName}.pool.tsv", emit: chromap_filter_fragments_tsv_pool_out
    path "${barcode_summary_csv.baseName}.pool.tsv", emit: barcode_summary_csv_out_pool_out

  // Script section
  script:
  """
    echo 'start run_add_pool_prefix'
    echo 'update the 4th column to have the subpool value'
    
    awk -v OFS="\t" -v subpool='$pool_prefix' '{$4=$4"_"subpool; print $0}' ${chromap_filter_fragments_tsv} > temp
    mv temp '${chromap_filter_fragments_tsv.baseName}.pool.tsv'

    awk -v FS="," -v OFS="," -v subpool='$pool_prefix' 'NR==1{print $0;next}{$1=$1"_"subpool; print $0}' ${barcode_summary_csv} > temp
    mv temp '${barcode_summary_csv.baseName}.pool.tsv'
    
    echo 'Finished run_add_pool_prefix'
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
