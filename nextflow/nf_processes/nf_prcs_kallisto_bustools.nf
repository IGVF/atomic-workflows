// Enable DSL2
nextflow.enable.dsl=2

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
    path "t2g.txt",emit: t2g_txt_out
  script:
  """
  echo start run_kb_ref_with_jq_commands
  /usr/local/bin/$script_name index.idx t2g.txt $transcriptome_file $genome_fasta_gz $gene_gtf $jq_commands_file
  echo finished run_kb_ref_with_jq_commands
  """
}



// TODO: fix the CPU parameter
// path 'out/counts_unfiltered/adata.h5ad', emit: adata_out_h5ad
// path 'out/counts_unfiltered/cells_x_genes.barcodes.txt', emit: cells_x_genes_barcodes_out
// path 'out/run_info.json', emit: kb_count_run_info_json
// path 'out/inspect.json', emit: kb_count_inspect_json
    
process run_kb_count_rna {
  label 'kb_count_rna'
  debug true
  input:
    val script_name
    path index_file
    path t2g_txt
    path gtf_gz
    tuple path(fastq1), path(fastq2), path(spec_yaml), path(whitelist_file), val(seqspec_rna_region_id), val(subpool)
    path technology_file
    val cpus
  output:
    path "out/counts_unfiltered/adata.h5ad", emit: adata_out_h5ad
    path "out/counts_unfiltered/cells_x_genes.barcodes.txt", emit: cells_x_genes_barcodes_out
    path "out/run_info.json", emit: kb_count_run_info_json
    path "out/inspect.json", emit: kb_count_inspect_json
    
  script:
  """
  echo start run_kb_count_rna !!!
  echo $index_file
  echo $t2g_txt
  echo $fastq1
  echo $fastq2
  echo $technology_file
  
  /usr/local/bin/$script_name $index_file $t2g_txt $technology_file $whitelist_file $fastq1 $fastq2 $cpus
  
  echo finished run_kb_count_rna
  """
}

process run_jq_on_kb_count_outputs_to_logs {
  label 'kb_count_output_jq'
  debug true
  input:
    val script_name
    val output_file_name
    path run_info_json
    path inspect_json
  output:
    path "${output_file_name.baseName.replace('.', '_')}.json", emit: kb_count_out_json_files

  script:
  """  
  echo '------ Start run_jq_on_kb_count_outputs_to_logs ------'
  echo 'Input script_name: $script_name'
  echo 'Input output_file_name: $output_file_name'
  echo 'Input run_info_json: $run_info_json'
  echo 'Input inspect_json: $inspect_json'
  
  output_path="${output_file_name.baseName.replace('.', '_')}.json"
  echo "Constructed output path: $output_path"
 
  /usr/local/bin/$script_name $run_info_json $inspect_json $output_path
  
  echo '------ Finished run_jq_on_kb_count_outputs_to_logs ------'
  """
}




/*

interleaved_files_string=$(paste -d' ' <(printf "%s\n" BMMC_single_donor_RNA_L001_R1_corrected.fastq.gz BMMC_single_donor_RNA_L002_R1_corrected.fastq.gz) <(printf "%s\n" BMMC_single_donor_RNA_L001_R2_corrected.fastq.gz BMMC_single_donor_RNA_L002_R2_corrected.fastq.gz) | tr -s ' ')


kb count -i index.idx -g t2g.txt -x 1,0,24:1,24,34:0,0,50 -w sai_192_whitelist.txt -o BMMC-single-donor.rna.align.cellatlas.hg38 --h5ad -t 2 $interleaved_files_string

*/