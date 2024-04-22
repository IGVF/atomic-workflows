#!/usr/bin/env python3

"""
This script takes in a mtx file, barcode.txt and genes.txt and outputs a h5ad.
"""

import anndata
import argparse
import scanpy as sc

def main():
    # get arguments
    parser = argparse.ArgumentParser(description="This script takes in a mtx file, barcode.txt and genes.txt and outputs a h5ad.")
    parser.add_argument("mtx", help="Filename for input mtx file")
    parser.add_argument("barcode", help="Filename for input barcode file")
    parser.add_argument("genes", help="Filename for input genes file")
    
    args = parser.parse_args()
    mtx = getattr(args, "mtx")
    barcodes = getattr(args, "barcodes")
    genes = getattr(args, "genes")
    
    adata = sc.read_mtx(mtx)
    
    bc_file = open(barcodes, "r")
    bc=bc_file.read().splitlines()
    
    gene_file = open(genes, "r")
    g=gene_file.read().splitlines()
    
    adata.obs_names = bc
    adata.var_names = g[0]
    
    adata.write_h5ad("output.h5ad")
