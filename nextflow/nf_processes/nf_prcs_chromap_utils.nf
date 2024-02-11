// Enable DSL2
nextflow.enable.dsl=2

// # echo 'chromap mapping command: chromap -x ref.index --trim-adapters --remove-pcr-duplicates --remove-pcr-duplicates-at-cell-level --Tn5-shift --low-mem --BED -l 2000 --bc-error-threshold 2 --bc-probability-threshold 0.9 --read-format bc:0:-1,r1:0:-1,r2:0:-1 --drop-repetitive-reads 4 -x ref.index -r GCA_000001405.15_GRCh38_no_alt_analysis_set.fna.gz -q 0 -t 1 -1 BMMC_single_donor_ATAC_L001_R1_corrected_trimmed.fastq.gz,BMMC_single_donor_ATAC_L002_R1_corrected_trimmed.fastq.gz -2 BMMC_single_donor_ATAC_L001_R2_corrected_trimmed.fastq.gz,BMMC_single_donor_ATAC_L002_R2_corrected_trimmed.fastq.gz -b BMMC_single_donor_ATAC_L001_R1_corrected_barcode.fastq.gz,BMMC_single_donor_ATAC_L002_R1_corrected_barcode.fastq.gz --barcode-whitelist sai_192_whitelist -o BMMC_single_donor_ATAC_L001_R1_corrected_trimmed.fastq.atac.filter.fragments.tsv --summary BMMC_single_donor_ATAC_L001_R1_corrected_trimmed.fastq.atac.align.barcode.summary.csv'
  // # chromap -x ref.index --trim-adapters --remove-pcr-duplicates --remove-pcr-duplicates-at-cell-level --Tn5-shift --low-mem --BED -l 2000 --bc-error-threshold 2 --bc-probability-threshold 0.9 --read-format bc:0:-1,r1:0:-1,r2:0:-1 --drop-repetitive-reads 4 -x ref.index -r GCA_000001405.15_GRCh38_no_alt_analysis_set.fna.gz -q 0 -t 1 -1 BMMC_single_donor_ATAC_L001_R1_corrected_trimmed.fastq.gz,BMMC_single_donor_ATAC_L002_R1_corrected_trimmed.fastq.gz -2 BMMC_single_donor_ATAC_L001_R2_corrected_trimmed.fastq.gz,BMMC_single_donor_ATAC_L002_R2_corrected_trimmed.fastq.gz -b BMMC_single_donor_ATAC_L001_R1_corrected_barcode.fastq.gz,BMMC_single_donor_ATAC_L002_R1_corrected_barcode.fastq.gz --barcode-whitelist sai_192_whitelist -o BMMC_single_donor_ATAC_L001_R1_corrected_trimmed.fastq.atac.filter.fragments.tsv --summary BMMC_single_donor_ATAC_L001_R1_corrected_trimmed.fastq.atac.align.barcode.summary.csv
  // output:
  //   path "${fastq1.baseName}.atac.filter.fragments.tsv", emit: chromap_filter_fragments_tsv_out
  //   path "${fastq1.baseName}.atac.align.barcode.summary.csv", emit: barcode_summary_csv_out
// # chromap >> chromap_output.txt 2>&1
//   # chromap -x ref.index --trim-adapters --remove-pcr-duplicates --remove-pcr-duplicates-at-cell-level --Tn5-shift --low-mem --BED -l 2000 --bc-error-threshold 2 --bc-probability-threshold 0.9 --read-format bc:0:-1,r1:0:-1,r2:0:-1 --drop-repetitive-reads 4 -x ref.index -r GCA_000001405.15_GRCh38_no_alt_analysis_set.fna.gz -q 0 -t 16 -1 BMMC_single_donor_ATAC_L001_R1_corrected_trimmed.fastq.gz,BMMC_single_donor_ATAC_L002_R1_corrected_trimmed.fastq.gz -2 BMMC_single_donor_ATAC_L001_R2_corrected_trimmed.fastq.gz,BMMC_single_donor_ATAC_L002_R2_corrected_trimmed.fastq.gz -b BMMC_single_donor_ATAC_L001_R1_corrected_barcode.fastq.gz,BMMC_single_donor_ATAC_L002_R1_corrected_barcode.fastq.gz --barcode-whitelist sai_192_whitelist.txt -o BMMC_single_donor_ATAC_L001_R1_corrected_trimmed.fastq.atac.filter.fragments.tsv --summary BMMC_single_donor_ATAC_L001_R1_corrected_trimmed.fastq.atac.align.barcode.summary.csv >> chromap_output.txt 2>&1
//   # chromap -x $genome_chromap_idx -r $genome_fasta -1 BMMC_single_donor_ATAC_L001_R1_corrected_barcode.fastq.gz -t 8 --SAM -o alignment.sam
//   # chromap -x $genome_chromap_idx --trim-adapters --remove-pcr-duplicates --remove-pcr-duplicates-at-cell-level --Tn5-shift --low-mem --BED -l $CHROMAP_READ_LENGTH --bc-error-threshold $CHROMAP_BC_ERROR_THRESHOLD --bc-probability-threshold $CHROMAP_BC_PROBABILITY_THRESHOLD --read-format $CHROMAP_READ_FORMAT --drop-repetitive-reads $CHROMAP_DROP_REPETITIVE_READS -x $genome_chromap_idx -r $genome_fasta -q $CHROMAP_QUALITY_THRESHOLD -t 1 -1 $fastq1,$fastq2 -2 $fastq3,$fastq4 -b $barcode1_fastq,$barcode2_fastq --barcode-whitelist $whitelist_file -o ${fastq1.baseName}.atac.filter.fragments.tsv --summary ${fastq1.baseName}.atac.align.barcode.summary.csv >> chromap_output.txt 2>&1
//   ls
  // #chromap_cmd =  'chromap -x ref.index --trim-adapters --remove-pcr-duplicates --remove-pcr-duplicates-at-cell-level --Tn5-shift --low-mem --BED -l 2000 --bc-error-threshold 2 --bc-probability-threshold 0.9 --read-format bc:0:-1,r1:0:-1,r2:0:-1 --drop-repetitive-reads 4 -x ref.index -r GCA_000001405.15_GRCh38_no_alt_analysis_set.fna.gz -q 0 -t \${numCpus} -1 BMMC_single_donor_ATAC_L001_R1_corrected_trimmed.fastq.gz,BMMC_single_donor_ATAC_L002_R1_corrected_trimmed.fastq.gz -2 BMMC_single_donor_ATAC_L001_R2_corrected_trimmed.fastq.gz,BMMC_single_donor_ATAC_L002_R2_corrected_trimmed.fastq.gz -b BMMC_single_donor_ATAC_L001_R1_corrected_barcode.fastq.gz,BMMC_single_donor_ATAC_L002_R1_corrected_barcode.fastq.gz --barcode-whitelist sai_192_whitelist.txt -o BMMC_single_donor_ATAC_L001_R1_corrected_trimmed.fastq.atac.filter.fragments.tsv --summary BMMC_single_donor_ATAC_L001_R1_corrected_trimmed.fastq.atac.align.barcode.summary.csv'
  //   #chromap_cmd="chromap mapping command: chromap -x \$genome_chromap_idx --trim-adapters --remove-pcr-duplicates --remove-pcr-duplicates-at-cell-level --Tn5-shift --low-mem --BED -l \$CHROMAP_READ_LENGTH --bc-error-threshold \$CHROMAP_BC_ERROR_THRESHOLD --bc-probability-threshold \$CHROMAP_BC_PROBABILITY_THRESHOLD --read-format \$CHROMAP_READ_FORMAT --drop-repetitive-reads \$CHROMAP_DROP_REPETITIVE_READS -x \$genome_chromap_idx -r \$genome_fasta -q \$CHROMAP_QUALITY_THRESHOLD -t \$numCpus -1 \$fastq1,\$fastq2 -2 \$fastq3,\$fastq4 -b \$barcode1_fastq,\$barcode2_fastq --barcode-whitelist \$whitelist_file -o \${fastq1.baseName}.atac.filter.fragments.tsv --summary \${fastq1.baseName}.atac.align.barcode.summary.csv"

  // #echo "chromap mapping command: \${chromap_cmd}"
  // #\${chromap_cmd} >> chromap_output.txt 2>&1
process run_chromap_map_to_idx {
  label 'chromap_map_idx'
  debug true
  input:
    // tuple: R1_fastq_gz	R2_fastq_gz	R3_fastq_gz	R4_fastq_gz	barcode1_fastq_gz	barcode2_fastq_gz	spec	whitelist
    tuple path(fastq1), path(fastq2),path(fastq3),path(fastq4),path(barcode1_fastq),path(barcode2_fastq), path(spec_yaml), path(whitelist_file),val(subpool),path(conversion_dict),val(prefix)
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
    path "${prefix}.atac.filter.fragments.tsv", emit: chromap_filter_fragments_tsv_out
    path "${prefix}.atac.align.barcode.summary.csv", emit: barcode_summary_csv_out
    path "${prefix}.atac.align.k4.hg38.log.txt", emit: chromap_alignment_log_out
    path "ls_input.txt"
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
  
  ls > ls_input.txt
  echo 'start chromap execution'
  chromap -x $genome_chromap_idx --trim-adapters --remove-pcr-duplicates --remove-pcr-duplicates-at-cell-level --Tn5-shift --low-mem --BED -l $CHROMAP_READ_LENGTH --bc-error-threshold $CHROMAP_BC_ERROR_THRESHOLD --bc-probability-threshold $CHROMAP_BC_PROBABILITY_THRESHOLD --read-format $CHROMAP_READ_FORMAT --drop-repetitive-reads $CHROMAP_DROP_REPETITIVE_READS -r $genome_fasta -q $CHROMAP_QUALITY_THRESHOLD -t $CPUS_TO_USE -1 $fastq1,$fastq2 -2 $fastq3,$fastq4 -b $barcode1_fastq,$barcode2_fastq --barcode-whitelist $whitelist_file -o ${prefix}.atac.filter.fragments.tsv --summary ${prefix}.atac.align.barcode.summary.csv > ${prefix}.atac.align.k4.hg38.log.txt 2>&1
  echo 'finished run_chromap_map_to_idx'
  """
}

// process run_process_conversion_to_barcode {

  // Set debug to true
//   debug true
  
  // Label the process as 'pool_prefix'
//   label 'pool_prefix'

  // Define input paths
//   input:
//     val subpool_script
//     path barcode_conversion_file
//     val subpool_str
//     val barcode_summary_csv
  
  // Define output paths
//   output:
//     path "${barcode_summary_csv}", emit: barcode_summary_csv_out_pool_out

  // Script section
//   script:
//   """
//     echo 'start run_add_subpool_prefix_to_summary_file'
//     echo 'input barcode_summary_csv is $barcode_summary_csv'
//     /usr/local/bin/$subpool_script $barcode_conversion_file $subpool_str $barcode_summary_csv
 //    ls
//     echo 'finished run_add_subpool_prefix_to_summary_file'
//   """
// }

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
    # time chromap -i -r <(zcat /cromwell_root/fc-secure-0a879173-62d3-4c3a-8fc3-e35ee4248901/annotations/human/GCA_000001405.15_GRCh38_no_alt_analysis_set.fna.gz) -o chromap_index/index
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
