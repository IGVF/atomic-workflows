version 1.0

# Import the tasks called by the pipeline
import "../tasks/task_cellatlas_rna.wdl" as task_cellatlas_rna
import "../tasks/task_cellatlas_rna.wdl" as task_cellatlas_rna

workflow wf_rna {
    meta {
        version: 'v0.1'
        author: 'Siddarth Wekhande (swekhand@broadinstitute.org) at Broad Institute of MIT and Harvard'
        description: 'IGVF Single Cell pipeline: Sub-workflow to process RNA libraries'
    }

    input {
        # RNA Cell Atlas inputs

        Array[File] fastqs
        File seqspec
        File genome_fasta
        File? feature_barcodes
        File genome_gtf
        File barcode_whitelist
        
        String? subpool = "none"
        String genome_name # GRCh38, mm10
        String prefix = "test-sample"
    }

    call task_cellatlas_rna.cellatlas_rna as cellatlas{
        input:
            fastqs = fastqs,
            seqspec = seqspec,
            genome_fasta = genome_fasta,
            feature_barcodes = feature_barcodes,
            barcode_whitelist = barcode_whitelist,
            genome_gtf = genome_gtf,
            subpool = subpool,
            genome_name = genome_name,
            prefix = prefix,
            docker_image = docker_image,
            disk_factor = disk_factor,
            memory_factor = memory_factor
    }
    
    #add qc_rna
    
    call task_log_rna.log_rna as log_rna {
        input:
        
            alignment_json = cellatlas.rna_alignment_json,
            barcodes_json = cellatlas.rna_barcode_matrics_json,
            genome_name = genome_name, 
            prefix = prefix          
    }

    output {
        File rna_kb_output = cellatlas.rna_output
        File rna_count_matrix = cellatlas.rna_count_matrix
        File rna_log = log_rna.rna_logfile
    }
}
