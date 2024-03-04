import h5py
import numpy as np
import argparse
import shutil
import os

def append_suffix_to_h5ad(input_h5ad_file, suffix, output_h5ad_file):
    # Copy the input H5 file to create the output H5 file
    shutil.copy(input_h5ad_file, output_h5ad_file)

    # If the suffix is not "_none", perform the appending to the H5 file
    if suffix.decode("utf-8") != "_none":
        # Open the output H5 file for modification
        with h5py.File(output_h5ad_file, "r+") as h5file:
            # Access the dataset containing the list of byte strings
            dataset = h5file["/obs/barcode"]

            # Convert the dataset to regular Python strings, append the suffix, and convert back to bytes
            dataset[:] = np.array([item.decode('utf-8') + suffix.decode("utf-8") for item in dataset], dtype='S')

            # Save the modified dataset
            h5file.flush()

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Append a suffix to a dataset in an h5ad file and create a new file.")
    parser.add_argument("input_h5ad_file", help="Path to the input h5ad file")
    parser.add_argument("suffix", help="Suffix to append")
    parser.add_argument("output_h5ad_file", help="Path to the output h5ad file")

    args = parser.parse_args()

    input_h5ad_file = args.input_h5ad_file
    suffix = ("_" + args.suffix).encode("utf-8")
    output_h5ad_file = args.output_h5ad_file

    append_suffix_to_h5ad(input_h5ad_file, suffix, output_h5ad_file)
