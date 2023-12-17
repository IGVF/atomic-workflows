// Enable DSL2
nextflow.enable.dsl=2


// The process was copied from https://github.com/LucasSilvaFerreira/pipeline_perturbseq_like/blob/master/main.nf
process downloadGTF {
  debug true
  cache 'lenient'
  input:
      val gtf_gz_path
  output:
      path "transcripts.gtf", emit: gtf
  script:
      if (params.CUSTOM_REFERENCE)
      """ 
        cp $params.CUSTOM_GTF_PATH transcripts.gtf
      """ 
      else
      """    
        wget -O - $gtf_gz_path | gunzip -c > transcripts.gtf
      """ 

}