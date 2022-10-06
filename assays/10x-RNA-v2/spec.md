# 10x-RNA-v2
- DOI: [https://doi.org/10.1038/ncomms14049](https://doi.org/10.1038/ncomms14049)
- Description: The 10x Genomics Chromium Single Cell 3' Solution V2 chemistry
- Modalities: RNA
    
## Final Library
###### RNA
<pre style="overflow-x: auto; text-align: left; background-color: #f6f8fa">AATGATACGGCGACCACCGAGATCTACACTCTTTCCCTACACGACGCTCTTCCGATCTNNNNNNNNNNNNNNNNNNNNNNNNNNXXAGATCGGAAGAGCACACGTCTGAACTCCAGTCACNNNNNNNNATCTCGTATGCCGTCTTCTGCTTG</pre>
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
   - sequence: <pre style="overflow-x: auto; text-align: left; margin: 0; display: inline;">NNNNNNNNNN</pre>
   - min_len: 10
   - max_len: 10
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
