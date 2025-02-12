# `igvf-chromap`

## Overview
`run_chromap.py` is a script designed to run the Chromap pipeline for processing single-cell ATAC-seq data. This script is used by the IGVF-single-cell-pipeline.

## Installation
1. Clone the repository:
    ```sh
    git clone https://github.com/IGVF/atomic-workflows
    cd atomic-workflows/modules/igvf-chromap
    ```
2. Build the docker:
    ```sh
    docker build -t igvf-chromap:dev -f docker_builder.dockerfile .
    ```
3. Alternative method - Run the official docker:
    ```sh
    docker run -it --rm -v ${PWD}:/data docker.io/igvf/chromap:dev bash
    ```

## Usage
The igvf-chromap tool provides a command-line interface (CLI) with subcommands for managing the index creation and alignment steps.

## Index Creation

### Arguments for Index Creation
- `--output_dir`: Directory where the index file will be saved.
- `--genome_fasta`: Patht to the genome FASTA file.

### Command

```sh
run_chromap index --genome_fasta <genome_fasta> --output_dir <output_dir>
```
Chromap is called within the python script using the following parameters:
```sh
chromap -i 
    -r <genome_fasta> 
    -o <output_dir>/index
```


### Outputs
A compressed file called `<output_dir>.tar.gz` in `tar.gz` format containing the genome index. The structure of the `tar` file is:

```
<output_dir>/
└── index
```
## Alignment

### Arguments

### Arguments for Alignment

- `--index_dir`: Path to the Chromap index directory.
- `--read_format`: Format of the input reads.
- `--reference_fasta`: Path to the reference FASTA file.
- `--prefix`: Prefix for the output files (default: "output").
- `--subpool`: Subpool ID string to append to the barcode (optional).
- `--threads`: Number of threads to use (default: 1).
- `--barcode_onlist`: Path to the barcode inclusion list file. **No compression**
- `--barcode_translate`: Path to the barcode translation file for 10x data.
- `--read1`: Path to the FASTQ file containing read 1.
- `--read2`: Path to the FASTQ file containing read 2.
- `--read_barcode`: Path to the FASTQ file containing the barcode (optional).

### Command

To run the alignment step, use the following command:

```sh
run_chromap align --index_dir <index_dir> --read_format <read_format> --reference_fasta <reference_fasta> --prefix <prefix> --subpool <subpool> --threads <threads> --barcode_onlist <barcode_onlist> --barcode_translate <barcode_translate> --read1 <read1> --read2 <read2> --read_barcode <read_barcode>
```

Chromap is called within the python script using the following parameters:
```sh
chromap -x <index_dir>/index 
    --read-format <read_format> 
    -r <reference_fasta> 
    --remove-pcr-duplicates 
    --remove-pcr-duplicates-at-cell-level 
    --trim-adapters 
    --low-mem 
    --BED 
    -l 2000 
    --bc-error-threshold 1 
    -t <threads> 
    --bc-probability-threshold 0.90 
    -q 30 
    --barcode-whitelist <barcode_onlist>
    --barcode-translate <barcode_translate>
    -o <prefix>.fragments.tsv 
    --summary <prefix>.barcode.summary.csv 
    -1 <read1> 
    -2 <read2> 
    -b <read_barcode> > <prefix>.log.txt 2>&1
```


### Outputs

The alignment step generates the following output files:

- `<prefix>.log`: The log file containing information about the alignment process.
- `<prefix>_fragments.tsv.gz`: The fragments file in TSV format, compressed with bgzip.
- `<prefix>_fragments.tsv.gz.tbi`: The index file for the fragments file. Generated using tabix.
- `<prefix>.log.txt`: A summary file containing statistics about the alignment.
- `<prefix>.barcode.summary.csv`: A summary file containing statistics about the alignment.

## Format of `fragments.tsv.gz`

The `fragments.tsv` file contains information about the fragments generated during the alignment process. This is the raw file returned in output by `chromap` and it hasn't been filtered. Each line in the file corresponds to a single fragment and includes the following `tab-separated` columns:

1. **Chromosome**: The chromosome where the fragment is located.
2. **Start**: The starting position of the fragment on the chromosome (0-based). **No Tn5 shifting performed!**
3. **End**: The end position is exclusive, so represents the position immediately following the fragment interval. **No Tn5 shifting performed!**
4. **Barcode**: The barcode sequence associated with the fragment.
5. **Read Count**: The number of reads supporting the fragment.

Example:
```
chr1    10000   10100   ATCGTAGC_subpool    2
chr1    10200   10300   GCTAGCTA_subpool    1
```

## Format of `barcode.summary.csv`

The `barcode.summary.csv` file contains information alignments information for each barcode. Each line in the file corresponds to a single barcodes and includes the following `comma-separated` columns:

The CSV file contains the following columns:
- `barcode`: The unique identifier for each barcode.
- `total`: The total number of reads associated with the barcode.
- `duplicate`: The number of duplicate reads.
- `unmapped`: The number of unmapped reads.
- `lowmapq`: The number of reads with low mapping quality.

Example rows:
```
barcode,total,duplicate,unmapped,lowmapq
ATCGTAGC_subpool,7,0,0,1
GCTAGCTA_subpool,5,0,0,2
```
 




## Logging
The tool uses Python's logging module to log information and errors. Logs are output to stderr.


## License
This project is licensed under the MIT License. See the LICENSE file for details.

