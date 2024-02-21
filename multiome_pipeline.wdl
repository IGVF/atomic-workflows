version 1.0

# Import the sub-workflow for preprocessing the fastqs.
import "tasks/task_check_inputs.wdl" as check_inputs
import "workflows/subwf_atac.wdl" as subwf_atac
import "workflows/subwf_rna.wdl" as subwf_rna
import "tasks/10x_task_preprocess.wdl" as preprocess_tenx
import "tasks/10x_create_barcode_mapping.wdl" as tenx_barcode_map
import "tasks/task_joint_qc.wdl" as joint_qc
import "tasks/task_html_report.wdl" as html_report

# WDL workflow for SHARE-seq

workflow multiome_pipeline {

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
        
        Array[String] whitelist_atac
        Array[String] whitelist_rna
        
        Array[String] seqspecs

        # ATAC-specific inputs
        Array[String] read1_atac
        Array[String] read2_atac
        Array[String] fastq_barcode
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
        String? read_format = "bc:0:-1,r1:0:-1,r2:0:-1"
        Int? atac_filter_minimum_fragments_cutoff = 1
        #Int? atac_filter_shift_plus = 4
        #Int? atac_filter_shift_minus = -4

        # RNA-specific inputs
        Array[String] read1_rna
        Array[String] read2_rna
        File? gtf

        # Joint qc
        Int remove_low_yielding_cells = 10

        File genome_tsv
        String? genome_name
    }

    Map[String, File] annotations = read_map(genome_tsv)
    String genome_name_ =  select_first([ genome_name, annotations["genome_name"]])
    File idx_tar_atac_ = select_first([atac_genome_index_tar, annotations["bowtie2_idx_tar"]])
    File chrom_sizes_ = select_first([chrom_sizes, annotations["chrsz"]])
    File tss_bed_ = select_first([tss_bed, annotations["tss"]])
    File gtf_ = select_first([gtf, annotations["genesgtf"]])

    Boolean process_atac = if length(read1_atac)>0 then true else false
    Boolean process_rna = if length(read1_rna)>0 then true else false
    
    scatter(file in whitelist_atac){
        call check_inputs.check_inputs as check_whitelist_atac{
            input:
                path = file
        }
    }
      
    #could not coerce Array[File] to File?
    Array[File] whitelists_atac_ = select_first([ check_whitelist_atac.output_file, whitelist_atac ])
    File whitelist_atac_ = whitelists_atac_[0]

    scatter(file in whitelist_rna){
        call check_inputs.check_inputs as check_whitelist_rna{
            input:
                path = file
        }
    }
    
    #could not coerce Array[File] to File?
    Array[File] whitelists_rna_ = select_first([ check_whitelist_rna.output_file, whitelist_rna ])
    File whitelist_rna_ = whitelists_rna_[0]
    
    #ATAC Read1
    scatter(file in read1_atac){
        call check_inputs.check_inputs as check_read1_atac{
            input:
                path = file
        }
    }
    
    Array[File] read1_atac_ = select_first([ check_read1_atac.output_file, read1_atac ])
    
    scatter(file in read2_atac){
        call check_inputs.check_inputs as check_read2_atac{
            input:
                path = file
        }
    }
    
    Array[File] read2_atac_ = select_first([ check_read2_atac.output_file, read2_atac ])
    
     scatter(file in fastq_barcode){
        call check_inputs.check_inputs as check_fastq_barcode{
            input:
                path = file
        }
    }
    
    Array[File] fastq_barcode_ = select_first([ check_fastq_barcode.output_file, fastq_barcode ])
    
    scatter(file in read1_rna){
        call check_inputs.check_inputs as check_read1_rna{
            input:
                path = file
        }
    }
    
    Array[File] read1_rna_ = select_first([ check_read1_rna.output_file, read1_rna ])
    
    scatter(file in read2_rna){
        call check_inputs.check_inputs as check_read2_rna{
            input:
                path = file
        }
    }
    
    Array[File] read2_rna_ = select_first([ check_read2_rna.output_file, read2_rna ])
    
    
    #will be updated when changing atac? 
    if ( chemistry != "shareseq" && chemistry != "parse" && process_atac) {
        call preprocess_tenx.preprocess_tenx as preprocess_tenx{
                input:
                    fastq_barcode = fastq_barcode[0],
                    #whitelist = select_first([whitelist_atac, whitelist_atac_]),
                    whitelist = whitelist_atac_,
                    chemistry = chemistry,
                    barcode_offset = atac_barcode_offset,
                    prefix = prefix
        }
        if ( chemistry == "10x_multiome" ){
            call tenx_barcode_map.mapping_tenx_barcodes as barcode_mapping{
                input:
                    #whitelist_atac = select_first([whitelist_atac, whitelist_atac_]),
                    #whitelist_rna = select_first([whitelist_rna, whitelist_rna_])
                    whitelist_atac = whitelist_atac_,
                    whitelist_rna = whitelist_rna_
            }
        }
    }
    
    if ( process_rna ) {
        if ( read1_rna[0] != "" ) {
            call subwf_rna.wf_rna as rna{
                input:
                    read1 = read1_rna_,
                    read2 = read2_rna_,
                    seqspecs = seqspecs,
                    chemistry = chemistry,
                    barcode_whitelists = whitelists_rna_,
                    genome_fasta = genome_fasta,
                    genome_gtf = gtf_,
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
                    read1 = select_first([read1_atac_]),
                    read2 = select_first([read2_atac_]),
                    fastq_barcode = fastq_barcode_,
                    chemistry = chemistry,
                    reference_fasta = genome_fasta,
                    subpool = subpool,
                    gtf = gtf_,
                    whitelist = whitelists_atac_[0], #cannot coerce array
                    trim_fastqs = trim_fastqs,
                    chrom_sizes = chrom_sizes_,
                    genome_index_tar = idx_tar_atac_,
                    tss_bed = tss_bed_,
                    prefix = prefix,
                    read_format = select_first([preprocess_tenx.tenx_barcode_complementation_out,read_format]),
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

    if ( pipeline_modality != "no_align" ) {
        call html_report.html_report as html_report {
            input:
                prefix = prefix,
                atac_metrics = atac.atac_qc_metrics,
                rna_metrics = rna.rna_log,
                ## JPEG files to be encoded and appended to html
                # RNA plots
                image_files = [joint_qc.joint_qc_plot, joint_qc.joint_density_plot,
                            rna.rna_umi_barcode_rank_plot, rna.rna_gene_barcode_rank_plot, rna.rna_gene_umi_scatter_plot,
                            atac.atac_qc_barcode_rank_plot, atac.atac_qc_hist_plot, atac.atac_qc_tss_enrichment],

                ## Links to files and logs to append to end of html
                log_files = [rna.rna_align_log, rna.rna_log, atac.atac_alignment_log]

        }
    }

    output{
        # Fastq after correction/trimming
        Array[File]? atac_read1_processed = atac.atac_read1_processed
        Array[File]? atac_read2_processed = atac.atac_read2_processed

        Array[File]? rna_read1_processed = rna.rna_read1_processed
        Array[File]? rna_read2_processed = rna.rna_read2_processed

        # RNA outputs
        File? rna_kb_output = rna.rna_kb_output
        File? rna_mtx_tar = rna.rna_mtx_tar
        File? rna_counts_h5ad = rna.rna_counts_h5ad
        File? rna_log = rna.rna_log
        File? rna_barcode_metadata  = rna.rna_barcode_metadata
        
        # ATAC ouputs
        File? atac_filter_fragments = atac.atac_fragments
        File? atac_filter_fragments_index = atac.atac_fragments_index
        File? atac_barcode_metadata = atac.atac_barcode_metadata

        # Joint outputs
        File? joint_barcode_metadata = joint_qc.joint_barcode_metadata

        # Report
        File? html_summary = html_report.html_report_file
        File? csv_summary = html_report.csv_summary_file
    }

}
