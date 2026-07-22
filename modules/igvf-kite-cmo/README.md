# `igvf-kite-cmo`

## Overview
`run_kite.py` is a script that quantifies Cell Multiplexing Oligo (CMO) tags per cell barcode using the [kb-python](https://github.com/pachterlab/kb_python) KITE workflow. It is designed for 10x Genomics multiome experiments where CMO reads have been separated from GEX reads (e.g. via splitcode). This script is used by the IGVF single-cell pipeline.

## Installation
1. Clone the repository:
    ```sh
    git clone https://github.com/IGVF/atomic-workflows
    cd atomic-workflows/modules/igvf-kite-cmo
    ```
2. Install the required Python packages:
    ```sh
    pip install .
    ```
Alternative method 1 - Build the docker:
    ```sh
    docker build -t igvf-kite-cmo:latest -f docker_builder.dockerfile .
    ```
Alternative method 2 - Run the official docker:
    ```sh
    docker run -it --rm -v ${PWD}:/data igvf/kite-cmo:main bash
    ```

## Usage
The `igvf-kite-cmo` tool provides a CLI with three subcommands: barcode preparation, index creation, and quantification.

---

## Barcode Preparation

Converts a CMO barcode CSV (from IGVF or a local file) into the gzipped two-column TSV format required by the KITE index command.

### Arguments
- `--accession`: IGVF file accession (e.g. `IGVFFI9308MNHO`). Downloads the CSV.gz from the IGVF portal using `IGVF_API_KEY` and `IGVF_SECRET_KEY` from a `.env` file.
- `--input`: Local CSV or CSV.gz file (mutually exclusive with `--accession`).
- `--sequence-col`: Column name for barcode sequences (default: `multiseq_bc`, matching IGVF `IGVFFI9308MNHO`).
- `--name-col`: Column name for barcode labels (default: `CMO ID`, matching IGVF `IGVFFI9308MNHO`).
- `--output`: Output path for the gzipped TSV (`sequence\tname`, no header).

### Command
```sh
# From IGVF portal
run_kite prepare-barcodes \
    --accession IGVFFI9308MNHO \
    --output cmo_barcodes_for_kite.tsv.gz

# From local file with custom column names
run_kite prepare-barcodes \
    --input cmo_barcodes.csv.gz \
    --sequence-col barcode_seq \
    --name-col cmo_id \
    --output cmo_barcodes_for_kite.tsv.gz
```

IGVF authentication requires a `.env` file in the working directory (or any parent) with:
```
IGVF_API_KEY=<your_key>
IGVF_SECRET_KEY=<your_secret>
```

### Output
- `cmo_barcodes_for_kite.tsv.gz`: Gzipped TSV with columns (sequence, name), no header. Pass directly to `run_kite index --cmo_barcodes`.

---

## Index Creation

### Arguments
- `--output_dir`: Directory where the index files will be saved.
- `--cmo_barcodes`: CMO barcode TSV file (two columns: sequence, name; no header).
- `--temp_dir`: Path to a temporary directory (optional).

### Command
```sh
run_kite index \
    --output_dir <output_dir> \
    --cmo_barcodes <cmo_barcodes.tsv> \
    --temp_dir <temp_dir>
```

`kb ref` is called with the following parameters:
```sh
kb ref \
    --tmp <temp_dir> \
    --workflow kite \
    -i <output_dir>/cmo.idx \
    -g <output_dir>/cmo_t2g.txt \
    -f1 <output_dir>/cmo_cdna.fa \
    <cmo_barcodes.tsv>
```

### Outputs
A compressed file `<output_dir>.tar.gz` containing:
```
<output_dir>/
├── cmo.idx
├── cmo_t2g.txt
└── cmo_cdna.fa
```

---

## Quantification

### Arguments
- `--index_dir`: Directory containing the KITE index files (`cmo.idx`, `cmo_t2g.txt`).
- `--output_dir`: Directory where kb count output files will be saved.
- `--barcode_onlist`: Cell barcode whitelist (`.tsv` or `.tsv.gz`).
- `--read_format`: kb technology string specifying CB, UMI, and cDNA positions (default: `0,0,16:0,16,28:1,0,15`).
- `--threads`: Number of threads (default: 8).
- `--memory`: Memory limit for bustools sort (default: `4G`).
- `--temp_dir`: Path to a temporary directory (optional).
- `fastqs`: Two positional arguments — R1 (trimmed to 28 bp) then R2.

### Command
```sh
run_kite quantify \
    --index_dir <index_dir> \
    --output_dir <output_dir> \
    --barcode_onlist <onlist.tsv> \
    --read_format 0,0,16:0,16,28:1,0,15 \
    --threads 8 \
    --memory 4G \
    <channel_CMO_R1.trimmed.fastq.gz> <channel_CMO_R2.fastq.gz>
```

`kb count` is called with the following parameters:
```sh
kb count \
    --workflow kite \
    --tmp <temp_dir> \
    -i <index_dir>/cmo.idx \
    -g <index_dir>/cmo_t2g.txt \
    -x <read_format> \
    -w <onlist.tsv> \
    --h5ad \
    -t <threads> \
    -m <memory> \
    -o <output_dir> \
    <R1.fastq.gz> <R2.fastq.gz>
```

### Outputs
- `{output_dir}/counts_unfiltered/adata.h5ad`: Unfiltered CMO counts in h5ad format.
- `{output_dir}.tar.gz`: Tarball of the full output directory.

For a full description of all output files see [docs/README.md](docs/README.md).

---

## Read format
The default technology string `0,0,16:0,16,28:1,0,15` encodes:
- Cell barcode: file 0, bases 0–15 (16 bp)
- UMI: file 0, bases 16–27 (12 bp)
- cDNA: file 1, bases 0–14 (15 bp)

This matches the 10x Genomics 3' v3 / multiome cell barcode + UMI layout after trimming the CMO R1 to the last 28 bp.

---

## Logging
The tool uses Python's `logging` module. All messages are output to stderr at INFO level.

## License
This project is licensed under the MIT License. See the LICENSE file for details.
