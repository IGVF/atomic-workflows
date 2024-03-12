import argparse
import snapatac2 as snap
from pathlib import Path
import os
import sys

def main():
    parser = argparse.ArgumentParser(description="Description of your script.")
    parser.add_argument("--fragment-file", dest="fragment_file", help="Path to the fragment file.")
    parser.add_argument("--compressed-gtf-file", dest="compressed_gtf_file", help="Path to the compressed GTF file.")
    parser.add_argument("--output-file", dest="output_file", help="Path to the output file.")
    parser.add_argument("--min-frag-cutoff", dest="min_frag_cutoff", type=int, help="Minimum fragment cutoff.")

    args = parser.parse_args()

    no_singleton_bed_file = args.fragment_file
    genes_gtf_file = args.compressed_gtf_file
    output_file = args.output_file
    min_frag_cutoff = args.min_frag_cutoff
    
    # Print SnapATAC version
    print("SnapATAC version:", snap.__version__)

    # Check if the fragment file exists
    if not os.path.isfile(no_singleton_bed_file):
        print(f"Error: Fragment file '{no_singleton_bed_file}' not found.")
        sys.exit(1)

    # Check if the compressed GTF file exists
    if not os.path.isfile(genes_gtf_file):
        print(f"Error: Compressed GTF file '{genes_gtf_file}' not found.")
        sys.exit(1)

    print(f"no_singleton_bed_file: {no_singleton_bed_file}")
    print(f"genes_gtf_file: {genes_gtf_file}")
    print(f"output_file: {output_file}")
    print(f"min_frag_cutoff: {min_frag_cutoff}")


    hg38_genome = snap.genome.hg38
    
    print("Loading data from fragment file...")
    adata = snap.pp.import_data(fragment_file=Path(no_singleton_bed_file), chrom_sizes=hg38_genome, min_num_fragments=min_frag_cutoff, sorted_by_barcode=False)


    # Calculate and plot TSSE
    print("Calculating TSSE...")
    snap.metrics.tsse(adata, gene_anno=genes_gtf_file, inplace=True)
#     WDL
# snap.metrics.tsse(data, compressed_gtf_file)

    # Save the plot to a file (optional)
    #snap.pl.tsse(adata)
    #snap.pl.save("tsse.png")

    # Save your results to the output file
    adata.obs.to_csv(output_file, index_label="barcode", sep="\t")
    print("Results saved to", output_file)
# WDL:
# data.obs.to_csv(output_file, index_label="barcode", sep="\t")

if __name__ == "__main__":
    main()
