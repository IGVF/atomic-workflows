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
        String? read_format
        
        File genome_fasta
        File genome_gtf
        String chemistry
        
        Array[File] barcode_whitelists
        
        String? subpool = "none"
        String genome_name # GRCh38, mm10
        String prefix = "test-sample"
        
        # RNA kb runtime parameters
        String? kb_strand
        Int? kb_cpus
        Float? kb_disk_factor
        Float? kb_memory_factor
        String? kb_docker_image
        String? kb_workflow = "nac"
        
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

    #should implement check if length of seqspecs == length of read1 == length of read2
    scatter ( idx in range(length(seqspecs)) ) {
        call task_seqspec_extract.seqspec_extract as seqspec_extract {
            input:
                seqspec = seqspecs[idx],
                fastq_R1 = basename(read1[idx]),
                fastq_R2 = basename(read2[idx]),
                onlists = barcode_whitelists,
                modality = "rna",
                tool_format = "kb",
                chemistry = chemistry,
                onlist_format = "multi",
                cpus = seqspec_extract_cpus,
                disk_factor = seqspec_extract_disk_factor,
                memory_factor = seqspec_extract_memory_factor,
                docker_image = seqspec_extract_docker_image
        }
    }
    
    #Assuming this whitelist is applicable to all fastqs for kb task
    File barcode_whitelist_ = seqspec_extract.onlist[0]
    
    #Assuming this index_string is applicable to all fastqs for kb task
    String index_string_ = if chemistry == "shareseq" then "1,0,24:1,24,34:0,0,50" else seqspec_extract.index_string[0] #fixed index string for shareseq
    
    
    #correct barcode logic for shareseq
    if ( chemistry == "shareseq" && correct_barcodes ) {
        scatter (read_pair in zip(read1, read2)) {
            call share_task_correct_fastq.share_correct_fastq as correct {
                input:
                    fastq_R1 = read_pair.left,
                    fastq_R2 = read_pair.right,
                    whitelist = barcode_whitelist_,
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

    call task_kb.kb as kb{
        input:
            read1_fastqs = fastqs_R1,
            read2_fastqs = fastqs_R2,
            genome_fasta = genome_fasta,
            strand = kb_strand,
            kb_workflow = kb_workflow,
            barcode_whitelist = barcode_whitelist_,
            index_string = select_first([read_format, index_string_]),
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
            counts_h5ad = kb.rna_mtxs_h5ad,
            genome_name = genome_name,
            kb_workflow = kb_workflow,
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
        File rna_mtxs_tar = kb.rna_mtxs_tar
        File rna_mtxs_h5ad = kb.rna_mtxs_h5ad
        File? rna_aggregated_counts_h5ad = kb.rna_aggregated_counts_h5ad
        File rna_log = log_rna.rna_logfile
        File rna_barcode_metadata = qc_rna.rna_barcode_metadata
        File? rna_umi_barcode_rank_plot = qc_rna.rna_umi_barcode_rank_plot
        File? rna_gene_barcode_rank_plot = qc_rna.rna_gene_barcode_rank_plot
        File? rna_gene_umi_scatter_plot = qc_rna.rna_gene_umi_scatter_plot
    }
}
