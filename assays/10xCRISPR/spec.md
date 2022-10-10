# 10xCrispr assay
- DOI: [https://www.10xgenomics.com/products/single-cell-crispr-screening](https://www.10xgenomics.com/products/single-cell-crispr-screening)
- Description: single-cell CRISPR screen and RNA-seq
- Modalities: CRISPR, RNA
    
## Final Library
###### CRISPR
<pre style="overflow-x: auto; text-align: left; background-color: #f6f8fa">AATGATACGGCGACCACCGAGATCTACACTCGTCGGCAGCGTCAGATGTGTATAAGAGACAGNNNNNNNNNNNNNNNNNNNNNNNNNNNNTTGCTAGGACCGGCCTTAAAGCGCACCGACTCGGTGCCACTTTTTCAAGTTGATAACGGACTAGCCTTATTTAAACTTGCTATGCTGTTTCCAGCTTAGCTCTTAAACNNNNNNNNNNNNNNNNNXXXCCCATGTACTCTGCGTTGATACCACTGCTTAGATCGGAAGAGCACACGTCTGAACTCCAGTCACNNNNNNNNATCTCGTATGCCGTCTTCTGCTTG</pre>
1. <details><summary>illumina_p5</summary>

   - sequence_type: fixed
   - sequence: <pre style="overflow-x: auto; text-align: left; margin: 0; display: inline;">AATGATACGGCGACCACCGAGATCTACAC</pre>
   - min_len: 29
   - max_len: 29
   - onlist: None
   </details>
2. <details><summary>nextera_r1</summary>

   - sequence_type: fixed
   - sequence: <pre style="overflow-x: auto; text-align: left; margin: 0; display: inline;">TCGTCGGCAGCGTCAGATGTGTATAAGAGACAG</pre>
   - min_len: 33
   - max_len: 33
   - onlist: None
   </details>
3. <details><summary>cell_bc</summary>

   - sequence_type: onlist
   - sequence: <pre style="overflow-x: auto; text-align: left; margin: 0; display: inline;">NNNNNNNNNNNNNNNN</pre>
   - min_len: 16
   - max_len: 16
   - onlist: {'filename': '737K-august-2016.txt.gz', 'md5': None}
   </details>
4. <details><summary>umi</summary>

   - sequence_type: random
   - sequence: <pre style="overflow-x: auto; text-align: left; margin: 0; display: inline;">NNNNNNNNNNNN</pre>
   - min_len: 12
   - max_len: 12
   - onlist: None
   </details>
5. <details><summary>cap_seq_1</summary>

   - sequence_type: fixed
   - sequence: <pre style="overflow-x: auto; text-align: left; margin: 0; display: inline;">TTGCTAGGACCGGCCTTAAAGC</pre>
   - min_len: 22
   - max_len: 22
   - onlist: None
   </details>
6. <details><summary>sgRNA_scaffold</summary>

   - sequence_type: fixed
   - sequence: <pre style="overflow-x: auto; text-align: left; margin: 0; display: inline;">GCACCGACTCGGTGCCACTTTTTCAAGTTGATAACGGACTAGCCTTATTTAAACTTGCTATGCTGTTTCCAGCTTAGCTCTTAAAC</pre>
   - min_len: 86
   - max_len: 86
   - onlist: None
   </details>
7. <details><summary>sgRNA_target</summary>

   - sequence_type: onlist
   - sequence: <pre style="overflow-x: auto; text-align: left; margin: 0; display: inline;">NNNNNNNNNNNNNNNNNXXX</pre>
   - min_len: 17
   - max_len: 20
   - onlist: {'filename': 'sgRNA_target_onlist.txt', 'md5': None}
   </details>
8. <details><summary>triple_c</summary>

   - sequence_type: fixed
   - sequence: <pre style="overflow-x: auto; text-align: left; margin: 0; display: inline;">CCC</pre>
   - min_len: 3
   - max_len: 3
   - onlist: None
   </details>
9. <details><summary>tso</summary>

   - sequence_type: fixed
   - sequence: <pre style="overflow-x: auto; text-align: left; margin: 0; display: inline;">ATGTACTCTGCGTTGATACCACTGCTT</pre>
   - min_len: 27
   - max_len: 27
   - onlist: None
   </details>
10. <details><summary>truseq_r2</summary>

    - sequence_type: fixed
    - sequence: <pre style="overflow-x: auto; text-align: left; margin: 0; display: inline;">AGATCGGAAGAGCACACGTCTGAACTCCAGTCAC</pre>
    - min_len: 27
    - max_len: 27
    - onlist: None
    </details>
11. <details><summary>sample_index</summary>

    - sequence_type: random
    - sequence: <pre style="overflow-x: auto; text-align: left; margin: 0; display: inline;">NNNNNNNN</pre>
    - min_len: 8
    - max_len: 8
    - onlist: None
    </details>
12. <details><summary>illumina_p7</summary>

    - sequence_type: fixed
    - sequence: <pre style="overflow-x: auto; text-align: left; margin: 0; display: inline;">ATCTCGTATGCCGTCTTCTGCTTG</pre>
    - min_len: 24
    - max_len: 24
    - onlist: None
    </details>
###### RNA
<pre style="overflow-x: auto; text-align: left; background-color: #f6f8fa">AATGATACGGCGACCACCGAGATCTACACTCTTTCCCTACACGACGCTCTTCCGATCTNNNNNNNNNNNNNNNNNNNNNNNNNNNNXXAGATCGGAAGAGCACACGTCTGAACTCCAGTCACNNNNNNNNATCTCGTATGCCGTCTTCTGCTTG</pre>
1. <details><summary>Illumina P5</summary>

   - sequence_type: fixed
   - sequence: <pre style="overflow-x: auto; text-align: left; margin: 0; display: inline;">AATGATACGGCGACCACCGAGATCTACAC</pre>
   - min_len: 29
   - max_len: 29
   - onlist: None
   </details>
2. <details><summary>Truseq Read 1</summary>

   - sequence_type: fixed
   - sequence: <pre style="overflow-x: auto; text-align: left; margin: 0; display: inline;">TCTTTCCCTACACGACGCTCTTCCGATCT</pre>
   - min_len: 10
   - max_len: 10
   - onlist: None
   </details>
3. <details><summary>Cell Barcode</summary>

   - sequence_type: onlist
   - sequence: <pre style="overflow-x: auto; text-align: left; margin: 0; display: inline;">NNNNNNNNNNNNNNNN</pre>
   - min_len: 16
   - max_len: 16
   - onlist: {'filename': '737K-august-2016.txt.gz', 'md5': None}
   </details>
4. <details><summary>UMI</summary>

   - sequence_type: random
   - sequence: <pre style="overflow-x: auto; text-align: left; margin: 0; display: inline;">NNNNNNNNNNNN</pre>
   - min_len: 12
   - max_len: 12
   - onlist: None
   </details>
5. <details><summary>Poly-T</summary>

   - sequence_type: random
   - sequence: <pre style="overflow-x: auto; text-align: left; margin: 0; display: inline;">X</pre>
   - min_len: 1
   - max_len: 98
   - onlist: None
   </details>
6. <details><summary>cDNA</summary>

   - sequence_type: random
   - sequence: <pre style="overflow-x: auto; text-align: left; margin: 0; display: inline;">X</pre>
   - min_len: 1
   - max_len: 98
   - onlist: None
   </details>
7. <details><summary>Truseq Read 2</summary>

   - sequence_type: fixed
   - sequence: <pre style="overflow-x: auto; text-align: left; margin: 0; display: inline;">AGATCGGAAGAGCACACGTCTGAACTCCAGTCAC</pre>
   - min_len: 34
   - max_len: 34
   - onlist: None
   </details>
8. <details><summary>Truseq Read 2</summary>

   - sequence_type: onlist
   - sequence: <pre style="overflow-x: auto; text-align: left; margin: 0; display: inline;">NNNNNNNN</pre>
   - min_len: 8
   - max_len: 8
   - onlist: {'filename': 'sample_bc_onlist.txt', 'md5': None}
   </details>
9. <details><summary>Illumina P7</summary>

   - sequence_type: fixed
   - sequence: <pre style="overflow-x: auto; text-align: left; margin: 0; display: inline;">ATCTCGTATGCCGTCTTCTGCTTG</pre>
   - min_len: 24
   - max_len: 24
   - onlist: None
   </details>
