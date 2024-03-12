// ATAC workflow
//include {} from './../../nf_processes/'
//include {run_synpase_download} from './../../nf_processes/nf_prcs_synapse_utils.nf'
//include {run_whitelist_gunzip} from './../../nf_processes/nf_prcs_gunzip.nf'
include {run_downloadFiles} from './../../nf_processes/nf_prcs_download_url_files.nf'
include {run_seqspec_print;run_seqspec_modify_atac} from './../../nf_processes/nf_prcs_seqspec_utils.nf'
include {run_create_chromap_idx;run_chromap_map_to_idx;run_chromap_test} from './../../nf_processes/nf_prcs_chromap_utils.nf'
include {run_process_create_temp_summary_dict;run_add_subpool_to_chromap_output} from './../../nf_processes/nf_prcs_subpool_summary_dict.nf'
include {run_filter_aligned_fragments_gz} from './../../nf_processes/nf_prcs_filter_by_dictionary_barcode.nf'
include {run_bgzip_on_chromap_fragments_output} from './../../nf_processes/nf_prcs_bgzip.nf'
include {run_tabix_on_sorted_bgzip_chromap;run_tabix_filtered_fragments_no_singleton} from './../../nf_processes/nf_prcs_tabix.nf'
include {run_merge_chromap_logs} from './../../nf_processes/nf_prcs_merge_logs.nf'
include {run_calculate_tss_enrichment_bulk;run_calculate_tss_enrichment_snapatac2} from './../../nf_processes/nf_prcs_tss.nf'
include {run_barcode_metadata_stats;run_atac_barcode_rank_plot} from './../../nf_processes/nf_prcs_atac_metadata_annoation_and_plot.nf'
include {run_atac_merge_barcode_metadata} from './../../nf_processes/nf_prcs_generate_merged_barcode_metadata.nf'
include {run_zcat} from './../../nf_processes/nf_prcs_zcat.nf'
include {run_gzip_on_genes_gtf} from './../../nf_processes/nf_prcs_gzip.nf'
include {run_generate_insert_size_histogram_data;run_generate_insert_size_plot} from './../../nf_processes/nf_prcs_atac_generate_insert_size_plot.nf'
include {run_sort_on_chromap_fragments_output} from './../../nf_processes/nf_prcs_sort_fragments_file.nf'

workflow {
  println params.FASTQS_SPEC_CH
  println params.ENV_SYNAPSE_TOKEN

  // This will wait for the time that we have the data from the synapse
  // synIds_ch = Channel.fromPath(params.SYNAPSE_IDS)
  //                    .splitCsv(header: true)
  //                    | map { record -> tuple(record.synid_idx,record.synid_fastq1,record.synid_fastq2) }
  //                    | view
  // run_synpase_download(synIds_ch,params.ENV_SYNAPSE_TOKEN)
    
  // STEP 1: input processing
  // R1_fastq_gz	R2_fastq_gz	R3_fastq_gz	R4_fastq_gz	barcode1_fastq_gz	barcode2_fastq_gz	spec	whitelist
  files_ch = Channel
    .fromPath( params.FASTQS_SPEC_CH )
    .splitCsv( header: true, sep: '\t')
    .map { row -> tuple( file(row.R1_fastq_gz), file(row.R2_fastq_gz), file(row.R3_fastq_gz), file(row.R4_fastq_gz),file(row.barcode1_fastq_gz),file(row.barcode2_fastq_gz),file(row.spec), file(row.whitelist),row.subpool,file(row.barcode_conversion_dict_file),row.prefix,row.prefix,row.seqspec_atac_region_id) }
    .set { sample_run_ch }

  // STEP 2: update seqspec file
  //  run_seqspec_modify_atac(params.EXECUTE_SEQSPEC_MODIFY,sample_run_ch)
  //  seqspec_modify_atac_out=run_seqspec_modify_atac.out.seqspec_modify_atac_out
  //  println ('after run_seqspec_modify_atac')

  // STEP 3: print spec file after update - seqspec_modify_atac_out
  // run_seqspec_print(run_seqspec_modify_atac.out.seqspec_modify_atac_out)
  // println ('after run_seqspec_print')
  
  //---------------- START OF GENOME FASTA FILE ----------------
  
  // STEP 4: download the genome FA
  genome_fasta_ch = channel.value(file(params.CHROMAP_GENOME_REFERENCE_FASTA))
  println ('after genome_fasta_ch')
  
  // STEP 4 - cont
  // zcat the reference genome input file that is used for index
  run_zcat(params.EXECUTE_ZCAT_SCRIPT,genome_fasta_ch)
  genome_fasta_zcat_out = run_zcat.out.zcat_file_out
  println ('after run_zcat ')
  
  //---------------- END OF GENOME FASTA FILE ----------------


  //---------------- START OF CHROMAP INDEX ----------------
  // STEP 5a: download chromap index - after it was created. useful when you want to skip the index
  // genome_chromap_idx = channel.value(file(params.CHROMAP_IDX))

  // STEP 5b: calculate the chromap index ///////////////////////////////////

  // Call chromap index with the output of the zcat
  run_create_chromap_idx(params.CHROMAP_CREATE_INDEX_SCRIPT,genome_fasta_zcat_out)
  genome_chromap_idx = run_create_chromap_idx.out.chromap_idx_out
  println ('after run_create_chromap_idx')
  
  //---------------- END OF CHROMAP INDEX ----------------
  
  
  //---------------- START OF CHROMAP MAPPING ----------------
  // STEP 6a:
  // TODO: replace this with task.cpus in the process. one the task.cpus works correctly with/without cache
  // TODO: check how more parameters options are passed
  run_chromap_map_to_idx(params.CHROMAP_MAP_TO_INDEX,sample_run_ch,genome_fasta_ch,genome_chromap_idx, params.CHROMAP_QUALITY_THRESHOLD, params.CHROMAP_DROP_REPETITIVE_READS, params.CHROMAP_READ_FORMAT, params.CHROMAP_BC_PROBABILITY_THRESHOLD, params.CHROMAP_BC_ERROR_THRESHOLD,params.CHROMAP_READ_LENGTH,params.CPUS_TO_USE_CHROMAP_IDX)
  chromap_fragments_tsv = run_chromap_map_to_idx.out.chromap_fragments_tsv_out
  chromap_barcode_summary_csv = run_chromap_map_to_idx.out.barcode_summary_csv_out
  chromap_alignment_log_out = run_chromap_map_to_idx.out.chromap_alignment_log_out
  println ('finished run_chromap_map_to_idx')

  // STEP 6b:  for debug: load the outputs:  
  // chromap_fragments_tsv = channel.value(file(params.chromap_fragments_tsv))
  // chromap_barcode_summary_csv = channel.value(file(params.barcode_summary_csv))
  // chromap_alignment_log_out = channel.value(file(params.chromap_alignment_log_out))
  // println ('after load chrompa mapping debug')
  //---------------- END OF CHROMAP MAPPING ----------------
  

  //---------------- START OF SUBPOOL ----------------
  // STEP 7: will check of none is in the subpool
run_add_subpool_to_chromap_output(params.TSV_ADD_SUBPOOL_SCRIPT,chromap_fragments_tsv,chromap_barcode_summary_csv,sample_run_ch)
  chromap_fragments_subpool_tsv = run_add_subpool_to_chromap_output.out.chromap_fragments_tsv_pool_out
  chromap_barcode_summary_subpool_csv = run_add_subpool_to_chromap_output.out.barcode_summary_csv_out_pool_out
  
  // STEP 8: call bgzip chromap_fragments_subpool_tsv
  println ('before call ')
  run_bgzip_on_chromap_fragments_output(params.EXECUTE_BGZIP_SCRIPT,chromap_fragments_subpool_tsv)
  bgzip_subpool_chromap_fragments_tsv_out = run_bgzip_on_chromap_fragments_output.out.bgzip_chromap_fragments_tsv_out
  println ('after call run_bgzip_on_chromap_fragments_output')
  
  //---------------- END OF SUBPOOL ----------------
  


  //---------------- START OF ATAC TSS ----------------
  
  // STEP 9: create a dictionary with the summary csv and the dictionary available
  println ('before run_process_create_temp_summary_dict')
  run_process_create_temp_summary_dict(params.CSV_ADD_SUBPOOL_SCRIPT,sample_run_ch,chromap_barcode_summary_csv)
  temp_summary_dict = run_process_create_temp_summary_dict.out.temp_summary_dict
  println ('after run_process_create_temp_summary_dict')
  
  // Debug 9 input - TODO: add sorted file before comtinuing
  // bgzip_subpool_chromap_fragments_tsv_out =  channel.value(file(params.bgzip_subpool_chromap_fragments_tsv_out))

  // STEP 10: enforce the dictionary based on the previous step dictionary udpate with fragments threashold
  println ('before run_filter_aligned_fragments_gz')
  run_filter_aligned_fragments_gz(temp_summary_dict,params.FILTER_FRAGMENTS_SCRIPT ,bgzip_subpool_chromap_fragments_tsv_out,params.ATAC_FRAGMENTS_MIN_FRAG_CUTOFF)
  no_singleton_bed_gz=run_filter_aligned_fragments_gz.out.no_singleton_bed_gz
  println ('after run_filter_aligned_fragments_gz')
  
  // debug 10: debug input - TODO: comment out. failed with the wdl output
  // no_singleton_bed_gz = channel.value(file(params.no_singleton_gz))
  
  
  // STEP 11: prepare genes.gtf file for run_calculate_tss_enrichment_snapatac2
  input_genes_gtf_ch = Channel.fromPath(file(params.ATAC_TSS_SNAPATAC2_GENES_GTF))
  run_gzip_on_genes_gtf(params.EXECUTE_GZIP_SCRIPT,input_genes_gtf_ch)
  genes_gtf_gzip_file_out = run_gzip_on_genes_gtf.out.genes_gtf_gzip_file_out
  println ('after run_gzip_on_genes_gtf')

  // STEP 12: TSS snapatac2
  println ('before call run_calculate_tss_enrichment_snapatac2')
  run_calculate_tss_enrichment_snapatac2(sample_run_ch,params.ATAC_TSS_SNAPATAC2_CALCULATION_SCRIPT,no_singleton_bed_gz,genes_gtf_gzip_file_out,params.ATAC_TSS_SNAPATAC2_MIN_FRAG_CUTOFF)
  snapatac_tss_fragments_stats_out = run_calculate_tss_enrichment_snapatac2.out.snapatac_tss_fragments_stats_out
  println ('after call run_calculate_tss_enrichment_snapatac2')

  // STEP 13: metadata stats - calculate_barcode_metadata_stats
  println ('before run_barcode_metadata_stats')
  run_barcode_metadata_stats(temp_summary_dict,snapatac_tss_fragments_stats_out,params.ATAC_SNAP_METADATA_STATS_SCRIPT)
  tmp_barcode_stats_out=run_barcode_metadata_stats.out.tmp_barcode_stats_out
  println ('after run_barcode_metadata_stats')

  // STEP 14: metadata stats barcode rank plot
  // snapatac_tss_fragments_stats_out this is being used as a template of the output name. will be added png at the code
  println ('before call run_atac_barcode_rank_plot')
  run_atac_barcode_rank_plot(params.ATAC_PLOT_METADATA_SCRIPT,params.ATAC_PLOT_METADATA_HELPER_SCRIPT,tmp_barcode_stats_out,params.ATAC_QC_FRAGMENT_CUTOFF,snapatac_tss_fragments_stats_out)
  println ('after run_atac_barcode_rank_plot')

  //---------------- END OF ATAC TSS ----------------
  
  
  
  //---------------- START OF INSERT SIZE ----------------
  
  // STEP 15: prepare insert data for the histogram
  print ("before run_generate_insert_size_histogram_data")
  run_generate_insert_size_histogram_data(params.CHROMAP_FRAGMENTS_HISTOGRAM_DATA_SCRIPT,no_singleton_bed_gz)
  histogram_data_file_out = run_generate_insert_size_histogram_data.out.histogram_data_file_out
  print ("after run_generate_insert_size_histogram_data")

  // STEP 16: run_generate_insert_size_plot 
  println ('before call run_generate_insert_size_plot')
  run_generate_insert_size_plot(params.ATAC_INSERT_SIZE_PLOT_SCRIPT,histogram_data_file_out,params.pkr_id)
  println ('after call run_generate_insert_size_plot')

  //---------------- END OF INSERT SIZE ----------------
  
  
  //---------------- START OF MERGE LOGS ----------------
  // STEP 17: merge chromap logs: log + summary_csv
  println ('before call run_merge_chromap_logs')
  run_merge_chromap_logs(params.CHROMAP_MERGE_LOGS_SCRIPT,chromap_alignment_log_out,chromap_barcode_summary_subpool_csv)
  println ('after call run_merge_chromap_logs')
  //---------------- END OF MERGE LOGS ----------------
  
  
  // ===============END===============================
  // ===============END===============================
  // ===============END===============================
  // ===============END===============================
  
}
  