version 1.0

# Import the tasks called by the pipeline
import "../tasks/task_seqspec_extract.wdl" as task_seqspec_extract
import "../tasks/share_task_correct_fastq.wdl" as share_task_correct_fastq
import "../tasks/task_kb.wdl" as task_kb
import "../tasks/task_qc_rna.wdl" as task_qc_rna
import "../tasks/task_log_rna.wdl" as task_log_rna

workflow wf_rna {
    meta {
        version: 'v0.1'
        author: 'Siddarth Wekhande (swekhand@broadinstitute.org) at Broad Institute of MIT and Harvard'
        description: 'IGVF Single Cell pipeline: Sub-workflow to process RNA libraries'
    }

    input {
        # RNA Cell Atlas inputs

        Array[File] read1
        Array[File] read2
                
        Array[File] seqspecs
        
        File genome_fasta
        File genome_gtf
        String chemistry
        
        Array[File] barcode_whitelists
        
        String? subpool = "none"
        String genome_name # GRCh38, mm10
        String prefix = "test-sample"
        
        # RNA kb runtime parameters
        Int? kb_cpus
        Float? kb_disk_factor
        Float? kb_memory_factor
        String? kb_docker_image
        
        # Correct-specific inputs
        Boolean correct_barcodes = true #for shareseq
        
        # RNA correct runtime parameters
        Int? correct_cpus
        Float? correct_disk_factor
        Float? correct_memory_factor
        String? correct_docker_image
        
        # RNA seqspec extract runtime parameters
        Int? seqspec_extract_cpus
        Float? seqspec_extract_disk_factor
        Float? seqspec_extract_memory_factor
        String? seqspec_extract_docker_image
        
        # RNA QC runtime parameters
        Int? qc_rna_cpus
        Float? qc_rna_disk_factor
        Float? qc_rna_memory_factor
        String? qc_rna_docker_image  
    }

    
    if ( chemistry == "shareseq" && correct_barcodes ) {
        scatter (read_pair in zip(read1, read2)) {
            call share_task_correct_fastq.share_correct_fastq as correct {
                input:
                    fastq_R1 = read_pair.left,
                    fastq_R2 = read_pair.right,
                    whitelist = barcode_whitelists[0],
                    sample_type = "RNA",
                    pkr = subpool,
                    prefix = prefix,
                    cpus = correct_cpus,
                    disk_factor = correct_disk_factor,
                    memory_factor = correct_memory_factor,
                    docker_image = correct_docker_image
            }
        }
    }
    
    Array[File] fastqs_R1 = select_first([correct.corrected_fastq_R1, read1])
    Array[File] fastqs_R2 = select_first([correct.corrected_fastq_R2, read2])
    
    if ( chemistry != "shareseq" ) {
        scatter (read_pair in zip(read1, read2)) {
            call task_seqspec_extract.seqspec_extract as seqspec_extract {
                input:
                    fastq_R1 = basename(read_pair.left),
                    fastq_R2 = basename(read_pair.right),
                    onlists = barcode_whitelists,
                    modality = "rna",
                    format = "kb",
                    cpus = seqspec_extract_cpus,
                    disk_factor = seqspec_extract_disk_factor,
                    memory_factor = seqspec_extract_memory_factor,
                    docker_image = seqspec_extract_docker_image
            }
        }
    }
    
    File barcode_whitelist_ = select_first([seqspec_extract.onlist, barcode_whitelists[0]])
    
    String index_string_ = select_first([seqspec_extract.index_string, "1,0,24:1,24,34:0,0,50"]) #fixed index string for shareseq

    call task_kb.kb as kb{
        input:
            read1_fastqs = fastqs_R1,
            read2_fastqs = fastqs_R2,
            genome_fasta = genome_fasta,
            barcode_whitelist = barcode_whitelist_,
            index_string = index_string_,
            genome_gtf = genome_gtf,
            subpool = subpool,
            genome_name = genome_name,
            prefix = prefix,
            chemistry = chemistry,
            cpus = kb_cpus,
            disk_factor = kb_disk_factor,
            memory_factor = kb_memory_factor,
            docker_image = kb_docker_image
    }
    
    call task_qc_rna.qc_rna as qc_rna {
        input:
            counts_h5ad = kb.rna_counts_h5ad,
            genome_name = genome_name,
            prefix = prefix,
            cpus = qc_rna_cpus,
            disk_factor = qc_rna_disk_factor,
            memory_factor = qc_rna_memory_factor,
            docker_image = qc_rna_docker_image
    }
    
    #need to add duplicate logs from qc_rna in this task
    call task_log_rna.log_rna as log_rna {
        input:
            alignment_json = kb.rna_alignment_json,
            barcodes_json = kb.rna_barcode_matrics_json,
            genome_name = genome_name, 
            prefix = prefix          
    }

    output {
        Array[File]? rna_read1_processed = correct.corrected_fastq_R1
        Array[File]? rna_read2_processed = correct.corrected_fastq_R2
        File rna_align_log = kb.rna_alignment_json
        File rna_kb_output = kb.rna_output
        File rna_mtx_tar = kb.rna_mtx_tar
        File rna_counts_h5ad = kb.rna_counts_h5ad
        File rna_log = log_rna.rna_logfile
        File rna_barcode_metadata = qc_rna.rna_barcode_metadata
        File? rna_umi_barcode_rank_plot = qc_rna.rna_umi_barcode_rank_plot
        File? rna_gene_barcode_rank_plot = qc_rna.rna_gene_barcode_rank_plot
        File? rna_gene_umi_scatter_plot = qc_rna.rna_gene_umi_scatter_plot
    }
}
