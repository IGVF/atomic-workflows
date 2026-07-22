# Output files

## Quantification outputs

### Count matrix
- `{output_dir}/counts_unfiltered/adata.h5ad`: Unfiltered cell-by-CMO count matrix in h5ad format.
- `{output_dir}/counts_unfiltered/cells_x_features.barcodes.txt`: Cell barcodes (one per line).
- `{output_dir}/counts_unfiltered/cells_x_features.genes.txt`: CMO tag IDs (one per line).
- `{output_dir}/counts_unfiltered/cells_x_features.genes.names.txt`: CMO tag names (one per line).
- `{output_dir}/counts_unfiltered/cells_x_features.mtx`: Count matrix in MatrixMarket format.

### BUS files
- `{output_dir}/output.bus`: Raw BUS file from kallisto.
- `{output_dir}/output.unfiltered.bus`: Barcode-corrected and sorted BUS file.

### Annotation files
- `{output_dir}/matrix.ec`: Equivalence class file.
- `{output_dir}/transcripts.txt`: Transcript list.

### Metrics
- `{output_dir}/inspect.json`: Library QC metrics from bustools inspect.
- `{output_dir}/kb_info.json`: kb run metadata including the command, timing, and tool versions.
- `{output_dir}/run_info.json`: kallisto run metadata.

## Index outputs

- `{output_dir}/cmo.idx`: kallisto index built from CMO barcode pseudo-sequences.
- `{output_dir}/cmo_t2g.txt`: Transcript-to-gene mapping (CMO barcode ID to CMO name).
- `{output_dir}/cmo_cdna.fa`: FASTA file of CMO barcode pseudo-sequences.

## Format of `inspect.json`

```json
{
  "numRecords": ...,
  "numReads": ...,
  "numBarcodes": ...,
  "medianReadsPerBarcode": ...,
  "meanReadsPerBarcode": ...,
  "numUMIs": ...,
  "numBarcodeUMIs": ...,
  "medianUMIsPerBarcode": ...,
  "meanUMIsPerBarcode": ...,
  "numBarcodesOnOnlist": ...,
  "percentageBarcodesOnOnlist": ...,
  "numReadsOnOnlist": ...,
  "percentageReadsOnOnlist": ...
}
```
