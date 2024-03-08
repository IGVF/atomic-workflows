// RNA workflow

include {run_add_subpool_to_rna_kb_cout_outputs} from './../../nf_processes/nf_prcs_rna_kb_count_subpool_update.nf'
include {run_cellatlas_build;run_jq_on_cellatlas} from './../../nf_processes/nf_prcs_cellatlas_build.nf'
include {run_kb_ref_with_jq_commands;run_kb_count_rna;run_jq_on_kb_count_outputs_to_logs} from './../../nf_processes/nf_prcs_kallisto_bustools.nf'
include {run_retrieve_seqspec_technology_rna;run_seqspec_modify_rna} from './../../nf_processes/nf_prcs_seqspec_utils.nf'
include {rna_calculate_qc_metrics} from './../../nf_processes/nf_prcs_rna_qc_metrics.nf'
include {rna_plot_qc_metrics_prcs} from './../../nf_processes/nf_prcs_rna_qc_plots.nf'


workflow {
    println 'in the RNA workflow'
    // STEP 1: cell input processing    
    files_ch = Channel
    .fromPath(params.FASTQS_SPEC_CH)
    .splitCsv(header: true, sep: '\t')
    .map { row -> tuple(file(row.R1_FASTQ_GZ), file(row.R2_FASTQ_GZ), file(row.seqspec), file(row.whitelist), row.seqspec_rna_region_id, row.subpool) }
    .set { sample_run_ch }

    //--------STEP 1 END -------------

    // STEP 2: call cellatlas build
    genome_fasta_gz = channel.value(file(params.GENOME_FASTA_GZ))
    genes_gtf = channel.value(file(params.GENES_GTF))
    run_cellatlas_build(params.CELLATLAS_BUILD_SCRIPT, 'rna', genome_fasta_gz, genes_gtf, sample_run_ch)
    cellatlas_run_info_out_json = run_cellatlas_build.out.cellatlas_run_info_out_json
    //--------STEP 2 END -------------

    // STEP 3: call jq with cellatlas build output
    run_jq_on_cellatlas(params.JQ_CELLATLAS_BUILD_JSON_SCRIPT, cellatlas_run_info_out_json)
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
    
    // STEP 5.2: get the technology from the modified seqspec. TODO: uncomment
    // run_retrieve_seqspec_technology_rna(params.RETRIEVE_SEQSPEC_TECHNOLOGY,sample_run_ch,seqspec_modify_rna_out)
    // seqspec_rna_technology_out=run_retrieve_seqspec_technology_rna.out.seqspec_rna_technology_out
    //--------STEP 5 END -------------
    
    
    // STEP 6: call kb count
    // 6.1
    // TODO: comment debug. this is the file content"1,0,24:1,24,34:0,0,50"
    seqspec_rna_technology_out=channel.value(file(params.KB_COUNT_TECHNOLGY_FILE_DEBUG))

    //run_kb_count_rna(params.EXECUTE_KB_COUNT_RNA_SCRIPT,index_out,t2g_txt_out,genes_gtf,sample_run_ch,seqspec_rna_technology_out,params.KB_COUNT_CPUS)
    //adata_out_h5ad=run_kb_count_rna.out.adata_out_h5ad
    //kb_count_run_info_json=run_kb_count_rna.out.kb_count_run_info_json
    //kb_count_inspect_json=run_kb_count_rna.out.kb_count_inspect_json
    //cells_x_genes_barcodes_out=run_kb_count_rna.out.cells_x_genes_barcodes_out
    
    // 6.2
    // debug: // TODO: comment debug. 
    adata_out_h5ad = channel.value(file(params.adata_out_h5ad_debug))
    kb_count_run_info_json=channel.value(file(params.kb_count_run_info_json_debug))
    kb_count_inspect_json=channel.value(file(params.kb_count_inspect_json_debug))
    cells_x_genes_barcodes_out=channel.value(file(params.cells_x_genes_barcodes_out_debug))
    //--------STEP 6 END -------------
    
    // STEP 7: call subpool
    println "Calling run_add_subpool_to_rna_kb_cout_outputs with the following inputs:"
    println "params.RNA_MODIFY_KB_COUNT_H5AD_WITH_SUBPOOL: ${params.RNA_MODIFY_KB_COUNT_H5AD_WITH_SUBPOOL}"
    println "params.RNA_MODIFY_CELL_GENE_WITH_SUBPOOL: ${params.RNA_MODIFY_CELL_GENE_WITH_SUBPOOL}"
    println "adata_out_h5ad: ${adata_out_h5ad}"
    println "cells_x_genes_barcodes_out: ${cells_x_genes_barcodes_out}"
    run_add_subpool_to_rna_kb_cout_outputs(params.RNA_MODIFY_KB_COUNT_H5AD_WITH_SUBPOOL,params.RNA_MODIFY_CELL_GENE_WITH_SUBPOOL,adata_out_h5ad,cells_x_genes_barcodes_out,sample_run_ch) 
    kb_count_h5ad_file_subpool=run_add_subpool_to_rna_kb_cout_outputs.out.kb_count_h5ad_file_subpool
    kb_count_fragments_file_subpool=run_add_subpool_to_rna_kb_cout_outputs.out.kb_count_fragments_file_subpool
    //--------STEP 7 END -------------
    
    
    // STEP 8: call cellatlas outputs to logs
    // run_jq_on_kb_count_outputs_to_logs(params.RNA_JQ_CELLATLAS_OUTPUT_TO_LOG,kb_count_run_info_json,kb_count_inspect_json,params.LOG_FILE_NAME)
    //--------STEP 8 END -------------
    // STEP 8: call cellatlas outputs to logs
    println "Calling run_jq_on_kb_count_outputs_to_logs with the following inputs:"
    println "run_jq_on_kb_count_outputs_to_logs: params.RNA_JQ_CELLATLAS_OUTPUT_TO_LOG: ${params.RNA_JQ_CELLATLAS_OUTPUT_TO_LOG}"
    println "run_jq_on_kb_count_outputs_to_logs: kb_count_run_info_json: ${kb_count_run_info_json}"
    println "run_jq_on_kb_count_outputs_to_logs: kb_count_inspect_json: ${kb_count_inspect_json}"
    println "run_jq_on_kb_count_outputs_to_logs: params.LOG_FILE_NAME: ${params.LOG_FILE_NAME}"
    output_file_name = params.LOG_FILE_NAME.replaceAll(/\.txt$/, '')

    run_jq_on_kb_count_outputs_to_logs(params.RNA_JQ_CELLATLAS_OUTPUT_TO_LOG, kb_count_run_info_json, kb_count_inspect_json, output_file_name)
    //--------STEP 8 END -------------

    // STEP 9: rna_calculate_qc_metrics
    rna_calculate_qc_metrics(params.RNA_QC__METRICS_SCRIPT,kb_count_h5ad_file_subpool,sample_run_ch)
    rna_qc_metrics_tsv=rna_calculate_qc_metrics.out.rna_qc_metrics_tsv


    // STEP 10: prepare QC graphs for RNA
    umi_rank_plot_all_output_file_name='umi_plot_all_'+output_file_name+'.png'
    umi_rank_plot_top_output='umi_plot_top_'+output_file_name+'.png'
    gene_umi_plot_file_output='gene_umi_'+output_file_name+'.png'
    rna_plot_qc_metrics_prcs(params.RNA_QC_PLOT_SCRIPT,params.RNA_QC_PLOT_HELPER_SCRIPT,rna_qc_metrics_tsv,params.UMI_CUTOFF,params.GENE_CUTOFF,umi_rank_plot_all_output_file_name,umi_rank_plot_top_output,gene_umi_plot_file_output)

}
