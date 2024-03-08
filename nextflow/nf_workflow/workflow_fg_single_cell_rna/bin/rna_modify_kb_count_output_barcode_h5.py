#!/usr/bin/env python

import h5py
import numpy as np
import argparse
import shutil
import os

def append_subpool_to_h5ad(input_h5ad_file, subpool, output_h5ad_file):
    # Print input values
    print(f"------ Function append_subpool_to_h5ad ------")
    print(f"Input H5AD file: {input_h5ad_file}")
    print(f"Subpool to append: {subpool}")
    print(f"Output H5AD file: {output_h5ad_file}")

    # Copy the input H5 file to create the output H5 file
    shutil.copy(input_h5ad_file, output_h5ad_file)
    print(f"Copied {input_h5ad_file} to {output_h5ad_file}")

    # If the subpool is not "_none", perform the appending to the H5 file
    if subpool != "_none":
        # Open the output H5 file for modification
        with h5py.File(output_h5ad_file, "r+") as h5file:
            print(f"Opened {output_h5ad_file} for modification")

            # Access the dataset containing the list of byte strings
            dataset = h5file["/obs/barcode"]
            print(f"Accessed dataset /obs/barcode in {output_h5ad_file}")

            # Convert the dataset to regular Python strings, append the subpool, and convert back to bytes
            modified_data = [item + subpool for item in dataset]
            print("Modified data:", modified_data)

            dataset[:] = np.array(modified_data, dtype='S')
            print(f"Updated dataset in {output_h5ad_file}")

            # Save the modified dataset
            h5file.flush()
            print(f"Flushed changes to {output_h5ad_file}")

    print("------ Finished append_subpool_to_h5ad ------")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Append a subpool to a dataset in an h5ad file and create a new file.")
    parser.add_argument("input_h5ad_file", help="Path to the input h5ad file")
    parser.add_argument("subpool", help="Subpool to append")
    parser.add_argument("output_h5ad_file", help="Path to the output h5ad file")

    args = parser.parse_args()

    input_h5ad_file = args.input_h5ad_file
    subpool = "_" + args.subpool
    output_h5ad_file = args.output_h5ad_file

    append_subpool_to_h5ad(input_h5ad_file, subpool, output_h5ad_file)
