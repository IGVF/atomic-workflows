# Atomic Workflows

This repository contains standards and pipelines for processing various assay and sequencing-platform data types. If you'd like to modify an existing workflow or contribute a new one please see the [contribution guidelines](CONTRIBUTING.md).

## Single-cell preprocessing

- [10x-RNA-v2](assays/10x-RNA-v2/): 10x Genomics single-ccell RNAseq v2
- [10x-RNA-v3](assays/10x-RNA-v3/): 10x Genomics single-ccell RNAseq v3
- [10x-RNA-ATAC](assays/10x-RNA-ATAC/): 10x Genomics Multiome (single-cell RNA/ATAC)
- [CEL-Seq](assays/CEL-Seq/): barcoding and pooling samples before amplifying RNA with in vitro transcription (v1)
- [CEL-Seq2](assays/CEL-Seq2/): Improvement CEL-Seq, now with UMIs! Implemented on Fluidigm's C1 (v2)
- [Quartz-seq](assays/Quartz-seq/): Riken technology for single-cell RNA-seq
- [Quartz-seq2](assays/Quartz-seq2/): Added umis to Quartz-seq (v2)
- [STRT-seq](assays/STRT-seq/): single-cell tagged reverse transcripton
- [STRT-seq-2i](assays/STRT-seq-2i/): STRT-seq performed on microwells with dual-index 5 prime
- [STRT-seq-C1](assays/STRT-seq-C1/): STRT-seq performed on microfluidics Fluidigm C1
- [Smart-seq2](assays/Smart-seq2/): full-length rna-seq from individual cells
- [Smart-seq3](assays/Smart-seq3/): full-length and five-prime rna-seq from individual cells
- [sci-RNA-seq](assays/sci-RNA-seq/): combinatorial single-cell RNA-seq

Each assay contains:

1. `README.md` with details on
 - Inputs
 - Preprocessing tools
 - Preprocessing steps
 - Outputs
 - Metrics (and their utility)
2. `spec.md` with the assay sequencing library specification (defined with [`seqspec`](https://github.com/IGVF/seqspec))
3. `example.ipynb` a Google Colab notebook executing the atomic workflow

**Todo**: add contributions and citations as well as references (in the README.md) to the the workflow components.

## Sequencing preprocessing

- [Illumina](sequencing/illumina/)
- [Pacific Biosciences](sequencing/pacbio/)
- [Oxford Nanopore](sequencing/nanopore/)

Each sequencing company contains a `README.md` with details on
1. Platforms produced by the company
2. Platform specific concerns
3. Methods for transforming platform specific files to FASTQs
