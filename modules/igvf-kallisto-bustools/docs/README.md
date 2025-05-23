# Processed Single-Cell Gene Expression Data (kallisto-bustools)

This archive contains processed single-cell gene expression data generated using **kallisto-bustools**.

## File Descriptions

All output files are located in the `counts_unfiltered` directory unless otherwise noted.

### Count Matrices

| File                              | Description                                                                                                                                                                                                                 |
|------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `cells_x_genes.mature.mtx`        | Matrix of RNA counts from exonic reads spanning splice junctions (spliced/mature transcripts). Corresponds to the `"mature"` layer in the AnnData `.h5ad` file.                        |
| `cells_x_genes.ambiguous.mtx`     | Matrix of RNA counts from ambiguous exonic reads (not spanning junctions). Included in the `"ambiguous"` layer of the AnnData file.                                                    |
| `cells_x_genes.cell.mtx`          | Sum of mature and ambiguous counts (all exonic reads).                                                                                                                                |
| `cells_x_genes.nascent.mtx`       | Matrix of RNA counts from intronic reads (unspliced/nascent transcripts). Included in the `"nascent"` layer of the AnnData file.                                                       |
| `cells_x_genes.nucleus.mtx`       | Combination of nascent and ambiguous counts (intronic + ambiguous exonic reads).                                                                                                      |
| `cells_x_genes.total.mtx`         | Matrix containing all reads: mature, nascent, and ambiguous. This is the default matrix in the `.X` attribute of the AnnData object.                                                  |

### Annotation Files

| File                              | Description                                                                                                                                                                                                                 |
|------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `cells_x_genes.barcodes.txt`      | List of cell barcodes (one per line), including sample-specific suffixes. Used as the observation index in AnnData and as row indices in all matrices.                                 |
| `cells_x_genes.genes.txt`         | List of unique ENSEMBL gene IDs (one per line). Used as the variable index in AnnData and as column indices in all matrices.                                                          |
| `cells_x_genes.genes.names.txt`   | List of human-readable gene names corresponding to the ENSEMBL IDs in `genes.txt`. Names are not guaranteed to be unique.                                                             |

### Additional Output Files

| File                              | Description                                                                                                                                                                                                                 |
|------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `inspect.json`                    | Summary statistics: total reads, barcodes, UMIs, mean/median reads and UMIs per barcode, and percentages matching known barcode lists (if provided).                                   |
| `kb_info.json`                    | Metadata for the `kb count` run: software versions, runtime, and command used.                                                                                                       |
| `run_info.json`                   | Summary of kallisto pseudoalignment: processed reads, mapping percentages, reference targets, k-mer length, and kallisto version.                                                     |
| `transcripts.txt`                 | List of transcripts present in the data, in the same order as the transcriptome FASTA file.                                                                                          |
| `matrix.ec`                       | Two-column file: (1) equivalence class index (0-based), (2) set of transcript indices (0-based, matching order in `transcripts.txt`) in each equivalence class.                      |
| `output.bus`                      | Initial BUS file after pseudoalignment: uncorrected, unsorted barcode-UMI-equivalence class records.                                                                                  |
| `output.unfiltered.bus`           | Processed and sorted BUS file for counting: corrected barcodes, no UMI filtering.                                                                                                     |
| `output_modified.unfiltered.bus`  | BUS file with barcodes modified using a replacement list (e.g., for merging oligo-dT and random hexamer barcodes in Parse Biosciences data). Present only if barcode collapsing was performed. |

### Barcode Collapsing (Parse Biosciences)

Some platforms (e.g., Parse Biosciences) assign two barcodes per cell (oligo-dT and random hexamer). These are typically collapsed into a single barcode during quantification using a replacement list, retaining the oligo-dT barcode.

- Collapsed output is saved in `counts_unfiltered_modified/` (same file structure as above), used to generate the primary AnnData `.h5ad` file.
- The original, uncollapsed output is preserved in `counts_unfiltered/adata.h5ad` for reproducibility and transparency.

---

## References

- Kallisto files:  
    [PMC10690192](https://pmc.ncbi.nlm.nih.gov/articles/PMC10690192/),  
    [kb_species_mixing tutorial](https://pachterlab.github.io/kallistobustools/tutorials/kb_species_mixing/R/kb_mixed_species_10x_v2/)
- Parse Bio barcoding:  
    [Parse Biosciences blog](https://www.parsebiosciences.com/blog/getting-started-with-scrna-seq-post-sequencing-data-analysis/),  
    [Genome Biology article](https://genomebiology.biomedcentral.com/articles/10.1186/s13059-021-02505-w)