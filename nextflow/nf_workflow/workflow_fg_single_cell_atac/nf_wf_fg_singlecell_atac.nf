// ATAC workflow
//include {} from './../../nf_processes/'
//include {run_synpase_download} from './../../nf_processes/nf_prcs_synapse_utils.nf'
include {run_downloadFiles} from './../../nf_processes/nf_prcs_download_url_files.nf'
include {run_seqspec_print;run_seqspec_modify_atac} from './../../nf_processes/nf_prcs_seqspec_utils.nf'
include {run_create_chromap_idx;run_chromap_map_to_idx;run_chromap_test} from './../../nf_processes/nf_prcs_chromap_utils.nf'
include {run_bgzip} from './../../nf_processes/nf_prcs_bgzip.nf'
include {run_tabix;run_tabix_filtered_fragments} from './../../nf_processes/nf_prcs_tabix.nf'
include {run_merge_logs} from './../../nf_processes/nf_prcs_merge_logs.nf'
include {run_filter_fragments} from './../../nf_processes/nf_prcs_filter_fragments.nf'
include {run_calculate_tss_enrichment} from './../../nf_processes/nf_prcs_tss.nf'
include {run_scrna_atac_plot_qc_metrics} from './../../nf_processes/nf_prcs_atac_qc_plots.nf'
include {run_atac_barcode_metadata} from './../../nf_processes/nf_prcs_generate_barcode_metadata.nf'
include {run_atac_barcode_rank_plot} from './../../nf_processes/nf_prcs_atac_barcode_rank_plot.nf'

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
  files_ch = Channel
    .fromPath( params.FASTQS_SPEC_CH )
    .splitCsv( header: true, sep: '\t' )
    .map { row -> tuple( file(row.R1_fastq_gz), file(row.R2_fastq_gz), file(row.R3_fastq_gz), file(row.spec), file(row.whitelist)) }
    .set { sample_run_ch }

  // STEP 2: modify seqspec with the file names
  run_seqspec_modify_atac(sample_run_ch)
  println ('after run_seqspec_modify_atac')
  
  // STEP 3: print spec file after update - seqspec_modify_rna_out
  run_seqspec_print(run_seqspec_modify_atac.out.seqspec_modify_atac_out)
  println ('after run_seqspec_print')
  
  // STEP 4: run_chromap_test
  run_chromap_test()
  println ('after run_chromap_test')
  
  // STEP 5: download the genome FA
  genome_fasta_ch = channel.value(file(params.GENOME_FASTA))
  println ('after genome_fasta_ch')
  
  // STEP 6: download the geonme gtf
  genome_gtf_ch = channel.value(file(params.GENOME_GZ_GTF))
  println ('after genome_gtf_ch')
  
  // STEP 7a: download chromap index
  genome_chromap_idx = channel.value(file(params.CHROMAP_IDX))
  println ('after genome_chromap_idx download')
  
  // STEP 8: run_chromap_map_to_idx
  println ('chromap parameters')
  println params.CHROMAP_TRIM_ADAPTERS
  println params.CHROMAP_REMOVE_PCR_DUPLICATES
  println params.CHROMAP_REMOVE_PCR_DUPLICATES_AT_CELL_LEVEL
  println params.CHROMAP_TN5_SHIFT
  println params.CHROMAP_LOW_MEM
  println params.CHROMAP_BED
  println params.CHROMAP_MAX_INSERT_SIZE
  println params.CHROMAP_BC_ERROR_THRESHOLD
  println params.CHROMAP_BC_PROBABILITY_THRESHOLD
  println params.READ_FORMAT
  println params.DROP_REPETITIVE_THRESHOLD
  println params.MAPQ_THRESHOLD
  println params.BARCODE_TRANSLATE
  run_chromap_map_to_idx(genome_chromap_idx,genome_fasta_ch,sample_run_ch,params.CHROMAP_TRIM_ADAPTERS)
  println ('finished run_chromap_map_to_idx')
  // TODO: ADD SUBPOOL EXECUTION ON THE OUTPUT
  
  
  // STEP 9: call bgzip run_chromap_map_to_idx.out.chromap_map_bed_path
  println ('before call bgzip')
  println (run_chromap_map_to_idx.out.chromap_map_bed_path)
  run_bgzip(run_chromap_map_to_idx.out.chromap_map_bed_path)
  println ('after call bgzip')
  
  // STEP 10: call TABIX
  println params.RUN_TABIX_SCRIPT
  println ('before call run_tabix_fragment_file')
  run_tabix(params.RUN_TABIX_SCRIPT,run_bgzip.out.bgzip_fragments_out)
  println ('after call run_tabix_fragment_file')
  
  // STEP 11: merge logs
  // run_chromap_map_to_idx.out.chromap_map_alignment_log - chromap_alignment_log
  // run_chromap_map_to_idx.out.chromap_map_summary_mapping_statistics - chromap_barcode_log
  println ('before call run_merge_logs')
  run_merge_logs(run_chromap_map_to_idx.out.chromap_map_alignment_log,run_chromap_map_to_idx.out.chromap_map_summary_mapping_statistics)
  println ('after call run_merge_logs')
  
  // STEP 12: filter fragments
  println ('before call run_merge_logs')
  barcode_conversion_file_ch = channel.value(file(params.BARCODE_CONVERSION_DICT_FILE))
  
  println ('before call run_filter_fragments')
  run_filter_fragments(params.ATAC_BARCODE_AND_POOL,run_tabix.out.tbi_fragments_out,barcode_conversion_file_ch,params.SUBPOOL,run_chromap_map_to_idx.out.chromap_map_summary_mapping_statistics,params.ATAC_FRAGMENTS_CUTOFF)
  println ('after call run_filter_fragments')
  
  // STEP 13: run tabix to the output on the filter fragments
  println ('before call run_tabix for the second time with filtered_fragment_file_out')
  println run_filter_fragments.out.filtered_fragment_file_out
  run_tabix_filtered_fragments(params.RUN_TABIX_SCRIPT,run_filter_fragments.out.filtered_fragment_file_out)
  
  // STEP 14: run tss 
  println ('before call run_calculate_tss_enrichment')
  regions_ch = channel.value(file(params.ATAC_TSS_REGION_BED_FILE)) 
  println ('after regions_ch')
  run_calculate_tss_enrichment(params.ATAC_TSS_CALCULATION_SCRIPT,run_filter_fragments.out.filtered_fragment_file_out,run_tabix_filtered_fragments.out.tbi_fragments_out,regions_ch,params.ATAC_TSS_BASES_FLANK,params.ATAC_TSS_COL_WITH_STRANDS_INFO,params.ATAC_TSS_SMOOTHING_WINDOW_SIZE)
  println ('after call run_calculate_tss_enrichment')
  
  
  // STEP 15: run_scrna_atac_plot_qc_metrics
  println ('before call run_scrna_atac_plot_qc_metrics')
  barcode_metadata_file = channel.value(file(params.SC_ATAC_QC_BARCODE_METADATA_FILE))
  run_scrna_atac_plot_qc_metrics(params.SC_ATAC_QC_PLOT_SCRIPT,params.SC_ATAC_QC_PLOT_HELPER_SCRIPT,barcode_metadata_file,params.SC_ATAC_QC_FRAGMENT_CUTOFF,params.SC_ATAC_QC_BARCODE_OUTPUT_FILE)
  println ('after call run_scrna_atac_plot_qc_metrics')
  
  // STEP 16: Generate barcode metadata
  println ('before call run_generate_barcode_metadata')
  filtered_barcode_stats = channel.value(file(params.SC_ATAC_BARCODE_METADATA_FILTERED_BARCODE_STATS))
  tss_enrichment_barcode_stats = channel.value(file(params.SC_ATAC_BARCODE_METADATA_TSS_ENRICHMENT_BARCODE_STATS))
  run_atac_barcode_metadata(filtered_barcode_stats,tss_enrichment_barcode_stats,params.SC_ATAC_BARCODE_METADATA_SCRIPT)
  
  // STEP 17: Generate barcode rank plot
  println ('before call run_generate_barcode_rank_plot')
  run_atac_barcode_rank_plot(params.SC_ATAC_GENERATE_BARCODE_RANK_PLOT_SCRIPT,run_filter_fragments.out.filtered_fragment_file_out,params.SC_ATAC_GENERATE_BARCODE_RANK_PLOT_PKR)
  
 
}