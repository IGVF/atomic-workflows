// Enable DSL2
nextflow.enable.dsl=2

// print

process run_seqspec_test {
  debug true
  label 'seqspec_local'
  output:
    path "seqspec.print.out" , emit: seqspec_out
  script:
  """
    echo start run_seqspec_test
    echo The path is: $PATH
    touch seqspec.print.out
    echo finished run_seqspec_test
  """
}



 //     seqspec print $spec_yaml -o seqspec_print_out
 //output:
 //   path "seqspec.print.out" , emit: seqspec_out
process run_seqspec_print {
  debug true
  label 'seqspec_local'
  input:
    path(spec_yaml)
  output:
    path "seqspec.print.out" , emit: seqspec_out
  script:
  """
    ls
    echo I am running inside container: \$HOSTNAME
    echo start run_seqspec_print
    seqspec print $spec_yaml -o seqspec.print.out
    echo $spec_yaml
    ls
    echo finished seqspec print
  """
}

// seqspec index -t kb -m rna -r $RNA_R1_fastq_gz,$RNA_R2_fastq_gz $spec_yaml
process run_seqspec_index_rna_kb {
  debug true
  label 'seqspec_local'
  input:
    tuple path(fastq1), path(fastq2), path(fastq3), path(spec_yaml), path(whitelist_file)
    path modified_spec_yaml
  output:
    path "seqspec.technology.out" , emit: seqspec_technology_out_file
  script:
  """
    echo spec_yaml is $modified_spec_yaml
    echo RNA_R1_fastq_gz is $fastq1
    echo RNA_R2_fastq_gz is $fastq2
    echo RNA_R3_fastq_gz is $fastq3
    
    seqspec index -t kb -m rna -r $fastq1,$fastq2 $modified_spec_yaml > seqspec.technology.out
    cat seqspec.technology.out
    echo finished run_seqspec_index_rna   
  """
}

process run_seqspec_check {
  debug true
  label 'seqspec_local'
  input:
    tuple path(fastq1), path(fastq2), path(fastq3), path(spec_yaml), path(whitelist_file)
  output:
    path "seqspec.check.out" , emit: seqspec_check_out
  script:
  """
    echo start run_seqspec_check
    echo $spec_yaml
    seqspec check $spec_yaml > seqspec.check.out
    echo finished seqspec check spec_yaml
  """
}

process run_seqspec_modify_rna {
  debug true
  label 'seqspec_local'
  input:
    tuple path(fastq1), path(fastq2), path(fastq3), path(spec_yaml), path(whitelist_file)
  output:
    path "nf_seqspec_modify.yaml", emit: seqspec_modify_rna_out
  script:
  """
  echo start run_seqspec_modify_rna
  echo $fastq1
  echo $fastq2
  echo $fastq3
  echo $spec_yaml
  seqspec modify -m rna -o modrna1.yaml -r rna_R1.fastq.gz --region-id $fastq1 $spec_yaml
  seqspec modify -m rna -o modrna2.yaml -r rna_R2.fastq.gz --region-id $fastq2 modrna1.yaml
  seqspec modify -m rna -o nf_seqspec_modify.yaml -r rna_R2.fastq.gz --region-id $fastq2 modrna2.yaml
  echo finished seqspec modify rna
  """
}


process run_seqspec_modify_atac {
  debug true
  label 'seqspec_local'
  input:
    tuple path(fastq1), path(fastq2),path(fastq3), path(spec_yaml),path(whitelist_file)
  output:
    path "nf_seqspec_modify.yaml", emit: seqspec_modify_atac_out
  script:
  """
  echo start run_seqspec_modify_atac
  echo $fastq1
  echo $fastq2
  echo $fastq3
  echo $spec_yaml
  ls
  # if fastq3 is na.fasq - nothing will happen in the spec
  seqspec modify -m atac -o modatac1.yaml -r atac_R1.fastq.gz --region-id $fastq1 $spec_yaml
  seqspec modify -m atac -o modatac2.yaml -r atac_R2.fastq.gz --region-id $fastq2 modatac1.yaml
  seqspec modify -m atac -o modatac3.yaml -r atac_R3.fastq.gz --region-id $fastq3 modatac2.yaml
  seqspec modify -m atac -o nf_seqspec_modify.yaml -r atac_R3.fastq.gz --region-id $fastq3 modatac3.yaml
  echo finished seqspec modify atac
  """
}