version 1.0

# Import the sub-workflow for preprocessing the fastqs.
import "workflows/subwf_atac.wdl" as subwf_atac
import "workflows/subwf_cellatlas_rna.wdl" as subwf_rna
import "tasks/10x_task_preprocess.wdl" as preprocess_tenx
import "tasks/10x_create_barcode_mapping.wdl" as tenx_barcode_map
import "tasks/task_joint_qc.wdl" as joint_qc
#import "tasks/task_html_report.wdl" as html_report

# WDL workflow for SHARE-seq

workflow share {

    input {
        # Common inputs

        Boolean trim_fastqs = true
        Boolean dorcs_flag = true
        String chemistry
        String prefix
        String? subpool = "none"
        String? parse_strand
        String pipeline_modality = "full" # "full": run everything; "count_only": stops after producing fragment file and count matrix; "no_align": correct and trim raw fastqs.

        File genome_fasta

        File whitelists_tsv = 'gs://broad-buenrostro-pipeline-genome-annotations/whitelists/whitelists.tsv'
        File? whitelist
        File? whitelist_atac
        Array[File] whitelist_rna
        String? read_format
        
        File seqspec

        # ATAC-specific inputs
        Array[File] read1_atac
        Array[File] read2_atac
        Array[File] fastq_barcode
        Boolean count_only = false
        File? chrom_sizes
        File? atac_genome_index_tar
        File? tss_bed
        Int atac_barcode_offset
        String? barcode_tag = "CB"

        #Int? cpus_atac
        #Int? cutoff_atac = 100
        #Int? atac_mapq_threshold = 30


        # ATAC - Align
        #Int? atac_align_multimappers

        # ATAC - Filter
        ## Biological
        Int? atac_filter_minimum_fragments_cutoff = 1
        #Int? atac_filter_shift_plus = 4
        #Int? atac_filter_shift_minus = -4

        # RNA-specific inputs
        Array[File] read1_rna
        Array[File] read2_rna
        #Array[File] fastqs_rna

        File gtf
        File? idx_tar_rna

        String? gene_naming = "gene_name"

        # Joint qc
        Int remove_low_yielding_cells = 10

        File genome_tsv
        String? genome_name
    }

    Map[String, File] annotations = read_map(genome_tsv)
    String genome_name_ =  select_first([genome_name, annotations["genome_name"]])
    File idx_tar_atac_ = select_first([atac_genome_index_tar, annotations["bowtie2_idx_tar"]])
    File chrom_sizes_ = select_first([chrom_sizes, annotations["chrsz"]])
    File tss_bed_ = select_first([tss_bed, annotations["tss"]])

    File idx_tar_rna_ = select_first([idx_tar_rna, annotations["star_idx_tar"]])
    File gtf_ = select_first([gtf, annotations["genesgtf"]])

    Boolean process_atac = if length(read1_atac)>0 then true else false
    Boolean process_rna = if length(read1_rna)>0 then true else false

    Map[String, File] whitelists = read_map(whitelists_tsv)
    File? whitelist_ = if chemistry=='10x_multiome' then whitelist else select_first([whitelist, whitelists[chemistry]])
    #File? whitelist_rna_ = if chemistry=="10x_multiome" then select_first([whitelist_rna, whitelists["${chemistry}_rna"]]) else whitelist_rna
    File? whitelist_atac_ = if chemistry=="10x_multiome" then select_first([whitelist_atac, whitelists["${chemistry}_atac"]]) else whitelist_atac

    if ( chemistry != "shareseq" && chemistry != "parse" && process_atac) {
        call preprocess_tenx.preprocess_tenx as preprocess_tenx{
                input:
                    fastq_barcode = fastq_barcode[0],
                    whitelist = select_first([whitelist_atac, whitelist_atac_]),
                    chemistry = chemistry,
                    barcode_offset = atac_barcode_offset,
                    prefix = prefix
        }
        if ( chemistry == "10x_multiome" ){
            call tenx_barcode_map.mapping_tenx_barcodes as barcode_mapping{
                input:
                    whitelist_atac = select_first([whitelist_atac, whitelist_atac_]),
                    #whitelist_rna = select_first([whitelist_rna, whitelist_rna_, whitelist_]),
            }
        }
    }

    if ( process_rna ) {
        if ( read1_rna[0] != "" ) {
            call subwf_rna.wf_rna as rna{
                input:
                    read1 = read1_rna,
                    read2 = read2_rna,
                    seqspec = seqspec,
                    chemistry = chemistry,
                    genome_fasta = genome_fasta,
                    genome_gtf = gtf,
                    prefix = prefix,
                    subpool = subpool,
                    genome_name = genome_name_
            }
        }
    }

    if ( process_atac ) {
        if ( read1_atac[0] != "" ) {
            call subwf_atac.wf_atac as atac{
                input:
                    read1 = select_first([read1_atac]),
                    read2 = select_first([read2_atac]),
                    fastq_barcode = fastq_barcode,
                    chemistry = chemistry,
                    reference_fasta = genome_fasta,
                    subpool = subpool,
                    whitelist = select_first([whitelist_atac, whitelist_atac_, whitelist, whitelist_]),
                    trim_fastqs = trim_fastqs,
                    chrom_sizes = chrom_sizes_,
                    genome_index_tar = idx_tar_atac_,
                    tss_bed = tss_bed_,
                    prefix = prefix,
                    read_format = select_first([read_format, preprocess_tenx.tenx_barcode_complementation_out]),
                    genome_name = genome_name_,
                    barcode_conversion_dict = barcode_mapping.tenx_barcode_conversion_dict,
                    pipeline_modality = pipeline_modality
            }
        }
    }

    if ( process_atac && process_rna ) {
        if ( read1_atac[0] != "" && read1_rna[0] != "" ) {            
            if ( pipeline_modality != "no_align" ) {
                call joint_qc.joint_qc_plotting as joint_qc {
                    input:
                        atac_barcode_metadata = atac.atac_barcode_metadata,
                        rna_barcode_metadata = rna.rna_barcode_metadata,
                        prefix = prefix,
                        genome_name = genome_name_
                }
            }
        }
    }

    # if ( pipeline_modality != "no_align" ) {
    #     call html_report.html_report as html_report {
    #         input:
    #             prefix = prefix,
    #             atac_alignment_log = atac.share_atac_alignment_log,
    #             atac_percent_duplicates = atac.share_atac_percent_duplicates,
    #             rna_total_reads = rna.share_rna_total_reads,
    #             rna_aligned_uniquely = rna.share_rna_aligned_uniquely,
    #             rna_aligned_multimap = rna.share_rna_aligned_multimap,
    #             rna_unaligned = rna.share_rna_unaligned,
    #             rna_feature_reads = rna.share_rna_feature_reads,
    #             rna_duplicate_reads = rna.share_rna_duplicate_reads,

    #             ## JPEG files to be encoded and appended to html
    #             # RNA plots
    #             image_files = [joint_qc.joint_qc_plot, joint_qc.joint_density_plot, rna.share_rna_umi_barcode_rank_plot, rna.share_rna_gene_barcode_rank_plot, rna.share_rna_gene_umi_scatter_plot, rna.share_rna_seurat_raw_violin_plot, rna.share_rna_seurat_raw_qc_scatter_plot, rna.share_rna_seurat_filtered_violin_plot, rna.share_rna_seurat_filtered_qc_scatter_plot, rna.share_rna_seurat_variable_genes_plot, rna.share_rna_seurat_PCA_dim_loadings_plot, rna.share_rna_seurat_PCA_plot, rna.share_rna_seurat_heatmap_plot, rna.share_rna_seurat_jackstraw_plot, rna.share_rna_seurat_elbow_plot, rna.share_rna_seurat_umap_cluster_plot, rna.share_rna_seurat_umap_rna_count_plot, rna.share_rna_seurat_umap_gene_count_plot, rna.share_rna_seurat_umap_mito_plot, atac.share_atac_qc_barcode_rank_plot, atac.share_atac_qc_hist_plot, atac.share_atac_qc_tss_enrichment,  atac.share_atac_archr_raw_tss_enrichment, atac.share_atac_archr_filtered_tss_enrichment, atac.share_atac_archr_raw_fragment_size_plot, atac.share_atac_archr_filtered_fragment_size_plot, atac.share_atac_archr_umap_doublets, atac.share_atac_archr_umap_cluster_plot, atac.share_atac_archr_umap_doublets, atac.share_atac_archr_umap_num_frags_plot, atac.share_atac_archr_umap_tss_score_plot, atac.share_atac_archr_umap_frip_plot,atac.share_atac_archr_gene_heatmap_plot, dorcs.j_plot],

    #             ## Links to files and logs to append to end of html
    #             log_files = [rna.share_rna_alignment_log,  rna.share_task_starsolo_barcodes_stats, rna.share_task_starsolo_features_stats, rna.share_task_starsolo_summary_csv, rna.share_task_starsolo_umi_per_cell, rna.share_task_starsolo_raw_tar,rna.share_rna_seurat_notebook_log, atac.share_atac_alignment_log, atac.share_atac_archr_notebook_log, dorcs.dorcs_notebook_log]
    #     }
    # }

    output{
        # Fastq after correction/trimming
        Array[File]? atac_read1_processed = atac.atac_read1_processed
        Array[File]? atac_read2_processed = atac.atac_read2_processed

        Array[File]? rna_read1_processed = rna.rna_read1_processed
        Array[File]? rna_read2_processed = rna.rna_read2_processed

        # RNA outputs
        File? rna_kb_output = rna.rna_kb_output
        File? rna_count_matrix = rna.rna_count_matrix
        File? rna_log = rna.rna_log
        File? rna_barcode_metadata  = rna.rna_barcode_metadata
        
        # ATAC ouputs
        #File? share_atac_final_bam_dedup = atac.share_atac_filter_alignment_dedup
        File? atac_filter_fragments = atac.atac_fragments
        File? atac_filter_fragments_index = atac.atac_fragments_index
        File? atac_barcode_metadata = atac.atac_barcode_metadata

        # Joint outputs
        File? joint_barcode_metadata = joint_qc.joint_barcode_metadata

        # Report
        #File? html_summary = html_report.html_report_file
    }

}