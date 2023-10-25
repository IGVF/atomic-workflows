version 1.0

# Import the tasks called by the pipeline
import "../tasks/share_task_correct_fastq.wdl" as share_task_correct_fastq
import "../tasks/task_cellatlas_rna.wdl" as task_cellatlas_rna
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

        #Array[File] fastqs
        Array[File] read1
        Array[File] read2
        File seqspec
        File genome_fasta
        File genome_gtf
        String chemistry
        
        # Correct-specific inputs
        Boolean correct_barcodes = true
        # Runtime parameters
        Int? correct_cpus
        Float? correct_disk_factor
        Float? correct_memory_factor
        String? correct_docker_image
        
        Array[File] barcode_whitelists
        
        String? subpool = "none"
        String genome_name # GRCh38, mm10
        String prefix = "test-sample"
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

    call task_cellatlas_rna.cellatlas_rna as cellatlas{
        input:
            fastqs = flatten([fastqs_R1,fastqs_R2]),
            seqspec = seqspec,
            genome_fasta = genome_fasta,
            barcode_whitelists = barcode_whitelists,
            genome_gtf = genome_gtf,
            subpool = subpool,
            genome_name = genome_name,
            prefix = prefix,
            chemistry = chemistry
    }
    
    call task_qc_rna.qc_rna as qc_rna {
        input:
            counts_h5ad = cellatlas.rna_counts_h5ad,
            genome_name = genome_name,
            prefix = prefix
    }
    
    #need to add duplicate logs from qc_rna in this task
    call task_log_rna.log_rna as log_rna {
        input:
            alignment_json = cellatlas.rna_alignment_json,
            barcodes_json = cellatlas.rna_barcode_matrics_json,
            genome_name = genome_name, 
            prefix = prefix          
    }

    output {
        Array[File]? rna_read1_processed = correct.corrected_fastq_R1
        Array[File]? rna_read2_processed = correct.corrected_fastq_R2
        File rna_align_log = cellatlas.rna_alignment_json
        File rna_kb_output = cellatlas.rna_output
        File rna_mtx_tar = cellatlas.rna_mtx_tar
        File rna_counts_h5ad = cellatlas.rna_counts_h5ad
        File rna_log = log_rna.rna_logfile
        File rna_barcode_metadata = qc_rna.rna_barcode_metadata
        File? rna_umi_barcode_rank_plot = qc_rna.rna_umi_barcode_rank_plot
        File? rna_gene_barcode_rank_plot = qc_rna.rna_gene_barcode_rank_plot
        File? rna_gene_umi_scatter_plot = qc_rna.rna_gene_umi_scatter_plot
    }
}
