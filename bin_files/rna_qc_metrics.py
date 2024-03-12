#!/usr/bin/env python

import argparse
import anndata
import scanpy as sc
import sys
import traceback

def sc_rna_qc_calculate(adata, subpool, output_file):
    # Your QC calculation logic here
    
    try:
        print("sc_rna_qc_calculate start")
        df = sc.pp.calculate_qc_metrics(adata)
        df = df[0][["total_counts", "n_genes_by_counts"]]
        
        print("rename the columns")
        df.rename(columns={"total_counts": "total_counts", "n_genes_by_counts": "genes"}, inplace=True)
        
        if subpool != "no_subpool":
            df.set_index(df.index.astype(str) + "_" + subpool, inplace=True)
        
        result_file_path = output_file
        df.to_csv(result_file_path, sep="\t")
        print(f"sc_rna_qc_calculate end. Result saved to {result_file_path}")
        
        # Return the file path
        return result_file_path
    
    except Exception as e:
        print(f"Error in sc_rna_qc_calculate: {e}")
        traceback.print_exc()
        sys.exit(1)

def main():
    # Parse command line arguments
    parser = argparse.ArgumentParser(description='scRNA-seq QC Calculation')
    parser.add_argument('--adata', type=str, help='Path to the adata file')
    parser.add_argument('--subpool', type=str, default='no_subpool', help='Subpool identifier')
    parser.add_argument('--output', type=str, default='rna_qc_calculate.tsv', help='Output file path')
    args = parser.parse_args()

    try:
        # Load the H5AD-formatted Anndata object directly from the provided path
        adata = anndata.read_h5ad(args.adata)

        print(f"Loaded adata from {args.adata}")

        # Call the sc_rna_qc_calculate method with the Anndata object, subpool, and output file arguments
        result_file = sc_rna_qc_calculate(adata, args.subpool, args.output)

        # Print the result file path to standard output
        print(f"Result file path: {result_file}")
    
    except Exception as e:
        print(f"Error in main: {e}")
        traceback.print_exc()
        sys.exit(1)

# Call the main function if the script is executed directly
if __name__ == "__main__":
    main()
