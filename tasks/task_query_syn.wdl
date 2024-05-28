version 1.0

# TASK
# Check inputs and download accordingly


task query_syn {
    meta {
        version: 'v0.1'
        author: 'Siddarth Wekhande (swekhand@broadinstitute.org) at Broad Institute of MIT and Harvard'
        description: 'Broad Institute of MIT and Harvard IGVF pipeline: query synapse task'
    }

    input {
        String path 
        
        Int? cpus = 1
        Float? disk_factor = 1.0
        Float? memory_factor = 1.0
        String? docker_image = "swekhande/shareseq-prod:check-inputs"    
    }

    Float mem_gb = 4.0

    Int disk_gb = round(10.0 * disk_factor)

    String disk_type = if disk_gb > 375 then "SSD" else "LOCAL"
    
    String monitor_fnp_log = "check_inputs_monitor.log"

    command <<<
        
        set -e

        bash $(which monitor_script.sh) | tee ~{monitor_fnp_log} 1>&2 &
        
        synapse show ~{path} | grep "name*" | cut -f2 -d "=" > tmp.txt
  
    >>>
    output {
       String output_file = read_string("tmp.txt")
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