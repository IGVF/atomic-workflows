version 1.0

# Import the tasks called by the pipeline
import "../tasks/task_seqspec_extract.wdl" as task_seqspec_extract
import "../tasks/task_chromap.wdl" as task_align_chromap
import "../tasks/task_chromap_bam.wdl" as task_align_chromap_bam
import "../tasks/task_qc_atac.wdl" as task_qc_atac
import "../tasks/task_log_atac.wdl" as task_log_atac


workflow wf_atac {
    meta {
        version: 'v1'
        author: 'Eugenio Mattei (emattei@broadinstitute.org) and Sai Ma @ Broad Institute of MIT and Harvard'
        description: 'Broad Institute of MIT and Harvard SHARE-Seq pipeline: Sub-workflow to process the ATAC portion of SHARE-seq libraries.'
    }

    input {
        # ATAC sub-workflow inputs
        File chrom_sizes
        File tss_bed
        Int? mapq_threshold = 30
        String? barcode_tag = "CB"
        String? barcode_tag_fragments
        String chemistry
        String? prefix = "sample"
        String? subpool = "none"
        String genome_name
        File? gtf
        Int? cutoff
        String pipeline_modality = "full"
        Boolean trim_fastqs = true
        File? barcode_conversion_dict # For 10X multiome

        # Align-specific inputs
        Array[File] read1
        Array[File] read2
        Array[File] fastq_barcode
        Array[File] seqspecs
        Array[File] barcode_whitelists
        Int? align_multimappers
        File reference_fasta
        File reference_index_tar_gz
        Boolean? remove_pcr_duplicates = true
        Boolean? remove_pcr_duplicates_at_cell_level = true
        Boolean? Tn5_shift = true
        Boolean? low_mem = true
        Boolean? bed_output = true
        Boolean? trim_adapters = true
        Int? max_insert_size = 2000
        Int? quality_filter = 0
        Int? bc_error_threshold = 2
        Float? bc_probability_threshold = 0.9
        String? read_format
        # Runtime parameters
        Int? align_cpus
        Float? align_disk_factor = 8.0
        Float? align_memory_factor = 0.15
        String? align_docker_image

        Int? qc_fragment_min_cutoff

        # Merge-specific inputs
        # Runtime parameters
        Int? merge_cpus
        Float? merge_disk_factor = 8.0
        Float? merge_memory_factor = 0.15
        String? merge_docker_image

        # Filter-specific inputs
        Int? filter_minimum_fragments_cutoff
        Int? filter_shift_plus = 4
        Int? filter_shift_minus = -4
        # Runtime parameters
        Int? filter_cpus = 16
        Float? filter_disk_factor = 8.0
        Float? filter_memory_factor = 0.15
        String? filter_docker_image

        # QC-specific inputs
        File? raw_bam
        File? raw_bam_index
        File? filtered_bam
        File? filtered_bam_index
        Int? qc_fragment_cutoff
        # Runtime parameters
        Int? qc_cpus = 16
        Float? qc_disk_factor = 8.0
        Float? qc_memory_factor = 0.15
        String? qc_docker_image

        # RNA seqspec extract runtime parameters
        Int? seqspec_extract_cpus
        Float? seqspec_extract_disk_factor
        Float? seqspec_extract_memory_factor
        String? seqspec_extract_docker_image
    }

    String barcode_tag_fragments_ = if chemistry=="shareseq" then select_first([barcode_tag_fragments, "XC"]) else select_first([barcode_tag_fragments, barcode_tag])

    scatter ( idx in range(length(seqspecs)) ) {
        call task_seqspec_extract.seqspec_extract as seqspec_extract {
            input:
                seqspec = seqspecs[idx],
                fastq_R1 = basename(read1[idx]),
                fastq_R2 = basename(read2[idx]),
                fastq_barcode = basename(fastq_barcode[idx]),
                onlists = barcode_whitelists,
                modality = "atac",
                tool_format = "chromap",
                onlist_format = "product",
                chemistry = chemistry,
                cpus = seqspec_extract_cpus,
                disk_factor = seqspec_extract_disk_factor,
                memory_factor = seqspec_extract_memory_factor,
                docker_image = seqspec_extract_docker_image
        }
    }
    
    #Assuming this whitelist is applicable to all fastqs for kb task
    File barcode_whitelist_ = seqspec_extract.onlist[0]
    
    String index_string_ = select_first([read_format, seqspec_extract.index_string[0] ])

    if (  "~{pipeline_modality}" != "no_align" ) {
        
        call task_align_chromap.atac_align_chromap as align {
            input:
                fastq_R1 = read1,
                fastq_R2 = read2,
                fastq_barcode = fastq_barcode,
                reference_fasta = reference_fasta,
                reference_index_tar_gz = reference_index_tar_gz,
                trim_adapters = trim_adapters,
                genome_name = genome_name,
                subpool = subpool,
                multimappers = align_multimappers,
                barcode_inclusion_list = barcode_whitelist_,
                barcode_conversion_dict = barcode_conversion_dict,
                prefix = prefix,
                disk_factor = align_disk_factor,
                memory_factor = align_memory_factor,
                cpus = align_cpus,
                docker_image = align_docker_image,
                remove_pcr_duplicates = remove_pcr_duplicates,
                remove_pcr_duplicates_at_cell_level = remove_pcr_duplicates_at_cell_level,
                Tn5_shift = Tn5_shift,
                low_mem = low_mem,
                bed_output = bed_output,
                max_insert_size = max_insert_size,
                quality_filter = quality_filter,
                bc_error_threshold = bc_error_threshold,
                bc_probability_threshold = bc_probability_threshold,
                read_format = index_string_
        }

        call task_align_chromap_bam.atac_align_chromap as generate_bam {
            input:
                fastq_R1 = read1,
                fastq_R2 = read2,
                fastq_barcode = fastq_barcode,
                reference_fasta = reference_fasta,
                trim_adapters = trim_adapters,
                genome_name = genome_name,
                subpool = subpool,
                multimappers = align_multimappers,
                barcode_inclusion_list = barcode_whitelist_,
                barcode_conversion_dict = barcode_conversion_dict,
                prefix = prefix,
                disk_factor = align_disk_factor,
                memory_factor = align_memory_factor,
                cpus = align_cpus,
                docker_image = align_docker_image,
                remove_pcr_duplicates = remove_pcr_duplicates,
                remove_pcr_duplicates_at_cell_level = remove_pcr_duplicates_at_cell_level,
                Tn5_shift = Tn5_shift,
                low_mem = low_mem,
                bed_output = bed_output,
                max_insert_size = max_insert_size,
                quality_filter = quality_filter,
                bc_error_threshold = bc_error_threshold,
                bc_probability_threshold = bc_probability_threshold,
                read_format = index_string_
        }

        call task_log_atac.log_atac as log_atac {
            input:
                alignment_log = align.atac_alignment_log,
                barcode_log = align.atac_align_barcode_statistics,
                prefix = prefix
        }

        call task_qc_atac.qc_atac as qc_atac{
            input:
                fragments = align.atac_fragments,
                fragments_index = align.atac_fragments_index,
                barcode_summary = align.atac_align_barcode_statistics,
                tss = tss_bed,
                gtf = gtf,
                subpool = subpool,
                barcode_conversion_dict = barcode_conversion_dict,
                fragment_min_snapatac_cutoff = qc_fragment_min_cutoff,
                chrom_sizes = chrom_sizes,
                genome_name = genome_name,
                prefix = prefix,
                cpus = qc_cpus,
                disk_factor = qc_disk_factor,
                docker_image = qc_docker_image,
                memory_factor = qc_memory_factor
         }
    }

    output {
        # Align
        File? atac_alignment_log = align.atac_alignment_log
        File? atac_chromap_bam = generate_bam.atac_bam
        File? atac_chromap_bam_alignement_stats = generate_bam.atac_alignment_log

        # Filter
        File? atac_fragments = align.atac_fragments
        File? atac_fragments_index = align.atac_fragments_index

        # QC
        File? atac_qc_chromap_barcode_metadata = qc_atac.atac_qc_chromap_barcode_metadata
        File? atac_qc_snapatac2_barcode_metadata = qc_atac.atac_qc_snapatac2_barcode_metadata
        File? atac_qc_tss_enrichment = qc_atac.atac_qc_tss_enrichment_plot
        File? atac_qc_barcode_rank_plot = qc_atac.atac_qc_barcode_rank_plot
        File? atac_qc_insertion_size_histogram = qc_atac.atac_qc_final_hist_png
        File? atac_qc_tsse_fragments_plot = qc_atac.atac_qc_tsse_fragments_plot

        # Log
        File? atac_qc_metrics = log_atac.atac_statistics_csv
    }
}