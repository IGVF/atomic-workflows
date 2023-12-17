import argparse
import anndata
import scanpy as sc
import sys

def sc_rna_qc_calculate(adata):
    # Your QC calculation logic here
    
    print("sc_rna_qc_calculate start")
    df = sc.pp.calculate_qc_metrics(adata)
    df = df[0][["total_counts", "n_genes_by_counts"]]
    
    print("rename the columns")
    df.rename(columns={"total_counts": "total_counts", "n_genes_by_counts": "genes"}, inplace=True)
    
    # if subpool != "no_subpool":
        # df.set_index(df.index.astype(str) + "_" + subpool, inplace=True)
    
    result_file_path = "sc_rna_qc_calculate.tsv"
    df.to_csv(result_file_path, sep="\t")
    print("sc_rna_qc_calculate end")
    
    # Return the file path
    return result_file_path

def main():
    # Parse command line arguments
    parser = argparse.ArgumentParser(description='scRNA-seq QC Calculation')
    parser.add_argument('--adata', type=str, help='Path to the adata file')
    args = parser.parse_args()

    # Load the H5AD-formatted Anndata object directly from the provided path
    adata = anndata.read_h5ad(args.adata)

    print(f"Loaded adata from {args.adata}")

    # Call the sc_rna_qc_calculate method with the Anndata object
    result_file = sc_rna_qc_calculate(adata)

    # Print the result file path to standard output
    print(result_file)

# Call the main function if the script is executed directly
if __name__ == "__main__":
    main()
