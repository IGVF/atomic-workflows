version 1.0

# Import the tasks called by the pipeline
import "../tasks/share_task_correct_fastq.wdl" as share_task_correct_fastq

workflow wf_correct_fastq {
    meta {
        version: 'v1'
        author: 'Siddarth Wekhande (swekhand@broadinstitute.org)'
        description: 'Broad Institute of MIT and Harvard SHARE-Seq pipeline: Sub-workflow to correct fastq'
    }
    
    input {
        Array[File] read1
        Array[File] read2
        
        String chemistry = "shareseq"
        String? prefix = "sample"
        String? subpool = "none"

        # Correct-specific inputs
        Boolean correct_barcodes = true
        File whitelist
        # Runtime parameters
        Int? correct_cpus = 16
        Float? correct_disk_factor = 8.0
        Float? correct_memory_factor = 0.08
        String? correct_docker_image
    }
    

    # Perform barcode error correction on FASTQs.
    if ( chemistry == "shareseq" && correct_barcodes ) {
        scatter (read_pair in zip(read1, read2)) {
            call share_task_correct_fastq.share_correct_fastq as correct {
                input:
                    fastq_R1 = read_pair.left,
                    fastq_R2 = read_pair.right,
                    whitelist = whitelist,
                    sample_type = "ATAC",
                    pkr = subpool,
                    prefix = prefix,
                    cpus = correct_cpus,
                    disk_factor = correct_disk_factor,
                    memory_factor = correct_memory_factor,
                    docker_image = correct_docker_image
            }
        }
    }
    
    output {
        # Correction/trimming
        Array[File]? atac_read1_processed = correct.corrected_fastq_R1
        Array[File]? atac_read2_processed = correct.corrected_fastq_R2
    }
}
