version 1.0

# TASK
# rna-cellatlas

    
task cellatlas_rna {

    meta {
        version: 'v0.1'
        author: 'Siddarth Wekhande (swekhand@broadinstitute.org) at Broad Institute of MIT and Harvard'
        description: 'align RNA using cellatlas'
    }
    
    input {
         # This task takes in input the raw RNA fastqs and their associated seqspec, processes the barcodes accordingly and aligns them to the genome.
                
        Array[File] read1_fastqs #These filenames must EXACTLY match the ones specified in seqspec
        Array[File] read2_fastqs #These filenames must EXACTLY match the ones specified in seqspec
        
        String modality = "rna"
        
        Array[File] seqspecs
        
        File genome_fasta
        File genome_gtf
        Array[File] barcode_whitelists #These filenames must EXACTLY match the ones specified in seqspec
        
        String? kb_workflow
        String? subpool = "none"
        String genome_name # GRCh38, mm10
        String prefix = "test-sample"
        String chemistry
        
        #Will these be used? Need to run tests to optimize
        Int? cpus = 4
        Float? disk_factor = 1
        Float? memory_factor = 0.15
        
        #TODO:We need to setup a docker registry.
        String? docker_image = "swekhande/igvf:task_cellatlas_rna"
        
    }
    
    
    # Determine the size of the input
    Float input_file_size_gb = size(read1_fastqs, "G") + size(read2_fastqs, "G")

    # Determining memory size base on the size of the input files.
    Float mem_gb = 24.0 + memory_factor * input_file_size_gb

    # Determining disk size base on the size of the input files.
    Int disk_gb = round(40.0 + disk_factor * input_file_size_gb)

    # Determining disk type base on the size of disk.
    String disk_type = if disk_gb > 375 then "SSD" else "LOCAL"

    # Define the output names
    String directory = "${prefix}.rna.align.cellatlas.${genome_name}"
    String count_matrix = "${prefix}.rna.align.cellatlas.${genome_name}.tar.gz"
    String alignment_json = "${prefix}.rna.align.cellatlas.${genome_name}/run_info.json"
    String barcode_matrics_json = "${prefix}.rna.align.cellatlas.${genome_name}/inspect.json"

    command <<<
    
        set -e

        bash $(which monitor_script.sh) 1>&2 &
         
        # cellatlas build
        cp ~{sep=" " barcode_whitelists} .
        
        interleaved_files_string=$(paste -d' ' <(printf "%s\n" ~{sep=" " read1_fastqs}) <(printf "%s\n" ~{sep=" " read2_fastqs}) | tr -s ' ')
            
        echo '------ cell atlas build ------' 1>&2
           
        cellatlas build \
        -o ~{directory} \
        -m ~{modality} \
        -s ~{seqspecs[0]} \
        -fa ~{genome_fasta} \
        -g ~{genome_gtf} \
        ~{read1_fastqs[0]} ~{read2_fastqs[0]}
        
        echo '------ RNA bash commands ------' 1>&2
        
        jq  -r '.commands[] | values[] | join("\n")' ~{directory}/cellatlas_info.json 1>&2
        
        
        #build index based on kb_workflow
        if [[ '~{kb_workflow}' == "standard" ]]; then    
            #build ref
            kb ref -i ~{directory}/index.idx -g ~{directory}/t2g.txt -f1 ~{directory}/transcriptome.fa ~{genome_fasta} ~{genome_gtf}
            
            #if shareseq, use fixed x_string since already corrected or extract from cell-atlas
            
            #kb count 
            [[ '~{chemistry}' == "shareseq" ]] && kb count -i ~{directory}/index.idx -g ~{directory}/t2g.txt -x 1,0,24:1,24,34:0,0,50 -w ~{sep=" " barcode_whitelists} -o ~{directory} --h5ad -t 4 $interleaved_files_string || kb count -i ~{directory}/index.idx -g ~{directory}/t2g.txt $(grep -oE '\-x [^ ]+' ~{directory}/cellatlas_info.json) $(grep -oE '\-w [^ ]+' ~{directory}/cellatlas_info.json) -o ~{directory} --h5ad -t 4 $interleaved_files_string

        
        else
            #build ref
            kb ref --workflow=nac -i ~{directory}/index.idx -g ~{directory}/t2g.txt -c1 ~{directory}/cdna.txt -c2 ~{directory}/nascent.txt -f1 ~{directory}/cdna.fasta -f2 ~{directory}/nascent.fasta ~{genome_fasta} ~{genome_gtf}
            
            #if shareseq, use fixed x_string since already corrected or extract from cell-atlas
            
            #kb count   
            [[ '~{chemistry}' == "shareseq" ]] && kb count --workflow=nac -i ~{directory}/index.idx -g ~{directory}/t2g.txt -c1 ~{directory}/cdna.txt -c2 ~{directory}/nascent.txt --sum=nucleus -x 1,0,24:1,24,34:0,0,50 -w ~{sep=" " barcode_whitelists} -o ~{directory} --h5ad -t 4 $interleaved_files_string || kb count --workflow=nac -i ~{directory}/index.idx -g ~{directory}/t2g.txt -c1 ~{directory}/cdna.txt -c2 ~{directory}/nascent.txt --sum=nucleus $(grep -oE '\-x [^ ]+' ~{directory}/cellatlas_info.json) $(grep -oE '\-w [^ ]+' ~{directory}/cellatlas_info.json) -o ~{directory} --h5ad -t 4 $interleaved_files_string
        
        fi

        #if subpool is defined add subpool suffix
        if [ '~{subpool}' != "none" ]; then
        
            #add subpool suffix in .h5ad file
            python3 $(which modify_barcode_h5.py) ~{directory}/counts_unfiltered/adata.h5ad ~{subpool}

            #add subpool suffix in barcodes.txt file
            sed -i 's/$/_~{subpool}/' ~{directory}/counts_unfiltered/cells_x_genes.barcodes.txt
        
        fi
        
        tar -kzcvf ~{directory}.tar.gz ~{directory}
        
        tar -czvf ~{count_matrix}  --exclude='*.h5ad' -C ~{directory}/counts_unfiltered/ .

        mv ~{directory}/counts_unfiltered/adata.h5ad ~{prefix}.rna.align.cellatlas.~{genome_name}.count_matrix.h5ad

    >>>

    output {
        File rna_output = "~{directory}.tar.gz"
        File rna_alignment_json = alignment_json
        File rna_barcode_matrics_json = barcode_matrics_json
        File rna_mtx_tar = count_matrix
        File rna_counts_h5ad = "~{prefix}.rna.align.cellatlas.~{genome_name}.count_matrix.h5ad"
    }

    runtime {
        cpu: cpus
        docker: "${docker_image}"
        singularity: "docker://${docker_image}"
        disks: "local-disk ${disk_gb} ${disk_type}"
        memory: "${mem_gb} GB"
    }
    
    parameter_meta {
    
        read1_fastqs: {
            description: 'List of input read1 fastqs.',
            help: 'List of raw read1 fastqs that will be corrected and processed using cellatlas',
            example: ['l0.r1.fq.gz', 'l1.r1.fq.gz']
        }
        
        read2_fastqs: {
            description: 'List of input read2 fastqs.',
            help: 'List of raw read2 fastqs that will be corrected and processed using cellatlas',
            example: ['l0.r2.fq.gz', 'l1.r2.fq.gz']
        }
        
        modality: {
            description: 'Modality',
            help: 'Fixed to RNA',
            example: 'rna'
        }
        
        seqspecs: {
            description: 'List of seqspecs',
            help: 'seqspec to process barcodes',
            example: ['spec.yaml']
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
