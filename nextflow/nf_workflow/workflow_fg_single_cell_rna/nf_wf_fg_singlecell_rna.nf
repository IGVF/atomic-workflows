// RNA workflow
include {run_cellatlas_build;run_jq_on_cellatlas} from './../../nf_processes/nf_prcs_cellatlas_build.nf'
include {run_kb_ref_with_jq_commands;run_kb_count_rna} from './../../nf_processes/nf_prcs_kallisto_bustools.nf'
include {run_retrieve_seqspec_technology_rna;run_seqspec_modify_rna} from './../../nf_processes/nf_prcs_seqspec_utils.nf'


workflow {
    println 'in the RNA workflow'
    // STEP 1: cell input processing
    files_ch = Channel
        .fromPath(params.FASTQS_SPEC_CH)
        .splitCsv(header: true, sep: '\t')
        .map { row -> tuple(file(row.R1_FASTQ_GZ), file(row.R2_FASTQ_GZ), file(row.seqspec), file(row.whitelist), row.seqspec_rna_region_id) }
        .set { sample_run_ch }
    //--------STEP 1 END -------------

    // STEP 2: call cellatlas build
    genome_fasta_gz = channel.value(file(params.GENOME_FASTA_GZ))
    genes_gtf = channel.value(file(params.GENES_GTF))
    run_cellatlas_build(params.CELLATLAS_BUILD_SCRIPT, 'rna', genome_fasta_gz, genes_gtf, sample_run_ch)
    cellatlas_out_json = run_cellatlas_build.out.cellatlas_out_json
    //--------STEP 2 END -------------

    // STEP 3: call jq with cellatlas build output
    run_jq_on_cellatlas(params.JQ_CELLATLAST_BUILD_JSON_SCRIPT, cellatlas_out_json)
    jq_commands_out = run_jq_on_cellatlas.out.jq_commands_out
    //--------STEP 3 END -------------

    // STEP 4: call kb ref with the jq commands
    transriptome_file = channel.value(file(params.TRANSCRIPTOME_FA))
    run_kb_ref_with_jq_commands(params.KB_REF_WITH_JQ_COMMANDS, jq_commands_out, transriptome_file, genome_fasta_gz, genes_gtf)
    index_out=run_kb_ref_with_jq_commands.out.index_out
    t2g_txt_out=run_kb_ref_with_jq_commands.out.t2g_txt_out
    //--------STEP 4 END -------------
    
    // STEP 5: get the technology from seqspec
    // STEP 5.1: update the spec.yaml file with the name of the fastq files:
    run_seqspec_modify_rna(params.EXECUTE_SEQSPEC_MODIFY,sample_run_ch)
    seqspec_modify_rna_out=run_seqspec_modify_rna.out.seqspec_modify_rna_out
    println ('after run_seqspec_modify_rna')
    
     // STEP 5.2: get the technology from the modified seqspec
    run_retrieve_seqspec_technology_rna(params.RETRIEVE_SEQSPEC_TECHNOLOGY,sample_run_ch,seqspec_modify_rna_out)
    seqspec_rna_technology_out=run_retrieve_seqspec_technology_rna.out.seqspec_rna_technology_out
    // STEP 5 END
    
    
    // STEP 6: call kb count
    // debug
    seqspec_rna_technology_out="1,0,24:1,24,34:0,0,50"
    run_kb_count_rna(params.EXECUTE_KB_COUNT_RNA_SCRIPT,index_out,t2g_txt_out,genes_gtf,sample_run_ch,seqspec_rna_technology_out,params.KB_COUNT_CPUS)
    adata_out_h5ad=run_kb_count_rna.out.adata_out_h5ad
    //--------STEP 6 END -------------
}
