// Enable DSL2
nextflow.enable.dsl=2

// The process was copied from https://github.com/LucasSilvaFerreira/pipeline_perturbseq_like/blob/master/main.nf
process downloadReference {
  debug true
  cache 'lenient'
  input:
    val ref_name 
    path k_bin 

  output:
    path "transcriptome_index.idx" , emit: transcriptome_idx
    path "transcriptome_t2g.txt"   , emit: t2t_transcriptome_index
  script:
    if (params.CUSTOM_REFERENCE)
      """
        cp $params.CUSTOM_REFERENCE_IDX  transcriptome_index.idx
        cp $params.CUSTOM_REFERENCE_T2T  transcriptome_t2g.txt
      """
    else
      """
        kb ref -d $ref_name -i transcriptome_index.idx -g transcriptome_t2g.txt --kallisto ${k_bin}
      """
}