// Enable DSL2
nextflow.enable.dsl=2

// parameters that should be piped from the workflow 

// The process was copied from https://github.com/LucasSilvaFerreira/pipeline_perturbseq_like/blob/master/main.nf
process downloadGenome {
  debug true
  cache 'lenient'
  container 'eilalan/igvf-seqspec-cellatlas:latest'
  input:
    val genome_path
  output:
    path "genome.fa.gz" , emit: genome
  script:
  """
    wget $genome_path -O genome.fa.gz 
  """
}