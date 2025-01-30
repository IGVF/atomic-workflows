# `igvf-chromap`

## Overview
`run_chromap.py` is a script designed to run the Chromap pipeline for processing single-cell ATAC-seq data. This script is used by the IGVF-single-cell-pipeline.

## Installation
1. Clone the repository:
    ```sh
    git clone https://github.com/IGVF/atomic-workflows
    cd atomic-workflows/modules/igvf-chromap
    ```
2. Install the required Python packages:
    ```sh
    pip install .
    ```

## Usage
The igvf-chromap tool provides a command-line interface (CLI) with several subcommands for managing the index creation and alignment steps.

## Index Creation

### Arguments
- `--output_directory`: Directory where the output files will be saved.
- `--genome_fasta`: Patht to the genome FASTA file.
- `--gtf`: Path to the IGVF file.

### command

```sh
run_kallisto index standard --output_dir <output_dir> --genome-fasta <genome_fasta> --gtf <gtf>
```

### Arguments
- `--index dir`: Path to the Kallisto index file.
- `--read_format`: Format of the input reads.
- `--replacement_list`: Path to the replacement list file.
- `--barcode_onlist`: Path to the barcode onlist file.
- `--strand`: Library strand orientation.
- `--output_directory`: Directory where the output files will be saved.
- `--threads`: Number of threads to use.
- `interleaved_fastqs`: Path to the input FASTQ file(s).

### Standard Quantification
To run the standard quantification pipeline, use the following command:
```sh
run_chromap quant standard --index_dir <index_dir> --read_format <read_format> --output_dir <output_dir> --strand <strand> --threads <threads> --barcode_onlist <barcode_onlist> --replacement_list <replacement_list> <interleaved_fastqs> 
```

## Logging
The tool uses Python's logging module to log information and errors. Logs are output to stderr.


## License
This project is licensed under the MIT License. See the LICENSE file for details.

