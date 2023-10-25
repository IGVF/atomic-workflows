#append subpool suffix to every barcode in .h5ad

import h5py
import numpy as np
import argparse

def append_suffix_to_h5ad(h5ad_file, suffix):
    # Open the h5ad file for modification
    with h5py.File(h5ad_file, "r+") as h5file:
        # Access the dataset containing the list of byte strings
        dataset = h5file["/obs/barcode"]

        # Convert the dataset to regular Python strings, append the suffix, and convert back to bytes
        dataset[:] = np.array([item.decode('utf-8') + suffix.decode("utf-8") for item in dataset], dtype='S')

        # Save the modified dataset
        h5file.flush()

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Append a suffix to a dataset in an h5ad file.")
    parser.add_argument("h5ad_file", help="Path to the h5ad file")
    parser.add_argument("suffix", help="Suffix to append")

    args = parser.parse_args()

    h5ad_file = args.h5ad_file
    suffix = ("_" + args.suffix).encode("utf-8")

    append_suffix_to_h5ad(h5ad_file, suffix)