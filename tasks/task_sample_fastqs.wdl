version 1.0

# TASK
# Extract first 1M reads from fastqs


task sample_fastqs {
    meta {
        version: 'v0.1'
        author: 'Siddarth Wekhande (swekhand@broadinstitute.org) at Broad Institute of MIT and Harvard'
        description: 'Broad Institute of MIT and Harvard IGVF pipeline: sample fastqs task'
    }

    input {
        File path 
        
        Int? cpus = 1
        Float? disk_factor = 1.0
        Float? memory_factor = 1.0
        String? docker_image = "ubuntu"    
    }
    
    Float mem_gb = 4.0

    Int disk_gb = round(100.0 * disk_factor)

    String disk_type = if disk_gb > 375 then "SSD" else "LOCAL"
    
    String monitor_fnp_log = "sample_fastqs_monitor.log"
    
    command <<<
    
        set -e

        bash $(which monitor_script.sh) | tee ~{monitor_fnp_log} 1>&2 &
        
        mkdir files
        
        mv ~{path} files/tmp.fastq.gz
        
        cd files
    
        zcat tmp.fastq.gz | head -4000000 | gzip > $(basename -s .fastq.gz ~{path}).sampled.fastq.gz # fastq files has 4 lines per record so 1 million records = 4 million lines
        
    >>>
    
    output {
        File output_file = glob("files/*")[0]
    }
    
    runtime {
        cpu : cpus
        memory : "~{mem_gb} GB"
        disks: "local-disk ~{disk_gb} ~{disk_type}"
        docker : "~{docker_image}"
    }
    
    parameter_meta {
        path: {
            description: 'File path',
            help: 'File path of input'
        }     
    }
}