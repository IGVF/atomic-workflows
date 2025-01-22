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

## Usage
The igvf-kallisto-bustools tool provides a command-line interface (CLI) with several subcommands for managing the index creation and quantification steps.

## Index Creation

### Arguments
- `--output_directory`: Directory where the output files will be saved.
- `--genome_fasta`: Patht to the genome FASTA file.
- `--gtf`: Path to the IGVF file.

### Standard Index
To create a standard Kallisto index, use the following command:

```sh
run_kallisto index standard --output_dir <output_dir> --genome-fasta <genome_fasta> --gtf <gtf>
```

### NAC Index
To create a NAC Kallisto index, use the following command:

```sh
run_kallisto index nac --output_dir <output_dir> --genome-fasta <genome_fasta> --gtf <gtf>
```


## Quantification

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
run_kallisto quant standard --index_dir <index_dir> --read_format <read_format> --output_dir <output_dir> --strand <strand> --threads <threads> --barcode_onlist <barcode_onlist> --replacement_list <replacement_list> <interleaved_fastqs> 
```

### NAC Quantification
To run the NAC quantification pipeline, use the following command:

```sh
run_kallisto quant nac --index_dir <index_dir> --read_format <read_format> --replacement_list <replacement_list> --barcode_onlist <barcode_onlist> --strand <strand> --output_dir <output_dir> --threads <threads> <interleaved_fastqs>
```


## Logging
The tool uses Python's logging module to log information and errors. Logs are output to stderr.


## License
This project is licensed under the MIT License. See the LICENSE file for details.

