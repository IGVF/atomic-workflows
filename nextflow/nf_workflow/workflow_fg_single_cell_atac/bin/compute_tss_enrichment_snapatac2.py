# based on https://github.com/IGVF/atomic-workflows/blob/dev/src/python/snapatac2-tss-enrichment.py

import argparse
import snapatac2 as snap
import sys

def main():
parser = argparse.ArgumentParser(description="Description of your script.")

parser.add_argument("fragment_file", help="Path to the fragment file.")
parser.add_argument("compressed_gtf_file", help="Path to the compressed GTF file.")
parser.add_argument("output_file", help="Path to the output file.")
parser.add_argument("min_frag_cutoff", type=int, help="Minimum fragment cutoff.")

args = parser.parse_args()

fragment_file = args.fragment_file
compressed_gtf_file = args.compressed_gtf_file
output_file = args.output_file
min_frag_cutoff = args.min_frag_cutoff

data = snap.pp.import_data(
  fragment_file,
  chrom_sizes=snap.genome.hg38,
  sorted_by_barcode=False,
  min_num_fragments=min_frag_cutoff
)

snap.metrics.tsse(data, compressed_gtf_file)

data.obs.to_csv(output_file, index_label="barcode", sep="\t")

if __name__ == "__main__":
  main()
