version 1.0

# TASK
# rna-log
# Gather information from log files 

task log_rna {
    meta {
        version: 'v0.1'
        author: 'Siddarth Wekhande (swekhand@broadinstitute.org) at Broad Institute of MIT and Harvard'
        description: 'Compile RNA statistics from various tasks'
    }

    input {
        # This function takes as input the necessary log files and extracts
        # the quality metrics
        File alignment_json
        File barcodes_json
        
        String genome_name # GRCh38, mm10
        String prefix = "test-sample"
        
        String? docker_image = "swekhande/shareseq-prod:igvf-log-rna"
    }
    
    String rna_log = "${prefix}.rna.log.${genome_name}.txt"

    command <<<
        
        touch rna_log
        
        jq -r 'to_entries | map("\(.key),\(.value)") | .[]' < ~{alignment_json} | grep '^\(n_\|p_\)' >> ~{rna_log}
        
        jq -r 'to_entries | map("\(.key),\(.value)") | .[]' < ~{barcodes_json} >> ~{rna_log}
            
    >>>
    output {
        File rna_logfile = rna_log
    }

    runtime {
        docker: "${docker_image}"
        singularity: "docker://${docker_image}"
    }
    parameter_meta {
        alignment_json: {
            description: 'RNA alignment JSON output from kb',
	        help: 'JSON file from RNA alignment step.',
            example: 'run_info.json'
        }

        barcodes_json: {
            description: 'Barcode metrics JSON from kb',
            help: 'JSON file from RNA alignment step.',
            example: 'inspect.json'
        }
    }
}
