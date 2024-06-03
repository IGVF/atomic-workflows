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
        String tool_format
        String onlist_format
        String chemistry
        
        #Take input filenames, not actual files since not required. Filenames must EXACTLY match in seqspec
        String fastq_R1 
        String fastq_R2
        String? fastq_barcode
        
        Int? cpus = 1
        Float? disk_factor = 1.0
        Float? memory_factor = 0.1
        String? docker_image = "swekhande/shareseq-prod:seqspec-devel"    
    }
    
    #Create array of fastq filenames  
    Array[String] fastq_files = select_all([fastq_R1, fastq_R2, fastq_barcode])
    
    # Determine the size of the input
    Float input_file_size_gb = 1.0 

    # Determining memory size base on the size of the input files.
    Float mem_gb = 2.0 + memory_factor * input_file_size_gb

    # Determining disk size base on the size of the input files.
    Int disk_gb = round(10.0 + disk_factor * input_file_size_gb)

    # Determining disk type base on the size of disk.
    String disk_type = if disk_gb > 375 then "SSD" else "LOCAL"
    
    String monitor_fnp_log = "seqspec_extract_monitor.log"

    command <<<
        
        set -e

        bash $(which monitor_script.sh) | tee ~{monitor_fnp_log} 1>&2 &
        
        mv ~{sep=" " onlists} ./
        mv ~{seqspec} ./spec.yaml
                
        echo 'seqspec index -t ~{tool_format} -m ~{modality} -r ~{sep="," fastq_files} spec.yaml > index_string.txt'
        
        seqspec index -t ~{tool_format} -m ~{modality} -r ~{sep="," fastq_files} spec.yaml > index_string.txt
        
        echo 'seqspec onlist -m ~{modality} -f ~{onlist_format} -r barcode -s region-type spec.yaml > whitelist_path.txt'
        
        seqspec onlist -m ~{modality} -f ~{onlist_format} -r barcode -s region-type spec.yaml > whitelist_path.txt
        
        file_path=$(cat whitelist_path.txt); [[ $file_path =~ \.gz$ ]] && mv $(cat whitelist_path.txt) final_barcodes.txt.gz || mv $(cat whitelist_path.txt) final_barcodes.txt
        
        if [[ '~{tool_format}' == "chromap" ]]; then
            awk '{print $NF}' index_string.txt > temp_index_string
            mv temp_index_string index_string.txt
        fi
                
    >>>
    output {
        String index_string = read_string("index_string.txt")
        File onlist = glob("final_barcodes*")[0]
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
        tool_format: {
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