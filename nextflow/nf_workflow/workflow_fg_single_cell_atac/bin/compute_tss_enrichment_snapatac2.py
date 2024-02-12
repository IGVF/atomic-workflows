import argparse
import snapatac2 as snap
from pathlib import Path
import os

def main():
    parser = argparse.ArgumentParser(description="Description of your script.")
    parser.add_argument("fragment_file", help="Path to the fragment file.")
    parser.add_argument("compressed_gtf_file", help="Path to the compressed GTF file.")
    parser.add_argument("output_file", help="Path to the output file.")
    parser.add_argument("min_frag_cutoff", type=int, help="Minimum fragment cutoff.")

    args = parser.parse_args()

    no_singleton_bed_file = args.fragment_file
    genes_gtf_file = args.compressed_gtf_file
    output_file = args.output_file
    min_frag_cutoff = args.min_frag_cutoff

    # Check if the fragment file exists
    if not os.path.isfile(no_singleton_bed_file):
        print(f"Error: Fragment file '{no_singleton_bed_file}' not found.")
        sys.exit(1)

    # Check if the compressed GTF file exists
    if not os.path.isfile(compressed_gtf_file):
        print(f"Error: Compressed GTF file '{compressed_gtf_file}' not found.")
        sys.exit(1)
        
    # Create the folder if it doesn't exist
    tempdir="/tss/tss_tmp"
    os.makedirs(tempdir, exist_ok=True)
    
    hg38_genome = snap.genome.hg38
    
    # TODO: genome=hg38_genome and not chrom_sizes=hg38_genome
    print("Loading data from fragment file...")
    adata = snap.pp.import_data(no_singleton_bed_file=Path(no_singleton_bed_file),file=Path(genes_gtf_file),genome=hg38_genome,tempdir=Path(tempdir),min_num_fragments=min_frag_cutoff,sorted_by_barcode=False,)
    
    # data = snap.pp.import_data(
    #     no_singleton_bed_file,
    #     chrom_sizes=snap.genome.hg38,
    #     sorted_by_barcode=False,
    #     min_num_fragments=min_frag_cutoff
    # )
    print("Data loaded successfully.")

    print("Running tsse with compressed GTF file...")
    snap.metrics.tsse(data, compressed_gtf_file)
    print("tsse completed.")

    print("Saving results to output file...")
    data.obs.to_csv(output_file, index_label="barcode", sep="\t")
    print("Results saved to", output_file)

if __name__ == "__main__":
    main()
