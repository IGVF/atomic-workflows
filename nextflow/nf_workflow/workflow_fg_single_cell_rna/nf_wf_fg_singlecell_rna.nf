// RNA workflow

include {run_synpase_download} from './../../nf_processes/nf_prcs_synapse_utils.nf'
include {run_kb_ref;run_kb_count;run_download_kb_idx} from './../../nf_processes/nf_prcs_kallisto_bustools.nf'
include {run_downloadFiles} from './../../nf_processes/nf_prcs_download_url_files.nf'
include {run_seqspec_print;run_seqspec_index_rna_kb;run_seqspec_check;run_seqspec_modify_rna} from './../../nf_processes/nf_prcs_seqspec_utils.nf'
include {scrna_calculate_qc_metrics} from './../../nf_processes/nf_prcs_rna_qc.nf'
include {scrna_plot_qc_metrics_prcs} from './../../nf_processes/nf_prcs_rna_qc_plots.nf'

workflow {
  println params.ENV_SYNAPSE_TOKEN
  println params.FASTQS_SPEC_CH

  
  // STEP 1: input processing
  files_ch = Channel
    .fromPath( params.FASTQS_SPEC_CH )
    .splitCsv( header: true, sep: '\t' )
    .map { row -> tuple( file(row.R1_fastq_gz), file(row.R2_fastq_gz), file(row.R3_fastq_gz), file(row.spec), file(row.whitelist) ) }
    .set { sample_run_ch }

  // STEP 2: modify seqspec with the file names
  run_seqspec_modify_rna(sample_run_ch)
  println ('after run_seqspec_modify_rna')
  
  // STEP 3: print spec file after update - seqspec_modify_rna_out
  run_seqspec_print(run_seqspec_modify_rna.out.seqspec_modify_rna_out)
  println ('after run_seqspec_print')

  // STEP 4: get the index parameter
  run_seqspec_index_rna_kb(sample_run_ch,run_seqspec_modify_rna.out.seqspec_modify_rna_out)
  println ('after run_seqspec_index_rna_kb')
  technology = run_seqspec_index_rna_kb.out.seqspec_technology_out_file
  println ('technology is $technology')
  
  // STEP 5: download the genome FA
  genome_fasta_ch = channel.value(file(params.GENOME_FASTA))
  println ('after genome_fasta_ch')

  // STEP 6: download the geonme gtf
  genome_gtf_ch = channel.value(file(params.GENOME_GZ_GTF))
  println ('after genome_gtf_ch')

  // STEP 7a: SIG KILL 9 - probably something with the machine properties
  // on a bigger machine with CPU. workaround - download reference
  run_kb_ref(genome_fasta_ch, genome_gtf_ch)
  println ('after run_kb_ref')
  index_out = run_kb_ref.out.index_out
  t2g_out = run_kb_ref.out.t2g_txt_out

  // STEP 7b-1: get the organism name
  genome_idx_org_ch = channel.value(params.ORGANISM)
  println ('after get organism')
  
  // STEP 7b-2: download the index of the organims
  //run_download_kb_idx(genome_idx_org_ch)
  //println ('after run_download_kb_idx')
  //index_out = run_download_kb_idx.out.index_out
  //t2g_out = run_download_kb_idx.out.t2g_txt_out
  
  // STEP 8: run alignment run_kb_count input: path index_file,path t2g_txt,path gtf_gz,tuple path(fastq1),path(fastq2),path(fastq3), path(spec_yaml),path technology
  run_kb_count(index_out,t2g_out,genome_gtf_ch,sample_run_ch,technology)
  println ('after run_kb_count')
  adata = run_kb_count.out.adata_out_h5ad
  
  // STEP 9: QC - for the test, will get a count H5 from the parameters
  // debug start
  //adata_file = file(params.ANNDATA_FILE)
  //println 'params.ANNDATA_FILE is: ' + params.ANNDATA_FILE
  //println 'adata_file is: ' + adata_file
  // debug end 

  subpool = channel.value(params.SUBPOOL)
  sc_rna_qc_script = params.SC_RNA_QC_SCRIPT
  scrna_calculate_qc_metrics(sc_rna_qc_script,adata,subpool)
  scrna_qc_metrics_tsv=scrna_calculate_qc_metrics.out.rna_qc_metrics_tsv
  println 'scrna_qc_metrics_tsv is: '+ scrna_qc_metrics_tsv
  
  // STEP 10: QC - plot the elbow
  umi_cutoff = params.UMI_CUTOFF
  gene_cutoff = params.GENE_CUTOFF
  // start debug
  //scrna_qc_metrics_tsv = file(params.RNA_DEBUG_QC)
  // end debug
  
  println 'scrna_qc_metrics_tsv is: '+ scrna_qc_metrics_tsv
  
  sc_rna_qc_plot_script = params.SC_RNA_QC_PLOT_SCRIPT
  println 'sc_rna_qc_plot_script is: '+ sc_rna_qc_plot_script
  
  sc_rna_qc_plot_helper_script = params.SC_RNA_QC_PLOT_HELPER_SCRIPT
  println 'sc_rna_qc_plot_helper_script is: '+ sc_rna_qc_plot_helper_script
    
  scrna_plot_qc_metrics_prcs(sc_rna_qc_plot_script,sc_rna_qc_plot_helper_script,scrna_qc_metrics_tsv,umi_cutoff,gene_cutoff, \
                             'umi_rank_plot_all_output.png','umi_rank_plot_top_output.png','gene_umi_plot_file_output.png')
    // out:
    //val umi_rank_plot_all
    //val umi_rank_plot_top
    //val gene_umi_plot_file
    
}