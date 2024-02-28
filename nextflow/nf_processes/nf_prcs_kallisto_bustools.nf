
// Enable DSL2
nextflow.enable.dsl=2

// cell atlas commnads:
// #### RNA
//kb ref -i rna_cellatlas_out/index.idx -g rna_cellatlas_out/t2g.txt -f1 // rna_cellatlas_out/transcriptome.fa http://ftp.ensembl.org/pub/release-109/fasta/homo_sapiens/dna/Homo_sapiens.GRCh38.dna.primary_assembly.fa.gz http://ftp.ensembl.org/pub/release-109/gtf/homo_sapiens/Homo_sapiens.GRCh38.109.gtf.gz
//kb count -i rna_cellatlas_out/index.idx -g rna_cellatlas_out/t2g.txt -x 0,0,16:0,16,28:1,0,102 -w RNA-737K-arc-v1.txt -o rna_cellatlas_out --h5ad -t 2 fastqs/rna_R1_SRR18677629.fastq.gz fastqs/rna_R2_SRR18677629.fastq.gz

//kb ref -i rna_cellatlas_out/index.idx -g rna_cellatlas_out/t2g.txt -f1 rna_cellatlas_out/transcriptome.fa http://ftp.ensembl.org/pub/release-109/fasta/homo_sapiens/dna/Homo_sapiens.GRCh38.dna.primary_assembly.fa.gz http://ftp.ensembl.org/pub/release-109/gtf/homo_sapiens/Homo_sapiens.GRCh38.109.gtf.gz

// TODO: ask Sina about -k 21 -m 256G. will that make sure that we dont have memory issue?
process run_kb_ref {
  label 'kb_ref'
  debug true
  input:
    path dna_assempbly_fa_gz
    path gtf_gz
  output:
    path "index.idx",emit: index_out
    path  "t2g.txt",emit: t2g_txt_out
  script:
  """
  echo dna_assempbly_fa_gz is $dna_assempbly_fa_gz
  echo gtf_gz is $gtf_gz
  kb ref --tmp tmp2 --overwrite -i index.idx -g t2g.txt -f1 transcriptome.fa $dna_assempbly_fa_gz $gtf_gz
  echo finished callling kb ref
  """
}

process run_kb_ref_with_jq_commands {
  label 'kb_ref_from_jq'
  debug true
  input:
    val script_name
    path jq_commands_file
    path transcriptome_file
    path genome_fasta_gz
    path gene_gtf
  output:
    path "index.idx",emit: index_out
    path  "t2g.txt",emit: t2g_txt_out
  script:
  """
  echo start run_kb_ref_with_jq_commands
  /usr/local/bin/$script_name 'index.idx' 't2g.txt' $transcriptome_file $genome_fasta_gz $gene_gtf $jq_commands_file
  echo finished run_kb_ref_with_jq_commands
  """
}


process run_download_kb_idx {
  label 'download_kb_idx'
  debug true
  input:
    val org
  output:
    path "index.idx",emit: index_out
    path  "t2g.txt",emit: t2g_txt_out
  script:
  """
  echo kb ref -d $org -i index.idx -g t2g.txt --verbose
  kb ref -d $org -i index.idx -g t2g.txt --verbose
  ls
  """
}

// !time kb count -i ref_cDNA/transcriptome.idx 
// -g ref_cDNA/transcripts_to_genes.txt 
// -x $(seqspec index -t kb -m RNA -r RNA-R1.fastq.gz,RNA-R2.fastq.gz broad_human_jamboree_test_spec-eugenio-fix.yaml)
//  -o out/ 
// -w sai_192_whitelist.txt 
// rna/BMMC_single_donor_RNA_L001_R1.fastq.gz rna/BMMC_single_donor_RNA_L001_R2.fastq.gz


// kb count -i index.idx -g t2g.txt -x 0,0,16:0,16,28:1,0,102 -w RNA-737K-arc-v1.txt -o rna_cellatlas_out --h5ad -t 2 fastqs/rna_R1_SRR18677629.fastq.gz fastqs/rna_R2_SRR18677629.fastq.gz
/*
process run_kb_count {
  label 'kb_count'
  debug true
  // conda 'kb-python'
  input:
    path index_file
    path t2g_txt
    path gtf_gz
    tuple path(fastq1), path(fastq2), path(fastq3), path(spec_yaml), path(whitelist_file),  
    path technology
  output:
    path 'out/counts_unfiltered/adata.h5ad', emit: adata_out_h5ad
  script:
  """
  echo start run_kb_count !!!
  echo $index_file
  echo $t2g_txt
  echo $fastq1
  echo $fastq2
  echo $technology
  technology_string=\$(cat $technology)
  echo \$technology_string
  mkdir out
  kb count -i $index_file -g $t2g_txt -x \$technology_string -w $whitelist_file -o out --h5ad -t $task.cpus $fastq1 $fastq2
  echo finished run_kb_count
  """
}

*/

// TODO: fix the CPU parameter
process run_kb_count_rna {
  label 'kb_count_rna'
  debug true
  input:
    val script_name
    path index_file
    path t2g_txt
    path gtf_gz
    tuple path(fastq1), path(fastq2), path(fastq3), path(spec_yaml), path(whitelist_file),  val(seqspec_rna_region_id)
    path technology_file
    val cpus
  output:
    path 'out/counts_unfiltered/adata.h5ad', emit: adata_out_h5ad
  script:
  """
  echo start run_kb_count_rna !!!
  echo $index_file
  echo $t2g_txt
  echo $fastq1
  echo $fastq2
  echo $technology
  
  /usr/local/bin/$script_name $index_file $t2g_txt $technology_file $whitelist_file $fastq1 $fastq2 $cpus
  $fastq1 $fastq2 $spec_yaml "rna" $technology
  
  echo finished run_kb_count_rna
  """
}
