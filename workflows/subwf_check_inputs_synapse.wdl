version 1.0

# Import the sub-workflow for preprocessing the fastqs.
import "../tasks/task_query_syn.wdl" as query_syn
import "../tasks/task_check_inputs.wdl" as check_inputs
import "../tasks/task_seqspec_extract.wdl" as task_seqspec_extract

workflow wf_check_inputs {
    meta {
        version: 'v0.1'
        author: 'Siddarth Wekhande (swekhand@broadinstitute.org) at Broad Institute of MIT and Harvard'
        description: 'IGVF Single Cell pipeline: Sub-workflow to check inputs with seqspec'
    }
    
    input {
    
        Array[File] whitelist_atac
        Array[File] whitelist_rna
        
        Array[File] seqspecs
        
        Array[File] read1_atac
        Array[File] read2_atac
        Array[File] fastq_barcode
        
        Array[File] read1_rna
        Array[File] read2_rna
        
        String chemistry
        
        Int? seqspec_extract_cpus
        Float? seqspec_extract_disk_factor
        Float? seqspec_extract_memory_factor
        String? seqspec_extract_docker_image
        
    }
    
    Boolean process_atac = if length(read1_atac)>0 then true else false
    Boolean process_rna = if length(read1_rna)>0 then true else false
    
    #onlists must be gs links. 
    File whitelist_atac_ = whitelist_atac[0]
    File whitelist_rna_ = whitelist_rna[0]
    
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
                call query_syn.query_syn as check_read1_atac{
                    input:
                        path = file
                }
            }
        }
        
        #ATAC Read2
        if ( (sub(read2_atac[0], "^gs:\/\/", "") == sub(read2_atac[0], "", "")) ){
            scatter(file in read2_atac){
                call query_syn.query_syn as check_read2_atac{
                    input:
                        path = file
                }
            }
        }

        #ATAC barcode
        if ( (sub(fastq_barcode[0], "^gs:\/\/", "") == sub(fastq_barcode[0], "", "")) ){
            scatter(file in fastq_barcode){
                call query_syn.query_syn as check_fastq_barcode{
                    input:
                        path = file
                }
            }
        }
    }
    
    Array[String] read1_atac_ = select_first([ check_read1_atac.output_file, read1_atac ])
    Array[String] read2_atac_ = select_first([ check_read2_atac.output_file, read2_atac ])
    Array[String] fastq_barcode_ = select_first([ check_fastq_barcode.output_file, fastq_barcode ])
    
    if(process_rna){
        #RNA Read1
        if ( (sub(read1_rna[0], "^gs:\/\/", "") == sub(read1_rna[0], "", "")) ){
            scatter(file in read1_rna){
                call query_syn.query_syn as check_read1_rna{
                    input:
                        path = file
                }
            }
        }

        #RNA Read2
        if ( (sub(read2_rna[0], "^gs:\/\/", "") == sub(read2_rna[0], "", "")) ){
            scatter(file in read2_rna){
                call query_syn.query_syn as check_read2_rna{
                    input:
                        path = file
                }
            }
        }
    }
    
    Array[String] read1_rna_ = select_first([ check_read1_rna.output_file, read1_rna ])
    Array[String] read2_rna_ = select_first([ check_read2_rna.output_file, read2_rna ])
    
    scatter ( idx in range(length(seqspecs_)) ) {
        call task_seqspec_extract.seqspec_extract as rna_seqspec_extract {
            input:
                seqspec = seqspecs_[idx],
                fastq_R1 = basename(read1_rna_[idx]),
                fastq_R2 = basename(read2_rna_[idx]),
                onlists = whitelist_rna,
                modality = "rna",
                tool_format = "kb",
                chemistry = chemistry,
                onlist_format = if chemistry=="shareseq" || chemistry=="parse" then "multi" else "product",
                cpus = seqspec_extract_cpus,
                disk_factor = seqspec_extract_disk_factor,
                memory_factor = seqspec_extract_memory_factor,
                docker_image = seqspec_extract_docker_image
        }
    }
    
    #Assuming this whitelist is applicable to all fastqs for kb task
    File rna_barcode_whitelist_ = rna_seqspec_extract.onlist[0]
    
    String rna_index_string_ = rna_seqspec_extract.index_string[0]
    
    scatter ( idx in range(length(seqspecs)) ) {
        call task_seqspec_extract.seqspec_extract as atac_seqspec_extract {
            input:
                seqspec = seqspecs_[idx],
                fastq_R1 = basename(read1_atac_[idx]),
                fastq_R2 = basename(read2_atac_[idx]),
                fastq_barcode = basename(fastq_barcode_[idx]),
                onlists = whitelist_atac,
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
    File atac_barcode_whitelist_ = atac_seqspec_extract.onlist[0]
    
    String atac_index_string_ = atac_seqspec_extract.index_string[0]
    
    output{
    
        File seqspec_atac_onlist = atac_barcode_whitelist_
        File seqspec_rna_onlist = rna_barcode_whitelist_
        String seqspec_atac_index = atac_index_string_
        String seqspec_rna_index = rna_index_string_
    
    }
}
    
    