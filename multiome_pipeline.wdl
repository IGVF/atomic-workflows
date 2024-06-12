version 1.0

# Import the sub-workflow for preprocessing the fastqs.
import "tasks/task_check_inputs.wdl" as check_inputs
import "tasks/task_sample_fastqs.wdl" as sample_fastqs
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
        Boolean sample_flag = false
        String chemistry
        String prefix
        String? subpool = "none"
        String pipeline_modality = "full" # "full": run everything; "count_only": stops after producing fragment file and count matrix; "no_align": correct and trim raw fastqs.

        File genome_fasta
        File kb_index_directory
        
        #can be removed
        File whitelists_tsv = 'gs://broad-buenrostro-pipeline-genome-annotations/whitelists/whitelists.tsv'
        
        Array[File] whitelist_atac
        Array[File] whitelist_rna
        
        Array[File] seqspecs

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
        String? atac_read_format
        Int? atac_filter_minimum_fragments_cutoff = 1
        #Int? atac_filter_shift_plus = 4
        #Int? atac_filter_shift_minus = -4

        # RNA-specific inputs
        Array[File] read1_rna
        Array[File] read2_rna
        File? gtf
        String? rna_read_format

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
    File gtf_ = select_first([gtf, annotations["genesgtf"]])

    Boolean process_atac = if length(read1_atac)>0 then true else false
    Boolean process_rna = if length(read1_rna)>0 then true else false
      
    #onlists must be gs links. 
    File whitelist_atac_ = whitelist_atac[0]
    File whitelist_rna_ = whitelist_rna[0]
    
    #seqspec
    if (sub(seqspecs[0], "^gs:\/\/", "") == sub(seqspecs[0], "", "")){
        scatter(file in seqspecs){
            call check_inputs.check_inputs as check_seqspec{
                input:
                    path = file
            }
        }
    }
    
    Array[File] seqspecs_ = select_first([ check_seqspec.output_file, seqspecs ])
    
    if(process_atac){
        #ATAC Read1
        if ( (sub(read1_atac[0], "^gs:\/\/", "") == sub(read1_atac[0], "", "")) ){

            scatter(file in read1_atac){
                call check_inputs.check_inputs as check_read1_atac{
                    input:
                        path = file
                }
            }
        }
        
        #ATAC Read2
        if ( (sub(read2_atac[0], "^gs:\/\/", "") == sub(read2_atac[0], "", "")) ){
            scatter(file in read2_atac){
                call check_inputs.check_inputs as check_read2_atac{
                    input:
                        path = file
                }
            }
        }

        #ATAC barcode
        if ( (sub(fastq_barcode[0], "^gs:\/\/", "") == sub(fastq_barcode[0], "", "")) ){
            scatter(file in fastq_barcode){
                call check_inputs.check_inputs as check_fastq_barcode{
                    input:
                        path = file
                }
            }
        }
    }
    
    Array[File] read1_atac_ = select_first([ check_read1_atac.output_file, read1_atac ])
    Array[File] read2_atac_ = select_first([ check_read2_atac.output_file, read2_atac ])
    Array[File] fastq_barcode_ = select_first([ check_fastq_barcode.output_file, fastq_barcode ])
    
    if(process_rna){
        #RNA Read1
        if ( (sub(read1_rna[0], "^gs:\/\/", "") == sub(read1_rna[0], "", "")) ){
            scatter(file in read1_rna){
                call check_inputs.check_inputs as check_read1_rna{
                    input:
                        path = file
                }
            }
        }

        #RNA Read2
        if ( (sub(read2_rna[0], "^gs:\/\/", "") == sub(read2_rna[0], "", "")) ){
            scatter(file in read2_rna){
                call check_inputs.check_inputs as check_read2_rna{
                    input:
                        path = file
                }
            }
        }
    }
    
    Array[File] read1_rna_ = select_first([ check_read1_rna.output_file, read1_rna ])
    Array[File] read2_rna_ = select_first([ check_read2_rna.output_file, read2_rna ])
    
    #sample mode - use first million records in fastq
    if (sample_flag){   
        scatter(file in read1_atac_){
                call sample_fastqs.sample_fastqs as sample_read1_atac{
                    input:
                        path = file
                }
            }      
        
        scatter(file in read2_atac_){
                call sample_fastqs.sample_fastqs as sample_read2_atac{
                    input:
                        path = file
                }
            }      
        
        scatter(file in fastq_barcode_){
                call sample_fastqs.sample_fastqs as sample_barcode{
                    input:
                        path = file
                }
            }      
    
        scatter(file in read1_rna_){
                call sample_fastqs.sample_fastqs as sample_read1_rna{
                    input:
                        path = file
                }
            }      
        
        scatter(file in read2_rna_){
                call sample_fastqs.sample_fastqs as sample_read2_rna{
                    input:
                        path = file
                }
            }      
    }
    
    if ( chemistry != "shareseq" && chemistry != "parse" && process_atac) {
    
        Array[File] fq_barcode_ = select_first([ sample_barcode.output_file, fastq_barcode_ ])
        call preprocess_tenx.preprocess_tenx as preprocess_tenx{
                input:
                    fastq_barcode = fq_barcode_[0],
                    whitelist = whitelist_atac_,
                    chemistry = chemistry,
                    barcode_offset = atac_barcode_offset,
                    prefix = prefix
        }
        
        if ( chemistry == "10x_multiome" && process_rna){
            call tenx_barcode_map.mapping_tenx_barcodes as barcode_mapping{
                input:
                    whitelist_atac = whitelist_atac_,
                    whitelist_rna = whitelist_rna_
            }
        }
    }
    
    if ( process_rna ) {
        if ( read1_rna[0] != "" ) {
            call subwf_rna.wf_rna as rna{
                input:
                    read1 = select_first([sample_read1_rna.output_file,read1_rna_]),
                    read2 = select_first([sample_read2_rna.output_file,read2_rna_]),
                    seqspecs = seqspecs_,
                    chemistry = chemistry,
                    barcode_whitelists = whitelist_rna,
                    #genome_fasta = genome_fasta,
                    #genome_gtf = gtf_,
                    kb_index_directory = kb_index_directory,
                    prefix = prefix,
                    subpool = subpool,
                    genome_name = genome_name_,
                    read_format = rna_read_format
            }
        }
    }

    if ( process_atac ) {
        if ( read1_atac[0] != "" ) {
            call subwf_atac.wf_atac as atac{
                input:
                    read1 = select_first([sample_read1_atac.output_file,read1_atac_]),
                    read2 = select_first([sample_read2_atac.output_file,read2_atac_]),
                    seqspecs = seqspecs_,
                    fastq_barcode = select_first([ sample_barcode.output_file, fastq_barcode_ ]),
                    chemistry = chemistry,
                    reference_fasta = genome_fasta,
                    subpool = subpool,
                    gtf = gtf_,
                    barcode_whitelists = whitelist_atac,
                    trim_fastqs = trim_fastqs,
                    chrom_sizes = chrom_sizes_,
                    genome_index_tar = idx_tar_atac_,
                    tss_bed = tss_bed_,
                    prefix = prefix,
                    read_format = select_first([preprocess_tenx.tenx_barcode_complementation_out,atac_read_format]),
                    #read_format = atac_read_format,
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
                        atac_barcode_metadata = atac.atac_qc_snapatac2_barcode_metadata,
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
                            atac.atac_qc_barcode_rank_plot, atac.atac_qc_insertion_size_histogram, atac.atac_qc_tss_enrichment],

                ## Links to files and logs to append to end of html
                log_files = [rna.rna_align_log, rna.rna_log, atac.atac_alignment_log]

        }
    }

    output{
        # Fastq after correction/trimming
        Array[File]? atac_read1_processed = atac.atac_read1_processed
        Array[File]? atac_read2_processed = atac.atac_read2_processed
        Array[File]? atac_fastq_barcode_processed = atac.atac_fastq_barcode_processed

        Array[File]? rna_read1_processed = rna.rna_read1_processed
        Array[File]? rna_read2_processed = rna.rna_read2_processed

        # RNA outputs
        File? rna_kb_output = rna.rna_kb_output
        File? rna_mtx_tar = rna.rna_mtxs_tar
        File? rna_mtxs_h5ad = rna.rna_mtxs_h5ad
        File? rna_aggregated_counts_h5ad = rna.rna_aggregated_counts_h5ad
        File? rna_log = rna.rna_log
        File? rna_barcode_metadata  = rna.rna_barcode_metadata
        
        # ATAC ouputs
        File? atac_bam = atac.atac_chromap_bam
        File? atac_bam_log = atac.atac_chromap_bam_alignement_stats
        File? atac_filter_fragments = atac.atac_fragments
        File? atac_filter_fragments_index = atac.atac_fragments_index
        File? atac_chromap_barcode_metadata = atac.atac_qc_chromap_barcode_metadata
        File? atac_snapatac2_barcode_metadata = atac.atac_qc_snapatac2_barcode_metadata

        # Joint outputs
        File? joint_barcode_metadata = joint_qc.joint_barcode_metadata

        # Report
        File? html_summary = html_report.html_report_file
        File? csv_summary = html_report.csv_summary_file
    }

}
