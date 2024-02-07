// Enable DSL2
nextflow.enable.dsl=2

// Define default values for parameters
params.tss_bases_flank = 2000
params.tss_col_strand_info = 4
params.smoothing_window_size = 20

// TODO: check why do we need the prefix
// python3 /usr/local/bin/compute_tss_enrichment_bulk.py \
//     -e 2000 - Number of bases to extend to each side. (default= 2000)
//     -p 16 - Number or threads for parallel processing (default= 1)
//     --regions /cromwell_root/broad-buenrostro-pipeline-genome-annotations/IGVF_human_v43/gene_annotations/hg38.synapse_transcripts.TSS.bed \
//     --prefix "BMMC-single-donor.atac.qc.hg38" - Bed file with the regions of interest
//     no-singleton.bed.gz - the tabix file (no default)

// pt=ython parameters
//     tabix_file = sys.argv[1]
//     flank_size = int(sys.argv[2])
//     strand_column = int(sys.argv[3])
//     cpus = int(sys.argv[4])
//     regions_file = sys.argv[5]

// TODO: work with $task.cpus after it is fixed after I see that the right value is being used
process run_calculate_tss_enrichment_bulk {
  debug true
  label 'tss_bulk'
  input:
    tuple path(fastq1), path(fastq2),path(fastq3),path(fastq4),path(barcode1_fastq),path(barcode2_fastq), path(spec_yaml), path(whitelist_file),val(subpool),path(conversion_dict),val(prefix)
    val calculation_script
    path tbi_fragments
    path regions_file
    val tss_bases_flank
    val tss_col_strand_info
    val smoothing_window_size
    val CPUS_TO_USE
  output:
    path "${tbi_fragments}_enrichment_bulk.tss", emit: tss_bulk_out
  script:
  """
    echo 'start run_calculate_tss_enrichment'
    echo 'calculation_script is $calculation_script. check that it is: compute_tss_script.py'
    echo 'tbi_fragments: $tbi_fragments'
    echo 'tss_bases_flank: $tss_bases_flank'
    echo 'tss_col_strand_info: $tss_col_strand_info'
    echo 'smoothing_window_size: $smoothing_window_size'
    python3 /usr/local/bin/$calculation_script $tbi_fragments -e $tss_bases_flank -s $tss_col_strand_info -p $CPUS_TO_USE --prefix $prefix --regions $regions_file
    echo 'finished run_calculate_tss_enrichment'
  """
}

process run_calculate_tss_enrichment_snapatac2 {
  debug true
  label 'tss_snapatac2'
  input:
    tuple path(fastq1), path(fastq2), path(fastq3), path(fastq4), path(barcode1_fastq), path(barcode2_fastq), path(spec_yaml), path(whitelist_file), val(subpool), path(conversion_dict), val(prefix)
    val calculation_script
    path no_singleton_bed_gz
    path genes_gtf_gzip_file_out
    val min_frag_cutoff
  output:
    path "${prefix}.tss_enrichment_barcode_stats.tsv", emit: snapatac_tss_fragments_stats_out
  script:
  """
    echo 'start run_calculate_tss_enrichment_snapatac2'
    echo 'calculation_script is $calculation_script. check that it is: snapatac2'
    echo 'no_singleton_bed_gz: $no_singleton_bed_gz'
    echo 'genes_gtf_gzip_file_out: $genes_gtf_gzip_file_out'
    echo 'min_frag_cutoff: $min_frag_cutoff'
    echo 'prefix: $prefix'
    echo 'output file: ${prefix}.tss_enrichment_barcode_stats.tsv'

    python3 /usr/local/bin/$calculation_script $no_singleton_bed_gz $genes_gtf_gzip_file_out "${prefix}.tss_enrichment_barcode_stats.tsv" $min_frag_cutoff
    echo 'finished run_calculate_tss_enrichment_snapatac2'
  """
}
