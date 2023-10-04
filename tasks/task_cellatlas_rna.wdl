version 1.0

# TASK
# rna-cellatlas

    
task rna_align_cellatlas {

    meta {
        version: 'v0.1'
        author: 'Siddarth Wekhande (swekhand@broadinstitute.org) at Broad Institute of MIT and Harvard'
        description: 'align RNA using cellatlas'
    }
    
    input {
         # This task takes in input the raw RNA fastqs and their associated seqspec, processes the barcodes accordingly and aligns them to the genome.
        
        Array[File] fastqs
        String modality = "rna"
        File seqspec
        File genome_fasta
        File? feature_barcodes
        File genome_gtf
        File barcode_whitelist
        
        String? subpool = "none"
        String genome_name # GRCh38, mm10
        String prefix = "test-sample"
        
        #Will these be used? Need to run tests to optimize
        Int? cpus = 4
        Float? disk_factor = 1
        Float? memory_factor = 0.15
        
        #TODO:We need to setup a docker registry.
        String? docker_image = "swekhande/shareseq-prod:cellatlas-build"
        
    }
    
    # TODO: Determine the size of the input
    Float input_file_size_gb = 1.0

    # TODO: Determining memory size base on the size of the input files.
    Float mem_gb = 24.0 + memory_factor * input_file_size_gb

    # Determining disk size base on the size of the input files.
    Int disk_gb = round(40.0 + disk_factor * input_file_size_gb)

    # Determining disk type base on the size of disk.
    String disk_type = if disk_gb > 375 then "SSD" else "LOCAL"

    # Define the output names
    String directory = '${prefix}.rna.align.cellatlas.${genome_name}'
    
    String alignment_log = "${prefix}.rna.align.cellatlas.${genome_name}/run_info.json"

    command <<<
    
        set -e

         bash $(which monitor_script.sh) 1>&2 &

        # cellatlas build
    
        echo '------ cell atlas build ------' 1>&2
           
        cellatlas build \
        -o ~{directory} \
        -m ~{modality} \
        -s ~{seqspec} \
        -fa ~{genome_fasta} \
        -g ~{genome_gtf} \
        ~{"-fb " + feature_barcodes} \
        ~{sep=" " fastqs}
        
        echo '------ RNA bash commands ------' 1>&2
        
        jq  -r '.commands[] | values[] | join("\n")' ~{directory}/cellatlas_info.json 1>&2
        
        kb ref -i ~{directory}/index.idx -g ~{directory}/t2g.txt -f1 ~{directory}/transcriptome.fa ~{genome_fasta} ~{genome_gtf}
        
        kb count -i ~{directory}/index.idx -g ~{directory}/t2g.txt $(grep -oE '\-x [^ ]+' ~{directory}/cellatlas_info.json) -w ~{barcode_whitelist} -o ~{directory} --h5ad -t 2 ~{sep=" " fastqs}
        
        gzip -k ~{directory}

    >>>

    output {
        File rna_output = "~{directory}.gz"
        File rna_alignment_log = alignment_log
    }

    runtime {
        cpu: cpus
        docker: "${docker_image}"
        singularity: "docker://${docker_image}"
        disks: "local-disk ${disk_gb} ${disk_type}"
        memory: "${mem_gb} GB"
    }
    
    parameter_meta {
    
        fastqs: {
            description: 'List of input fastqs.',
            help: 'List of raw fastqs that will be corrected and processed using cellatlas',
            example: ['r1.fq.gz', 'r2.fq.gz']
        }
        
        modality: {
            description: 'Modality',
            help: 'Fixed to RNA',
            example: 'rna'
        }
        
        seqspec: {
            description: 'seqspec',
            help: 'seqspec to process barcodes',
            example: 'spec.yaml'
        } 
        
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
