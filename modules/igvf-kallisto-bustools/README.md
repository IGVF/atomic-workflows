# `igvf-kallisto-bustools`

## Overview
`run_kallisto.py` is a script designed to run the Kallisto and Bustools pipeline for processing single-cell RNA-seq data. This script is used by the IGVF-single-cell-pipeline.

## Installation
1. Clone the repository:
    ```sh
    git clone https://github.com/IGVF/atomic-workflows
    cd atomic-workflows/modules/igvf-kallisto-bustool
    ```
2. Install the required Python packages:
    ```sh
    pip install .
    ```
Alternative method 1 - Build the docker:
    ```sh
    docker build -t igvf-kb:latest -f docker_builder.dockerfile .
    ```
Alternative method 2 - Run the official docker:
    ```sh
    docker run -it --rm -v ${PWD}:/data igvf/kallisto-bustools:main bash
    ```
## Usage
The igvf-kallisto-bustools tool provides a command-line interface (CLI) with several subcommands for managing the index creation and quantification steps.

## Index Creation

### Arguments
- `--output_directory`: Directory where the output files will be saved.
- `--genome_fasta`: Path to the genome FASTA file.
- `--gtf`: Path to the GTF file.
- `--temp_dir`: Path to the temporary directory (Optional)

### Command
To create a standard Kallisto index, use the following command:

```sh
run_kallisto index nac \
    --temp_dir <kb_temp_folder> \
    --genome_fasta <genome_fasta> \
    --gtf <gene_gtf> \
    --output_dir <output_folder>
```

`kallisto-bustool` is called withing the python scsript using the following parameters:
```sh
kb ref \
    --tmp <kb_temp_folder>
    --workflow=nac 
    -i <output_folder>/index.idx \
    -g <output_folder>/t2g.txt \
    -c1 <output_folder>/cdna.txt \
    -c2 <output_folder>/nascent.txt \
    -f1 <output_folder>/cdna.fasta \
    -f2 <output_folder>/nascent.fasta \
    <genome_fasta> \
    <gene_gtf>
```

### Outputs
A compressed file called `<output_dir>.tar.gz` in `tar.gz` format containing the transcriptome index. The structure of the `tar` file is:

```
<output_dir>/
└── index.idx
└── t2g.txt
└── cdna.txt
└── nascent.txt
```
Additionally, two FASTA files containing the sequences for the nascent and mature transcript are generated: `cdna.fasta` and `nascent.fasta` respectively.


## Quantification

### Arguments
- `--temp_dir`: Path to the temp directory (Optional).
- `--index_dir`: Path to the Kallisto index directory.
- `--read_format`: Format of the input reads.
- `--output_dir`: Directory where the output files will be saved.
- `--strand`: Library strand orientation.
- `--subpool`: Subpool ID string to append to the barcode (Optional).
- `--threads`: Number of threads to use (default: 1).
- `--barcode_onlist`: Path to the barcode onlist file.
- `--replacement_list`: Path to the replacement list file. (Optional).
- `interleaved_fastqs`: Path to the input FASTQ file(s).


### Command
To run the nac quantification pipeline, use the following command:
```sh
run_kallisto quantify nac \
    --temp_dir <temp_dir> \
    --index_dir <index_dir> \
    --read_format <read_format> \
    --output_dir <output_dir> \
    --strand <strand> \
    --subpool <subpool> \
    --threads <threads> \
    --barcode_onlist <barcode_onlist> \
    --replacement_list <replacement_list> \
    <interleaved_fastqs>

```

`kallisto-bustool` is called withing the python scsript using the following parameters:
```sh
kb count \
--workflow=nac \
--tmp <temp_dir> \
-i <index_dir>/index.idx \
-g <index_dir>/t2g.txt \
-c1 <index_dir>/cdna.txt \
-c2 <index_dir>/nascent.txt \
--sum=total -x <read_format> \
-w <barcode_onlist> \
--strand <strand> \
-o <output_dir> \
--h5ad \
-t <threads> \
<interleaved_fastqs>
```

### Outputs

The quantification step generates the following output files:

- `{output_dir}/counts_unfiltered/adata.h5ad`: The unfiltered counts in `h5ad` format.
- `{output_dir}.tar.gz`: A compressed tarball of the output directory with all the output files.
- `{output_dir}/inspect.json`: File in JSON format containing library specific metrics.

## Format of the `inspect.json` file.
The `inspect.json` file contains alignment statistics in JSON format.
The JSON will containt the following records:
- `numRecords`:
- `numReads`:
- `numBarcodes`:
- `medianReadsPerBarcode`:
- `meanReadsPerBarcode`:
- `numUMIs`:
- `numBarcodeUMIs`:
- `medianUMIsPerBarcode`:
- `meanUMIsPerBarcode`:
- `gtRecords`:
- `numBarcodesOnOnlist`:
- `percentageBarcodesOnOnlist`:
- `numReadsOnOnlist`:
- `percentageReadsOnOnlist`:

## Logging
The tool uses Python's logging module to log information and errors. Logs are output to stderr.


## License
This project is licensed under the MIT License. See the LICENSE file for details.