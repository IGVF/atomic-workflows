version 1.0

# TASK
# Extract the index string and onlist using seqspec


task seqspec_extract {
    meta {
        version: 'v0.1'
        author: 'Siddarth Wekhande (swekhand@broadinstitute.org) at Broad Institute of MIT and Harvard'
        description: 'Broad Institute of MIT and Harvard IGVF pipeline: seqspec extract task'
    }

    input {
        File seqspec
        Array[File] onlists #Filenames must EXACTLY match in seqspec
        String modality
        String format
        
        #Take input filenames, not actual files since not required. Filenames must EXACTLY match in seqspec
        String fastq_R1 
        String fastq_R2
        
        Int? cpus = 1
        Float? disk_factor = 1.0
        Float? memory_factor = 0.1
        String? docker_image = "swekhande/shareseq-prod:seqspec-extract"    
    }
    
    #Create array of fastq filenames  
    Array[String] fastq_files = [fastq_R1, fastq_R2]
    
    # Determine the size of the input
    Float input_file_size_gb = size(seqspec, "G") 

    # Determining memory size base on the size of the input files.
    Float mem_gb = 4.0 + memory_factor * input_file_size_gb

    # Determining disk size base on the size of the input files.
    Int disk_gb = round(10.0 + disk_factor * input_file_size_gb)

    # Determining disk type base on the size of disk.
    String disk_type = if disk_gb > 375 then "SSD" else "LOCAL"
    
    String monitor_fnp_log = "seqspec_extract_monitor.log"

    command <<<
        
        set -e

        bash $(which monitor_script.sh) | tee ~{monitor_fnp_log} 1>&2 &
        
        mv ~{sep=" " onlists} .
        
        python3 $(which seqspec_extract.py) -s ~{seqspec}  -m ~{modality} -fmt ~{format} -fq ~{sep=" " fastq_files}
        
    >>>
    output {
        String index_string = read_string("index_string.txt")
        File onlist = read_string("onlist_filename.txt")
        File monitor_log = "~{monitor_fnp_log}"
    }

    runtime {
        cpu : cpus
        memory : "~{mem_gb} GB"
        disks: "local-disk ~{disk_gb} ~{disk_type}"
        docker : "~{docker_image}"
    }
    parameter_meta {
        seqspec: {
            description: 'seqspec YAML file',
            help: 'seqspec file. must be unique to the fastq files'
        }
        onlists: {
            description: 'Barcode onlists / whitelist',
            help: 'Barcode sequence files in txt format. Filenames must EXACTLY match one in seqspec'
        }
        modality: {
            description: 'Assay modality',
            help: 'Which assay modality to extract infrormation from'
        }
        format: {
            description: 'Index string format',
            help: 'Output format of the index string. Check kb for available options.'
        }
        fastq_R1: {
            description: 'fastq R1 filename',
            help: 'Filename of fastq R1. Must EXACTLY match the one in seqspec region ID'
        }
        fastq_R2: {
            description: 'fastq R2 filename',
            help: 'Filename of fastq R2. Must EXACTLY match the one in seqspec region ID'
        }        
    }
}