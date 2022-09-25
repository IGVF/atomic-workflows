# 10x-RNA-v2

## Inputs

The 10x-RNA-v2 assay generates a library of DNA that is subsequently sequenced. The result is a set of sequencing reads that conform to the [specification](spec.md).

**Note**: sequencing platforms may have differing processing steps prior to FASTQ generation. Please see [sequencing](../sequencing) for more information.

1. FASTQ Files
   a. R1.fastq.gz (contains the cell barcode and UMI)
   b. R2.fastq.gz (contains the cDNA)

## Preprocessing tools

1. [`gget`](https://github.com/pachterlab/gget): fetch ensembl references

```bash
pip install gget==0.3.11
```

2. [`kb-python`](https://github.com/pachterlab/kb_python): pseudoalign and quantify sequencing reads

```bash
pip install kb-python==0.27.3
```

## Preprocessing steps

1. Obtain links to genomic references with `gget ref`

```bash
gget ref -r 104 -w dna,gtf human
```

- `-r 104` indicates the specific ensembl release
- `-w dna,gtf` indcates the specific refernce files obtains (genome DNA FASTA and genome annotation GTF)

2. Build kallisto pseudoalignment index with `kb ref`

```bash
kb ref \
	-i index.idx \
	-g t2g.txt \
	-f1 transcriptome.fa \
	http://ftp.ensembl.org/pub/release-104/fasta/homo_sapiens/dna/Homo_sapiens.GRCh38.dna.primary_assembly.fa.gz \
	http://ftp.ensembl.org/pub/release-104/gtf/homo_sapiens/Homo_sapiens.GRCh38.104.gtf.gz
```

- `-i` indicates the filename of the pseudoalignment index to be created
- `-g` indicates the filename of the transcripts to genes map to be created
- `-f1` indicates the filename of the transcriptome FASTQ to be created
- The genome FASTA and annotation GTF are the final two positional arguments

4. Pseudoalign reads with `kb count`

```bash
kb count \
	-i index.idx \
	-g t2g.txt \
	-x 10xv2 \
	-o out \
	--filter \
	--h5ad \
	R1.fastq.gz R2.fastq.gz
```

- `-i` indicates the filename of the pseudoalignment index that was created
- `-g` indicates the filename of the transcripts to genes map that was created
- `-x` indicates the technology of the assay that generated the FASTQ files
- `-o` indicates the folder where the output files will be created
- `--filter` indicates that knee-plot filtering will be performed
- `--h5ad` indicates that the count matrix will be saved as an `h5ad` object
- The FASTQ files are the final positional arguments

## Outputs

The `out` folder contains all of the files created.

```bash
$ tree out/
out/
├── 10x_version2_whitelist.txt
├── counts_filtered
│   ├── adata.h5ad
│   ├── cells_x_genes.barcodes.txt
│   ├── cells_x_genes.genes.txt
│   └── cells_x_genes.mtx
├── counts_unfiltered
│   ├── adata.h5ad
│   ├── cells_x_genes.barcodes.txt
│   ├── cells_x_genes.genes.txt
│   └── cells_x_genes.mtx
├── filter_barcodes.txt
├── inspect.json
├── kb_info.json
├── matrix.ec
├── output.bus
├── output.filtered.bus
├── output.unfiltered.bus
├── run_info.json
└── transcripts.txt
```

### File description

1. `cells_x_genes.barcodes.txt`: list of barcodes (size n)
2. `cells_x_genes.genes.txt`: list of gene names (size m)
3. `cells_x_genes.mtx`: a barcode by genes matrix (size n x m)
4. `adata.h5ad`: an anndata object containing the barcodes, genes, and count matrix
5. `filter_barcodes.txt`: barcodes that passed filter
6. `matrix.ec`: transcript ambiguity mapping
7. `transcripts.txt`: list of transcripts used for pseudoalignment
8. `output.bus`: raw BUS file
9. `output.filtered.bus`: filtered BUS file
10. `output.unfiltered.bus`: unfiltered BUS file
11. `10x_version2_whitelist.txt`: 10xv2 barcode whitelist
12. `kb_info.json`: metadata for the whole pre-processing workflow
13. `inspect.json`: metadata for the BUS file
14. `run_info.json`: metadata for pseudoalignment

## Metrics

Matrix-level metrics

```json
{
  "ncells": 10985,
  "ngenes": 60623,
  "nvals": 4699669,
  "density": 0.0070571571103864635,
  "avg_per_cell": 1172.6380518889396,
  "avg_per_gene": 212.48418916912723,
  "min_cell": 188,
  "max_cell": 28784,
  "total_counts": 12881429,
  "overdispersion": 2.5246422470313186
}
```

## FAQs
