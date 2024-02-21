version 1.0

# TASK
# Check inputs and download accordingly


task check_inputs {
    meta {
        version: 'v0.1'
        author: 'Siddarth Wekhande (swekhand@broadinstitute.org) at Broad Institute of MIT and Harvard'
        description: 'Broad Institute of MIT and Harvard IGVF pipeline: check inputs task'
    }

    input {
        String path 
        
        Int? cpus = 1
        Float? disk_factor = 1.0
        Float? memory_factor = 1.0
        String? docker_image = "swekhande/shareseq-prod:synapse1"    
    }

    Float mem_gb = 4.0

    Int disk_gb = round(100.0 * disk_factor)

    String disk_type = if disk_gb > 375 then "SSD" else "LOCAL"
    
    String monitor_fnp_log = "check_inputs_monitor.log"

    command <<<
        
        set -e

        bash $(which monitor_script.sh) | tee ~{monitor_fnp_log} 1>&2 &
        
        mkdir files
        cd files

        #add conditions for other sources
        if [[ "~{path}" == syn* ]]; then
            synapse get ~{path}
        fi
  
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