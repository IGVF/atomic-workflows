# calculate_qc_metrics.py
#!/usr/bin/env python3
import sys
import anndata
import scanpy as sc
print(f"calculate_qc_metrics: Python Version: {sys.version}")
print("calculate_qc_metrics: sys.argv are",sys.argv)


# adata = anndata.read_h5ad(adata)
# df = sc.pp.calculate_qc_metrics(adata)
#  extract metrics of interest
# df = df[0][["total_counts", "n_genes_by_counts"]]
    
#  rename columns
# df.rename(columns={"total_counts": "total_counts", "n_genes_by_counts": "genes"}, inplace=True)

#  suffix index with PKR
# if subpool != "none":
  # df.set_index(df.index.astype(str) + "_" + subpool, inplace=True)
        
# df.to_csv(barcode_metadata_file, sep="\t")




