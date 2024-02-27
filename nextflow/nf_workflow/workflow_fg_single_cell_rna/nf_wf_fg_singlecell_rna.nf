// RNA workflow
include {run_cellatlas_build; run_jq_on_cellatlas} from './../../nf_processes/nf_prcs_cellatlas_build.nf'
include {run_kb_ref_with_jq_commands} from './../../nf_processes/nf_prcs_kallisto_bustools.nf'

workflow {
    println 'in the RNA workflow'
    // STEP 1: cell input processing
    files_ch = Channel
        .fromPath(params.FASTQS_SPEC_CH)
        .splitCsv(header: true, sep: '\t')
        .map { row -> tuple(file(row.R1_FASTQ_GZ), file(row.R2_FASTQ_GZ), file(row.seqspec), file(row.whitelist)) }
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

    // STEP 4: call kb_ref with the jq commands
    transriptome_file = channel.value(file(params.TRANSCRIPTOME_FA))
    run_kb_ref_with_jq_commands(params.KB_REF_WITH_JQ_COMMANDS, jq_commands_out, transriptome_file, genome_fasta_gz, genes_gtf)
    //--------STEP 4 END -------------
}
