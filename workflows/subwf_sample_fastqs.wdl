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
    
    #ATAC Read1
    scatter(file in read1_atac){
        call check_inputs.check_inputs as check_read1_atac{
            input:
                path = file
        }
        
        call sample_fastqs.sample_fastqs as sample_fastqs_read1_atac{
            input:
                path = check_read1_atac.output_file
        }
    }
    
    #ATAC Read2
    scatter(file in read2_atac){
        call check_inputs.check_inputs as check_read2_atac{
            input:
                path = file
        }
        
        call sample_fastqs.sample_fastqs as sample_fastqs_read2_atac{
            input:
                path = check_read2_atac.output_file
        }
    }
    
    #ATAC Barcode
    scatter(file in fastq_barcode){
        call check_inputs.check_inputs as check_fastq_barcode{
            input:
                path = file
        }
        
        call sample_fastqs.sample_fastqs as sample_fastq_barcode{
            input:
                path = check_fastq_barcode.output_file
        }
    }
    
    #RNA Read1
    scatter(file in read1_rna){
        call check_inputs.check_inputs as check_read1_rna{
            input:
                path = file
        }
        
        call sample_fastqs.sample_fastqs as sample_fastqs_read1_rna{
            input:
                path = check_read1_rna.output_file
        }
    }
    
    #RNA Read2
    scatter(file in read2_rna){
        call check_inputs.check_inputs as check_read2_rna{
            input:
                path = file
        }
        
        call sample_fastqs.sample_fastqs as sample_fastqs_read2_rna{
            input:
                path = check_read2_rna.output_file
        }
    }
    
    output{
        # sampled fastqs 
        Array[File]? atac_read1_sampled = sample_fastqs_read1_atac.output_file
        Array[File]? atac_read2_sampled = sample_fastqs_read2_atac.output_file
        
        Array[File]? atac_barcode_sampled = sample_fastq_barcode.output_file
        
        Array[File]? rna_read1_sampled = sample_fastqs_read1_rna.output_file
        Array[File]? rna_read2_sampled = sample_fastqs_read2_rna.output_file
    }
}
        
    
    
