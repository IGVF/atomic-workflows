version 1.0

# TASK
# rna-kb

    
task kb_index {

    meta {
        version: 'v0.1'
        author: 'Siddarth Wekhande (swekhand@broadinstitute.org) at Broad Institute of MIT and Harvard'
        description: 'create reference using kb'
    }
    
    input {
         # This task takes in input genome and gtf and creates the index based on kb workflow
            
        File genome_fasta
        File genome_gtf   
        String? kb_workflow
        
        String prefix = "test-sample"
        String genome_name # GRCh38, mm10
        Int threads = 4
        
        Int? cpus = 4
        Float? disk_factor = 1
        Float? memory_factor = 1
        
        #TODO:We need to setup a docker registry.
        String? docker_image = "swekhande/igvf:task_kb"
        
    }
    
    
    # Determine the size of the input
    Float input_file_size_gb = size(genome_fasta, "G") + size(genome_gtf, "G")

    # Determining memory size base on the size of the input files.
    Float mem_gb = 24.0 + memory_factor * input_file_size_gb

    # Determining disk size base on the size of the input files.
    Int disk_gb = round(40.0 + disk_factor * input_file_size_gb)

    # Determining disk type base on the size of disk.
    String disk_type = if disk_gb > 375 then "SSD" else "LOCAL"

    # Define the output names
    String directory = "${prefix}.rna.align.kb.${genome_name}"


    command <<<
    
        set -e

        bash $(which monitor_script.sh) 1>&2 &
             
        mkdir ~{directory}
        
        #build index based on kb_workflow
        if [[ '~{kb_workflow}' == "standard" ]]; then   
        
            #build ref standard
            kb ref \
                -i ~{directory}/index.idx \
                -g ~{directory}/t2g.txt \
                -f1 ~{directory}/transcriptome.fa \
                ~{genome_fasta} \
                ~{genome_gtf}
                            
        else
                
            #build ref nac
            kb ref \
                --workflow=nac \
                -i ~{directory}/index.idx \
                -g ~{directory}/t2g.txt \
                -c1 ~{directory}/cdna.txt \
                -c2 ~{directory}/nascent.txt \
                -f1 ~{directory}/cdna.fasta \
                -f2 ~{directory}/nascent.fasta \
                ~{genome_fasta} \
                ~{genome_gtf}
                        
        fi
        
        tar -kzcvf ~{directory}.tar.gz ~{directory}

    >>>

    output {
        File rna_index = "~{directory}.tar.gz"
    }

    runtime {
        cpu: cpus
        docker: "${docker_image}"
        singularity: "docker://${docker_image}"
        disks: "local-disk ${disk_gb} ${disk_type}"
        memory: "${mem_gb} GB"
    }
    
    parameter_meta {   
        genome_fasta: {
            description: 'Genome reference',
            help: 'Genome reference in .fa.gz file',
            example: 'hg38.fa.gz'
        } 
        
        cpus: {
            description: 'Number of cpus.',
            help: 'Set the number of cpus used'
        }
            
        disk_factor: {
            description: 'Multiplication factor to determine disk required for task align.',
            help: 'This factor will be multiplied to the size of FASTQs to determine required disk of instance (GCP/AWS) or job (HPCs).',
            default: 8.0
        }
            
        memory_factor: {
            description: 'Multiplication factor to determine memory required for task align.',
            help: 'This factor will be multiplied to the size of FASTQs to determine required memory of instance (GCP/AWS) or job (HPCs).',
            default: 0.15
        }
            
        genome_name: {
            description: 'Reference name.',
            help: 'The name of the reference genome used by the aligner. This is appended to the output file name.',
            examples: ['GRCh38', 'mm10']
        }
            
        prefix: {
            description: 'Prefix for output files.',
            help: 'Prefix that will be used to name the output files',
            examples: 'my-experiment'
        }
            
        docker_image: {
            description: 'Docker image.',
            help: 'Docker image for the alignment step.',
            example: ["us.gcr.io/buenrostro-share-seq/share_task_bowtie2"]
        }
        
    }
    
}