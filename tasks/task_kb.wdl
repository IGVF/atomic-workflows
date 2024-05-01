version 1.0

# TASK
# rna-kb

    
task kb {

    meta {
        version: 'v0.1'
        author: 'Siddarth Wekhande (swekhand@broadinstitute.org) at Broad Institute of MIT and Harvard'
        description: 'align RNA using kb'
    }
    
    input {
         # This task takes in input the raw RNA fastqs and their associated index string and whitelist, processes the barcodes accordingly, aligns them to the genome, and outputs the count matrices.
                
        Array[File] read1_fastqs #These filenames must EXACTLY match the ones specified in seqspec
        Array[File] read2_fastqs #These filenames must EXACTLY match the ones specified in seqspec
        
        String modality = "rna"
        
        String index_string
        
        File genome_fasta
        File genome_gtf
        File barcode_whitelist 
        File? replacement_list
        
        String? kb_workflow
        String? subpool = "none"
        String genome_name # GRCh38, mm10
        String prefix = "test-sample"
        String chemistry
        String strand = "unstranded"
        String matrix_sum = "total"
        
        Int threads = 4
        
        #Will these be used? Need to run tests to optimize
        Int? cpus = 4
        Float? disk_factor = 1
        Float? memory_factor = 0.15
        
        #TODO:We need to setup a docker registry.
        String? docker_image = "swekhande/igvf:task_kb"
        
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
    String directory = "${prefix}.rna.align.kb.${genome_name}"
    String mtx_tar = "${prefix}.rna.align.kb.${genome_name}.mtx.tar.gz"
    String alignment_json = "${prefix}.rna.align.kb.${genome_name}/run_info.json"
    String barcode_matrics_json = "${prefix}.rna.align.kb.${genome_name}/inspect.json"

    command <<<
    
        set -e

        bash $(which monitor_script.sh) 1>&2 &
        
        #set up fastq order as l1r1, l1r2, l2r1, l2r2, etc.
        interleaved_files_string=$(paste -d' ' <(printf "%s\n" ~{sep=" " read1_fastqs}) <(printf "%s\n" ~{sep=" " read2_fastqs}) | tr -s ' ')
           
        mkdir ~{directory}
        
        if [[ '~{barcode_whitelist}' == *.gz ]]; then
            echo '------ Decompressing the RNA barcode inclusion list ------' 1>&2
            gunzip -c ~{barcode_whitelist} > barcode_inclusion_list.txt
        else
            echo '------ No decompression needed for the RNA barcode inclusion list ------' 1>&2
            cat ~{barcode_whitelist} > barcode_inclusion_list.txt
        fi
        
        #build index based on kb_workflow
        if [[ '~{kb_workflow}' == "standard" ]]; then   
        
            #build ref standard
            kb ref \
                -i ~{directory}/index.idx \
                -g ~{directory}/t2g.txt \
                -f1 ~{directory}/transcriptome.fa \
                ~{genome_fasta} \
                ~{genome_gtf}
                        
            #kb count standard
            kb count \
                -i ~{directory}/index.idx \
                -g ~{directory}/t2g.txt \
                -x ~{index_string} \
                -w barcode_inclusion_list.txt \
                --strand ~{strand} \
                ~{if defined(replacement_list) then "-r ~{replacement_list}" else ""} \
                -o ~{directory} \
                --h5ad \
                --gene-names \
                -t ~{threads} \
                $interleaved_files_string 
        
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
                        
            #kb count nac    
            kb count \
                --workflow=nac \
                -i ~{directory}/index.idx \
                -g ~{directory}/t2g.txt \
                -c1 ~{directory}/cdna.txt \
                -c2 ~{directory}/nascent.txt \
                --sum=~{matrix_sum} \
                -x ~{index_string} \
                -w barcode_inclusion_list.txt \
                --strand ~{strand} \
                ~{if defined(replacement_list) then "-r ~{replacement_list}" else ""} \
                -o ~{directory} \
                --h5ad \
                --gene-names \
                -t ~{threads} \
                $interleaved_files_string 
                
        fi

        #if subpool is defined add subpool suffix
        if [ '~{subpool}' != "none" ]; then
        
            #add subpool suffix in .h5ad file
            python3 $(which modify_barcode_h5.py) ~{directory}/counts_unfiltered/adata.h5ad ~{subpool}

            #add subpool suffix in barcodes.txt file
            sed -i 's/$/_~{subpool}/' ~{directory}/counts_unfiltered/cells_x_genes.barcodes.txt
        
        fi
        
        if [[ '~{kb_workflow}' == "nac" ]]; then  
        
            #python script to create aggregated counts h5ad    
            
            python3 $(which write_h5ad_from_mtx.py) ~{directory}/counts_unfiltered/cells_x_genes.~{matrix_sum}.mtx \
            ~{directory}/counts_unfiltered/cells_x_genes.barcodes.txt \
            ~{directory}/counts_unfiltered/cells_x_genes.genes.names.txt
            
            mv output.h5ad ~{prefix}.rna.align.kb.~{genome_name}.cells_x_genes.~{matrix_sum}.h5ad
        
        fi
        
        tar -kzcvf ~{directory}.tar.gz ~{directory}
        
        tar -czvf ~{mtx_tar}  --exclude='*.h5ad' -C ~{directory}/counts_unfiltered/ .

        mv ~{directory}/counts_unfiltered/adata.h5ad ~{prefix}.rna.align.kb.~{genome_name}.count_matrix.h5ad

    >>>

    output {
        File rna_output = "~{directory}.tar.gz"
        File rna_alignment_json = alignment_json
        File rna_barcode_matrics_json = barcode_matrics_json
        File rna_mtxs_tar = mtx_tar
        File rna_mtxs_h5ad = "~{prefix}.rna.align.kb.~{genome_name}.count_matrix.h5ad"
        File? rna_aggregated_counts_h5ad = "~{prefix}.rna.align.kb.~{genome_name}.cells_x_genes.~{matrix_sum}.h5ad"
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
            help: 'List of raw read1 fastqs that will be corrected and processed using kb',
            example: ['l0.r1.fq.gz', 'l1.r1.fq.gz']
        }
        
        read2_fastqs: {
            description: 'List of input read2 fastqs.',
            help: 'List of raw read2 fastqs that will be corrected and processed using kb',
            example: ['l0.r2.fq.gz', 'l1.r2.fq.gz']
        }
        
        modality: {
            description: 'Modality',
            help: 'Fixed to RNA',
            example: 'rna'
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