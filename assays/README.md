## seqspec examples for different assays

- [10x-RNA-v2](10x-RNA-v2/): 10x Genomics single-cell RNA-seq v2
- [10x-RNA-v3](10x-RNA-v3/): 10x Genomics single-cell RNA-seq v3
- [10x-RNA-ATAC](10x-RNA-ATAC/): 10x Genomics Multiome (single-cell RNA/ATAC)
- [10xCRISPR](10xCRISPR/): 10x Genomics CRISPR and RNA-seq (single-cell RNA/CRISPR)
- [CEL-Seq](CEL-Seq/): barcoding and pooling samples before amplifying RNA with in vitro transcription (v1)
- [CEL-Seq2](CEL-Seq2/): Improvement CEL-Seq, now with UMIs! Implemented on Fluidigm's C1 (v2)
- [Quartz-seq](Quartz-seq/): Riken technology for single-cell RNA-seq
- [Quartz-seq2](Quartz-seq2/): Added umis to Quartz-seq (v2)
- [SHARE-seq](SHARE-seq/): combinatorial indexing stratgy for RNA + chromatin accessibility
- [STRT-seq](STRT-seq/): single-cell tagged reverse transcripton
- [STRT-seq-2i](STRT-seq-2i/): STRT-seq performed on microwells with dual-index 5 prime
- [STRT-seq-C1](STRT-seq-C1/): STRT-seq performed on microfluidics Fluidigm C1
- [Smart-seq2](Smart-seq2/): full-length rna-seq from individual cells
- [Smart-seq3](Smart-seq3/): full-length and five-prime RNA-seq from individual cells
- [sci-RNA-seq](sci-RNA-seq/): combinatorial single-cell RNA-seq

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