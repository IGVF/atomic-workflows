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
        Array[String] paths 
        
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
        
        output_paths=()
        
        for id in ${sep=' ' paths} do
        
        #add conditions to check source here
            filename=$(synapse get ${id} | grep "Downloaded" | cut -d ' ' -f 3)
            output_paths+=($filename)
        done
        printf "%s\n" "${output_paths[@]}"
    >>>
    output {
        Array[File]? output_files = read_lines(stdout())
    }

    runtime {
        cpu : cpus
        memory : "~{mem_gb} GB"
        disks: "local-disk ~{disk_gb} ~{disk_type}"
        docker : "~{docker_image}"
    }
    parameter_meta {
        paths: {
            description: 'Array of synpase IDs',
            help: 'List of strings that are prefixed with "syn"'
        }     
    }
}