// Enable DSL2
nextflow.enable.dsl=2

// print

process run_seqspec_test {
  debug true
  label 'seqspec'
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
  label 'seqspec'
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

// TODO: see how to pass the names of the files and not the full FASTQ file
// seqspec index -t kb -m rna -r $fastq1,$fastq2 $spec_yaml > seqspec.technology.out
process run_retrieve_seqspec_technology_rna {
  debug true
  label 'seqspec_technology'
  input:
    val script_name
    tuple path(fastq1), path(fastq2), path(spec_yaml), path(whitelist_file),  val(seqspec_rna_region_id)
    path updated_seqspec_modify_rna
  output:
    path "seqspec.rna.technology.out" , emit: seqspec_rna_technology_out
  script:
  """
    echo start run_retrieve_seqspec_technology_rna
    echo spec_yaml is $spec_yaml
    echo fastq1 is $fastq1
    echo fastq2 is $fastq2
    /usr/local/bin/$script_name $fastq1 $fastq2 $updated_seqspec_modify_rna $seqspec_rna_region_id seqspec.rna.technology.out
    cat seqspec.rna.technology.out
    echo finished run_retrieve_seqspec_technology_rna   
  """
}


process run_seqspec_check {
  debug true
  label 'seqspec'
  input:
    tuple path(fastq1), path(fastq2), path(spec_yaml), path(whitelist_file),  val(seqspec_rna_region_id)
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
  label 'seqspec_modify'
  
  input:
    val script_name
    tuple path(fastq1), path(fastq2), path(spec_yaml), path(whitelist_file), val(seqspec_rna_region_id), val(subpool)
  
  output:
    path "seqspec_modify_rna_file_names.yaml", emit: seqspec_modify_rna_out
  
  script:
  """
  echo "=== Start run_seqspec_modify_rna ==="
  echo " Input Fastq Files:"
  echo " R1: $fastq1"
  echo " R2: $fastq2"
  echo " Specification YAML: $spec_yaml"
  echo " Whitelist File: $whitelist_file"
  echo " seqspec_rna_region_id is: $seqspec_rna_region_id"
  
  /usr/local/bin/$script_name $fastq1 $fastq2 $spec_yaml seqspec_modify_rna_file_names.yaml $seqspec_rna_region_id
  
  echo "=== Finished seqspec modify rna ==="
  """
}

/*
  ls
  # if fastq3 is na.fasq - nothing will happen in the spec
  seqspec modify -m atac -o modatac1.yaml -r atac_R1.fastq.gz --region-id $fastq1 $spec_yaml
  seqspec modify -m atac -o modatac2.yaml -r atac_R2.fastq.gz --region-id $fastq2 modatac1.yaml
  #seqspec modify -m atac -o modatac3.yaml -r atac_R3.fastq.gz --region-id $fastq3 modatac2.yaml
  seqspec modify -m atac -o nf_seqspec_modify.yaml -r atac_R3.fastq.gz --region-id $fastq3 modatac3.yaml
  echo finished seqspec modify atac
*/

process run_seqspec_modify_atac {
  debug true
  label 'seqspec_modify'
  input:
    val script_name
    tuple path(fastq1), path(fastq2),path(fastq3),path(fastq4),path(barcode1_fastq),path(barcode2_fastq), path(spec_yaml), path(whitelist_file),val(subpool),path(conversion_dict),val(prefix),val(seqspec_atac_region_id)
  output:
    path "seqspec_modify_atac_file_names.yaml", emit: seqspec_modify_atac_out
  script:
  """
  echo "=== Start run_seqspec_modify_atac ==="
  echo " Input Fastq Files:"
  echo " R1: $fastq1"
  echo " R2: $fastq2"
  echo " R3: $fastq3"
  echo " R4: $fastq4"
  echo " Specification YAML: $spec_yaml"
  echo " seqspec_atac_region_id is: $seqspec_atac_region_id"
  /usr/local/bin/$script_name $fastq1 $fastq2 $spec_yaml seqspec_modify_atac_file_names.yaml $seqspec_atac_region_id
  echo "=== Finished seqspec modify atac ==="
  """
}