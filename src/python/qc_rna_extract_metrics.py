#!/usr/bin/env python3

"""
This script takes in a anndata file, and outputs a txt file containing the number of
total reads and genes for each barcode.
"""

import anndata
import argparse
import scanpy as sc


def extract_qc_metrics(adata, layer = ""):
    if(layer == ""):
        df = sc.pp.calculate_qc_metrics(adata)
    else:
        df = sc.pp.calculate_qc_metrics(adata, layer = layer)
    return df


def write_qc_metrics(df, barcode_metadata_file):
    df.to_csv(barcode_metadata_file, sep="\t")


def main():
    # get arguments
    parser = argparse.ArgumentParser(description="Retrieve total reads and genes with atleast 1 count in each cell")
    parser.add_argument("anndata", help="Filename for input a5ad file")
    parser.add_argument("barcode_metadata_file", help="Filename for output barcode metadata txt file")
    parser.add_argument("kb_workflow", help="KB workflow (standard or nac)")
    parser.add_argument("subpool", help="Subpool ID to be appended to barcode", nargs="?")

    args = parser.parse_args()
    adata = getattr(args, "anndata")
    subpool = getattr(args, "subpool", "none")
    kb_workflow = getattr(args, "kb_workflow", "standard")
    barcode_metadata_file = getattr(args, "barcode_metadata_file")

    adata = anndata.read_h5ad(adata)
    
    #  use scanpy libraries to extract multiple qc metrics
    if(kb_workflow == "standard"):
        df = extract_qc_metrics(adata)
       
        #  extract metrics of interest
        df = df[0][["total_counts", "n_genes_by_counts"]]
    else:
        df_m = extract_qc_metrics(adata, 'mature')
        df_a = extract_qc_metrics(adata, 'ambiguous')
        df = df_m[0][["total_counts", "n_genes_by_counts"]] + df_a[0][["total_counts", "n_genes_by_counts"]]
    
    #  rename columns
    df.rename(columns={"total_counts": "total_counts", "n_genes_by_counts": "genes"}, inplace=True)

    #  suffix index with PKR
    if subpool != "none":
        df.set_index(df.index.astype(str) + "_" + subpool, inplace=True)

    write_qc_metrics(df, barcode_metadata_file)


if __name__ == "__main__":
    main()
