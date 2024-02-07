import argparse
import snapatac2 as snap
import os

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

    # Check if the fragment file exists
    if not os.path.isfile(fragment_file):
        print(f"Error: Fragment file '{fragment_file}' not found.")
        sys.exit(1)

    # Check if the compressed GTF file exists
    if not os.path.isfile(compressed_gtf_file):
        print(f"Error: Compressed GTF file '{compressed_gtf_file}' not found.")
        sys.exit(1)

    print("Loading data from fragment file...")
    data = snap.pp.import_data(
        fragment_file,
        chrom_sizes=compressed_gtf_file,
        sorted_by_barcode=False,
        min_num_fragments=min_frag_cutoff
    )
    print("Data loaded successfully.")

    print("Running tsse with compressed GTF file...")
    snap.metrics.tsse(data, compressed_gtf_file)
    print("tsse completed.")

    print("Saving results to output file...")
    data.obs.to_csv(output_file, index_label="barcode", sep="\t")
    print("Results saved to", output_file)

if __name__ == "__main__":
    main()
