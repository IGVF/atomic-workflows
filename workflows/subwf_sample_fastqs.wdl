version 1.0

# Import the tasks called by the pipeline
import "../tasks/task_check_inputs.wdl" as check_inputs
import "../tasks/task_sample_fastqs.wdl" as sample_fastqs


workflow wf_retrieve {
    meta {
        version: 'v1'
        author: 'Siddarth Wekhande @ Broad Institute of MIT and Harvard'
        description: 'Broad Institute of MIT and Harvard SHARE-Seq pipeline: Sub-workflow to download fastqs from synapse and extract first 1M lines.'
    }
    
    input {
            
        Array[String] read1_atac
        Array[String] read2_atac
        Array[String] fastq_barcode
        
        Array[String] read1_rna
        Array[String] read2_rna
    
    }
    
    
    call check_inputs.check_inputs as check_read1_atac{
        input:
            paths = read1_atac
    }
    #Array[File] read1_atac_ = check_read1_atac.output_files
    call sample_fastqs.sample_fastqs as sample_fastqs_read1_atac{
        input:
            paths = check_read1_atac.output_files
    }
    
    call check_inputs.check_inputs as check_read2_atac{
        input:
            paths = read2_atac
    }
    #Array[File] read2_atac_ = check_read2_atac.output_files
    call sample_fastqs.sample_fastqs as sample_fastqs_read2_atac{
        input:
            paths = check_read2_atac.output_files
    }
    
    call check_inputs.check_inputs as check_fastq_barcode{
        input:
            paths = fastq_barcode
    }
    #Array[File] fastq_barcode_ = check_fastq_barcode.output_files
    call sample_fastqs.sample_fastqs as sample_fastqs_barcode{
        input:
            paths = check_fastq_barcode.output_files
    }
    
    call check_inputs.check_inputs as check_read1_rna{
        input:
            paths = read1_rna
    }
    #Array[File] read1_rna_ = check_read1_rna.output_files
    call sample_fastqs.sample_fastqs as sample_fastqs_read1_rna{
        input:
            paths = check_read1_rna.output_files
    }
    
    call check_inputs.check_inputs as check_read2_rna{
        input:
            paths = read2_rna
    }
    #Array[File] read2_rna_ = check_read2_rna.output_files
    call sample_fastqs.sample_fastqs as sample_fastqs_read2_rna{
        input:
            paths = check_read2_rna.output_files
    }
    
    output{
        # sampled fastqa 
        Array[File]? atac_read1_sampled = sample_fastqs_read1_atac.output_files
        Array[File]? atac_read2_sampled = sample_fastqs_read2_atac.output_files
        
        Array[File]? atac_barcode_sampled = sample_fastqs_barcode.output_files
        
        Array[File]? rna_read1_sampled = sample_fastqs_read1_rna.output_files
        Array[File]? rna_read2_sampled = sample_fastqs_read2_rna.output_files
    }
}
        
    
    
