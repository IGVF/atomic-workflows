version 1.0

import "../tasks/task_kb_index.wdl" as task_kb

workflow wf_rna {
    meta {
        version: 'v0.1'
        author: 'Siddarth Wekhande (swekhand@broadinstitute.org) at Broad Institute of MIT and Harvard'
        description: 'IGVF Single Cell pipeline: Sub-workflow to create kb reference'
    }
    
    input {
    
        File genome_fasta
        File genome_gtf
        String genome_name # GRCh38, mm10
        String prefix = "test-sample"
        
        Int? kb_cpus
        Float? kb_disk_factor
        Float? kb_memory_factor
        String? kb_docker_image
        String? kb_workflow = "nac"
    }
        
        call task_kb.kb_index as kb{
        input:
            genome_fasta = genome_fasta,
            kb_workflow = kb_workflow,
            genome_gtf = genome_gtf,
            genome_name = genome_name,
            prefix = prefix,
            cpus = kb_cpus,
            disk_factor = kb_disk_factor,
            memory_factor = kb_memory_factor,
            docker_image = kb_docker_image
    }
    
    output {
        File rna_index = kb.rna_index
    }
}