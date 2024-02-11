// ATAC workflow
//include {} from './../../nf_processes/'
//include {run_synpase_download} from './../../nf_processes/nf_prcs_synapse_utils.nf'
include {run_downloadFiles} from './../../nf_processes/nf_prcs_download_url_files.nf'
include {run_seqspec_print;run_seqspec_modify_atac} from './../../nf_processes/nf_prcs_seqspec_utils.nf'
include {run_create_chromap_idx;run_chromap_map_to_idx;run_chromap_test} from './../../nf_processes/nf_prcs_chromap_utils.nf'
include {run_process_create_temp_summary_dict;run_add_subpool_to_chromap_output} from './../../nf_processes/nf_prcs_subpool_summary_dict.nf'
include {run_filter_aligned_fragments} from './../../nf_processes/nf_prcs_barcode_dictionary_filter.nf'
include {run_bgzip_on_chromap_fragments_output} from './../../nf_processes/nf_prcs_bgzip.nf'
include {run_tabix_chromap;run_tabix_filtered_fragments;run_tabix_no_singleton} from './../../nf_processes/nf_prcs_tabix.nf'
include {run_merge_chromap_logs} from './../../nf_processes/nf_prcs_merge_logs.nf'
include {run_calculate_tss_enrichment_bulk;run_calculate_tss_enrichment_snapatac2} from './../../nf_processes/nf_prcs_tss.nf'
include {run_barcode_metadata_stats;run_atac_barcode_rank_plot} from './../../nf_processes/nf_prcs_atac_metadata_annoation_and_plot.nf'
include {run_atac_merge_barcode_metadata} from './../../nf_processes/nf_prcs_generate_merged_barcode_metadata.nf'
include {run_zcat} from './../../nf_processes/nf_prcs_zcat.nf'
include {run_whitelist_gunzip} from './../../nf_processes/nf_prcs_gunzip.nf'
include {run_gzip_on_genes_gtf} from './../../nf_processes/nf_prcs_gzip.nf'
include {run_generate_insert_size_histogram_data;run_generate_insert_size_plot} from './../../nf_processes/nf_prcs_atac_generate_insert_size_plot.nf'

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
    .map { row -> tuple( file(row.R1_fastq_gz), file(row.R2_fastq_gz), file(row.R3_fastq_gz), file(row.R4_fastq_gz),file(row.barcode1_fastq_gz),file(row.barcode2_fastq_gz),file(row.spec), file(row.whitelist),row.subpool,file(row.barcode_conversion_dict_file),row.prefix) }
    .set { sample_run_ch }

  // STEP 2: print spec file after update - seqspec_modify_rna_out
  // run_seqspec_print(run_seqspec_modify_atac.out.seqspec_modify_atac_out)
  // println ('after run_seqspec_print')
  
  // STEP 3: download the genome FA
  genome_fasta_ch = channel.value(file(params.CHROMAP_GENOME_REFERENCE_FASTA))
  println ('after genome_fasta_ch')
  
  // STEP 3 - cont
  // zcat the reference genome input file that is used for index
  run_zcat(genome_fasta_ch)
  genome_fasta_zcat_out = run_zcat.out.zcat_file_out
  println ('after run_zcat ')

  // STEP 4a: download chromap index - after it was created. useful when you want to skip the index
  // genome_chromap_idx = channel.value(file(params.CHROMAP_IDX))

  // STEP 4b: calculate the chromap index ///////////////////////////////////

  // Call chromap index with the output of the zcat
  // run_create_chromap_idx(genome_fasta_zcat_out)
  // genome_chromap_idx = run_create_chromap_idx.out.chromap_idx_out
  // println ('after run_create_chromap_idx')
  // END STEP 4b
  

  // STEP 6a:
  // TODO: replace this with task.cpus in the process. one the task.cpus works correctly with/without cache
  // TODO: check how more parameters options are passed
  // run_chromap_map_to_idx(sample_run_ch,genome_fasta_ch,genome_chromap_idx, params.CHROMAP_QUALITY_THRESHOLD, params.CHROMAP_DROP_REPETITIVE_READS, params.CHROMAP_READ_FORMAT, params.CHROMAP_BC_PROBABILITY_THRESHOLD, params.CHROMAP_BC_ERROR_THRESHOLD,params.CHROMAP_READ_LENGTH,params.CPUS_TO_USE_CHROMAP_IDX)
  // chromap_fragments_tsv = run_chromap_map_to_idx.out.chromap_fragments_tsv_out
  // chromap_barcode_summary_csv = run_chromap_map_to_idx.out.barcode_summary_csv_out
  // chromap_alignment_log_out = run_chromap_map_to_idx.out.chromap_alignment_log_out
  // println ('finished run_chromap_map_to_idx')

  // STEP 6b:  for debug: load the outputs:  
  chromap_fragments_tsv = channel.value(file(params.chromap_fragments_tsv))
  chromap_barcode_summary_csv = channel.value(file(params.barcode_summary_csv))
  chromap_alignment_log_out = channel.value(file(params.chromap_alignment_log_out))
  println ('after load chrompa mapping debug')

  // STEP 7: will check of none is in the subpool
run_add_subpool_to_chromap_output(params.TSV_ADD_SUBPOOL_SCRIPT,chromap_fragments_tsv,chromap_barcode_summary_csv,sample_run_ch)
  chromap_fragments_subpool_tsv = run_add_subpool_to_chromap_output.out.chromap_fragments_tsv_pool_out
  chromap_barcode_summary_subpool_csv = run_add_subpool_to_chromap_output.out.barcode_summary_csv_out_pool_out

  // STEP 8: call bgzip chromap_fragments_tsv
  // println ('before call run_bgzip_on_chromap_fragments_output')
  // run_bgzip_on_chromap_fragments_output(chromap_fragments_subpool_tsv)
  // bgzip_subpool_chromap_fragments_tsv_out = run_bgzip_on_chromap_fragments_output.out.bgzip_chromap_fragments_tsv_out
  // println ('after call run_bgzip_on_chromap_fragments_output')
  
  // STEP 9: call TABIX bgzip_subpool_chromap_fragments_tsv_out
  // println ('before call run_tabix_chromap with tabix shell script')
  // run_tabix_chromap(params.RUN_TABIX_SCRIPT,bgzip_subpool_chromap_fragments_tsv_out)
  // tbi_bgzip_subpool_chromap_fragments_out = run_tabix_chromap.out.tbi_chromap_fragments_out
  // println ('after call run_tabix_chromap')
  

  // STEP 10: merge chromap logs: log + summary_csv
  // println ('before call run_merge_chromap_logs')
  // run_merge_chromap_logs(params.CHROMAP_MERGE_LOGS_SCRIPT,chromap_alignment_log_out,chromap_barcode_summary_subpool_csv)
  // println ('after call run_merge_chromap_logs')

  // STEP 11: create a dictionary with the summary csv and the dictionary available
  println ('before run_add_subpool_prefix_to_summary_file')
  run_process_create_temp_summary_dict(params.CSV_ADD_SUBPOOL_SCRIPT,sample_run_ch,chromap_barcode_summary_csv)
  temp_summary_dict = run_process_create_temp_summary_dict.out.temp_summary_dict
  println ('after run_add_subpool_prefix_to_summary_file')
  
  // Debug 12 input - TODO: commnent out
  bgzip_subpool_chromap_fragments_tsv_out =  channel.value(file(params.bgzip_subpool_chromap_fragments_tsv_out))

  // STEP 12: enforce the dictionary based on the previous step dictionary udpate with fragments threashold
  run_filter_aligned_fragments(temp_summary_dict,params.FILTER_FRAGMENTS_SCRIPT ,bgzip_subpool_chromap_fragments_tsv_out,params.ATAC_FRAGMENTS_MIN_FRAG_CUTOFF)
  no_singleton_bed_gz=run_filter_aligned_fragments.out.no_singleton_bed_gz
  
  // debug 13: debug input - TODO: comment out. failed with the wdl output
  // no_singleton_bed_gz = channel.value(file(params.no_singleton_gz))
  
  // STEP 13: run_tabix_no_singleton
  run_tabix_no_singleton(params.RUN_TABIX_SCRIPT,no_singleton_bed_gz)
  tbi_no_singleton_bed_gz_out=run_tabix_no_singleton.out.tbi_no_singleton_bed_gz_out
  
  // STEP 14: TSS- bulk run_calculate_tss_enrichment_bulk
  println ('before call run_calculate_tss_enrichment_bulk')
  regions_ch = channel.value(file(params.ATAC_TSS_REGION_BED_FILE)) 
  
  // debug - tbi_no_singleton_bed_gz_out TODO: comment
  // tbi_no_singleton_bed_gz_out=channel.value(file(params.tbi_no_singleton_bed_gz_out))
  
  //run_calculate_tss_enrichment_bulk(sample_run_ch,params.ATAC_TSS_BULK_CALCULATION_SCRIPT,tbi_no_singleton_bed_gz_out,regions_ch,params.ATAC_TSS_BASES_FLANK,params.ATAC_TSS_COL_WITH_STRANDS_INFO,params.ATAC_TSS_SMOOTHING_WINDOW_SIZE,params.CPUS_TO_USE_TSS)
  //tss_bulk_out = run_calculate_tss_enrichment_bulk.out.tss_bulk_out
  //println ('after call run_calculate_tss_enrichment_bulk')

  // STEP 17: prepare genes.gtf file for run_calculate_tss_enrichment_snapatac2
  input_genes_gtf_ch = Channel.fromPath(file(params.ATAC_TSS_SNAPATAC2_GENES_GTF))
  run_gzip_on_genes_gtf(input_genes_gtf_ch)
  genes_gtf_gzip_file_out = run_gzip_on_genes_gtf.out.genes_gtf_gzip_file_out
  println ('after run_gzip_on_genes_gtf')

  // STEP 18: TSS snapatac2
  println ('before call run_calculate_tss_enrichment_snapatac2')
  run_calculate_tss_enrichment_snapatac2(sample_run_ch,params.ATAC_TSS_SNAPATAC2_CALCULATION_SCRIPT,no_singleton_bed_gz,genes_gtf_gzip_file_out,params.ATAC_TSS_SNAPATAC2_MIN_FRAG_CUTOFF)
  snapatac_tss_fragments_stats_out = run_calculate_tss_enrichment_snapatac2.out.snapatac_tss_fragments_stats_out
  println ('after call run_calculate_tss_enrichment_snapatac2')

  // METADATA.
  // STEP 29
  println ('before run_barcode_metadata_stats')
  run_barcode_metadata_stats(temp_summary_dict,snapatac_tss_fragments_stats_out,params.ATAC_SNAP_METADATA_STATS_SCRIPT)
  tmp_barcode_stats_out=run_barcode_metadata_stats.out.tmp_barcode_stats_out
  println ('after run_barcode_metadata_stats')

  // STEP 20: Generate barcode rank plot
  // snapatac_tss_fragments_stats_out this is being used as a template of the output name. will be added png at the code
  // println ('before call run_atac_barcode_rank_plot')
  // run_atac_barcode_rank_plot(params.ATAC_PLOT_METADATA_SCRIPT,params.ATAC_PLOT_METADATA_HELPER_SCRIPT,tmp_barcode_stats_out,params.ATAC_QC_FRAGMENT_CUTOFF,snapatac_tss_fragments_stats_out)
  // println ('after run_atac_barcode_rank_plot')


  // bgzip_chromap_fragments_out
  // tbi_chromap_fragments_out
  // STEP 19: prepare data for the histogram
  // print ("before run_generate_insert_size_histogram_data")
  // run_generate_insert_size_histogram_data(params.CHROMAP_FRAGMENTS_HISTOGRAM_DATA_SCRIPT,bgzip_chromap_fragments_out)
  // histogram_data_file_out = run_generate_insert_size_histogram_data.out.histogram_data_file_out
  // print ("after run_generate_insert_size_histogram_data")

  // STEP 20: run_generate_insert_size_plot 
  // println ('before call run_generate_insert_size_plot')
  // pkr_id="BMM_PKR_ID"
  // run_generate_insert_size_plot(params.ATAC_INSERT_SIZE_PLOT_SCRIPT,histogram_data_file_out,pkr_id)
  // println ('after call run_generate_insert_size_plot')

  
  
  // ===============
  // STEP 12: prepare genes.gtf file
  // run_gzip_on_genes_gtf(params.ATAC_TSS_SNAPATAC2_GENES_GTF)
  // genes_gtf_gzip_file_out = run_gzip_on_genes_gtf.out.run_gzip_on_genes_gtf

  // STEP 11: filter fragments
  // println ('before call run_filter_fragments ')
  // TODO: need to split the subpool from the filter
  // run_filter_fragments(params.CSV_ADD_SUBPOOL_SCRIPT,tbi_chromap_fragments_out,barcode_conversion_file,subpoolValues,chromap_barcode_summary_csv,params.ATAC_FRAGMENTS_CUTOFF)
  // fragments_filter_out= run_filter_fragments.out.filtered_fragment_file_out
  // println ('after run_filter_fragments')
  
  // // STEP 11: merge logs
  // println ('before call run_merge_logs')
  // run_merge_logs(chromap_alignment_log_out,chromap_barcode_summary_csv)
  // println ('after call run_merge_logs')
  
  
  // // STEP 13: run tabix to the output on the filter fragments
  // println ('before call run_tabix_filtered_fragments for the second time with filtered_fragment_file_out')
  // run_tabix_filtered_fragments(params.RUN_TABIX_SCRIPT,no_singleton_bed_gz_out)
  // tbi_fragments_out= run_tabix_filtered_fragments.out.tbi_fragments_out
  // println ('after call run_tabix_filtered_fragments for filtered fragments')
  
  // // STEP 14: run tss 
  // println ('before call run_calculate_tss_enrichment_bulk')
  // regions_ch = channel.value(file(params.ATAC_TSS_REGION_BED_FILE)) 
  // CPUS_TO_USE_TSS=16
  // run_calculate_tss_enrichment_bulk(params.ATAC_TSS_BULK_CALCULATION_SCRIPT,no_singleton_bed_gz_out,tbi_fragments_out,regions_ch,params.ATAC_TSS_BASES_FLANK,params.ATAC_TSS_COL_WITH_STRANDS_INFO,params.ATAC_TSS_SMOOTHING_WINDOW_SIZE,prefix_str,CPUS_TO_USE_TSS)
  // tss_fragments_out = run_calculate_tss_enrichment_bulk.out.tss_fragments_out
  // println ('after call run_calculate_tss_enrichment_bulk')
  
  // // STEP 15: run tss snapatac2
  // println ('before call snapatac2')
  // // val calculation_script,path tbi_fragments,path gtf_file,val min_frag_cutoff
  // run_calculate_tss_enrichment_snapatac2(params.ATAC_TSS_SNAPATAC2_CALCULATION_SCRIPT,tbi_fragments_out,params.ATAC_TSS_SNAPATAC2_GENES_GTF,params.ATAC_TSS_SNAPATAC2_MIN_FRAG_CUTOFF,prefix_str)
  // println ('after call snapatac2')


  // STEP 16: run_scrna_atac_plot_qc_metrics - missing information to as Eugenio
  // println ('before call run_generate_insert_size_plot')
  // run_generate_insert_size_plot(params.ATAC_INSERT_SIZE_PLOT_SCRIPT)
  // println ('after call run_generate_insert_size_plot')
  

  // // STEP 16 - old: run_scrna_atac_plot_qc_metrics
  // println ('before call run_scrna_atac_plot_qc_metrics')
  // barcode_metadata_file = channel.value(file(params.SC_ATAC_QC_BARCODE_METADATA_FILE))
  //run_scrna_atac_plot_qc_metrics(params.SC_ATAC_QC_PLOT_SCRIPT,params.SC_ATAC_QC_PLOT_HELPER_SCRIPT,barcode_metadata_file,params.SC_ATAC_QC_FRAGMENT_CUTOFF,params.SC_ATAC_QC_BARCODE_OUTPUT_FILE)
  // println ('after call run_scrna_atac_plot_qc_metrics')
  
  // // STEP 17: Generate barcode metadata
  // println ('before call run_generate_barcode_metadata')
  // // filtered_barcode_stats = channel.value(file(params.SC_ATAC_BARCODE_METADATA_FILTERED_BARCODE_STATS))
  // //tss_enrichment_barcode_stats = channel.value(file(params.SC_ATAC_BARCODE_METADATA_TSS_ENRICHMENT_BARCODE_STATS))
  // // run_atac_barcode_metadata(filtered_barcode_stats,tss_enrichment_barcode_stats,params.SC_ATAC_BARCODE_METADATA_SCRIPT)
  
  // // STEP 18: Generate barcode rank plot
  // println ('before call run_generate_barcode_rank_plot')
  // //run_atac_barcode_rank_plot(params.SC_ATAC_GENERATE_BARCODE_RANK_PLOT_SCRIPT,run_filter_fragments.out.filtered_fragment_file_out,params.SC_ATAC_GENERATE_BARCODE_RANK_PLOT_PKR)
  
 
}// TODO: check the original WDL for the flow

  // // STEP 16: run_scrna_atac_plot_qc_metrics - missing information to as Eugenio
  // println ('before call run_generate_insert_size_plot')
  // run_generate_insert_size_plot(params.ATAC_INSERT_SIZE_PLOT_SCRIPT)
  // println ('after call run_generate_insert_size_plot')
  
  
  // // STEP 17: Generate barcode metadata
  // println ('before call run_generate_barcode_metadata')
  // // filtered_barcode_stats = channel.value(file(params.SC_ATAC_BARCODE_METADATA_FILTERED_BARCODE_STATS))
  // //tss_enrichment_barcode_stats = channel.value(file(params.SC_ATAC_BARCODE_METADATA_TSS_ENRICHMENT_BARCODE_STATS))
  // // run_atac_barcode_metadata(filtered_barcode_stats,tss_enrichment_barcode_stats,params.SC_ATAC_BARCODE_METADATA_SCRIPT)
  
  // // STEP 18: Generate barcode rank plot
  // println ('before call run_generate_barcode_rank_plot')
  // //run


  // Step 5: call gunzip for the whitelist. will not do a thing if it is not zipped
  // run_whitelist_gunzip(sample_run_ch)
  // barcode_whitelist_inclusion_list=run_whitelist_gunzip.out.whitelist_gunzip_inclusion_file_out
  // println ('after run_whitelist_gunzip')