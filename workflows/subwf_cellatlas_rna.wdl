version 1.0

# Import the tasks called by the pipeline
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
        
        String? docker_image
        
        #Runtime parameters
        Float? disk_factor
        Float? memory_factor
    }

    call task_cellatlas_rna.rna_align_cellatlas as rna_align_cellatlas{
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

    output {
        File rna_output = rna_align_cellatlas.rna_output
        File rna_alignment_log = rna_align_cellatlas.rna_alignment_log
    }
}
