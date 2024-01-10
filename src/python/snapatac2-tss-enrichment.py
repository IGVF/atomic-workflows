import snapatac2 as snap
import sys


fragment_file = sys.argv[1]
compressed_gtf_file = sys.argv[2]
output_file = sys.argv[3]
min_frag_cutoff = sys.argv[3]
tss_file = sys.argv[4]


data = snap.pp.import_data(
    fragment_file,
    chrom_sizes=snap.genome.hg38,
    sorted_by_barcode=False,
    min_num_fragments=min_frag_cutoff
)

snap.metrics.tsse(data, compressed_gtf_file)
snap.metrics.frip(data, tss_file)

data.obs.to_csv(output_file, index_label="barcode", sep="\t")
