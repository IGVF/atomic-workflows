# 10x-ATAC-RNA
- DOI: [https://support.10xgenomics.com/single-cell-multiome-atac-gex](https://support.10xgenomics.com/single-cell-multiome-atac-gex)
- Description: Single Cell Multiome ATAC + Gene Expression
- Modalities: RNA, ATAC
    
## Final Library
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
   - min_len: 29
   - max_len: 29
   - onlist: None
   </details>
3. <details><summary>Cell Barcode</summary>

   - sequence_type: onlist
   - sequence: <pre style="overflow-x: auto; text-align: left; margin: 0; display: inline;">NNNNNNNNNNNNNNNN</pre>
   - min_len: 16
   - max_len: 16
   - onlist: {'filename': 'cell_bc_onlist.txt', 'md5': None}
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
   - max_len: 99
   - onlist: None
   </details>
6. <details><summary>cDNA</summary>

   - sequence_type: random
   - sequence: <pre style="overflow-x: auto; text-align: left; margin: 0; display: inline;">X</pre>
   - min_len: 1
   - max_len: 99
   - onlist: None
   </details>
7. <details><summary>Truseq Read 2</summary>

   - sequence_type: fixed
   - sequence: <pre style="overflow-x: auto; text-align: left; margin: 0; display: inline;">AGATCGGAAGAGCACACGTCTGAACTCCAGTCAC</pre>
   - min_len: 34
   - max_len: 34
   - onlist: None
   </details>
8. <details><summary>Sample Index</summary>

   - sequence_type: random
   - sequence: <pre style="overflow-x: auto; text-align: left; margin: 0; display: inline;">NNNNNNNN</pre>
   - min_len: 8
   - max_len: 8
   - onlist: None
   </details>
9. <details><summary>Illumina P7</summary>

   - sequence_type: fixed
   - sequence: <pre style="overflow-x: auto; text-align: left; margin: 0; display: inline;">ATCTCGTATGCCGTCTTCTGCTTG</pre>
   - min_len: 24
   - max_len: 24
   - onlist: None
   </details>
###### ATAC
<pre style="overflow-x: auto; text-align: left; background-color: #f6f8fa">AATGATACGGCGACCACCGAGATCTACACNNNNNNNNNNNNNNNNCGCGTCTGTCGTCGGCAGCGTCAGATGTGTATAAGAGACAGXCTGTCTCTTATACACATCTCCGAGCCCACGAGACNNNNNNNNATCTCGTATGCCGTCTTCTGCTTG</pre>
1. <details><summary>Illumina P5</summary>

   - sequence_type: random
   - sequence: <pre style="overflow-x: auto; text-align: left; margin: 0; display: inline;">AATGATACGGCGACCACCGAGATCTACAC</pre>
   - min_len: 29
   - max_len: 29
   - onlist: None
   </details>
2. <details><summary>Cell Barcode</summary>

   - sequence_type: onlist
   - sequence: <pre style="overflow-x: auto; text-align: left; margin: 0; display: inline;">NNNNNNNNNNNNNNNN</pre>
   - min_len: 16
   - max_len: 16
   - onlist: {'filename': 'cell_bc_onlist.txt', 'md5': None}
   </details>
3. <details><summary>Spacer</summary>

   - sequence_type: fixed
   - sequence: <pre style="overflow-x: auto; text-align: left; margin: 0; display: inline;">CGCGTCTG</pre>
   - min_len: 8
   - max_len: 8
   - onlist: None
   </details>
4. <details><summary>S5</summary>

   - sequence_type: fixed
   - sequence: <pre style="overflow-x: auto; text-align: left; margin: 0; display: inline;">TCGTCGGCAGCGTC</pre>
   - min_len: 14
   - max_len: 14
   - onlist: None
   </details>
5. <details><summary>ME1</summary>

   - sequence_type: fixed
   - sequence: <pre style="overflow-x: auto; text-align: left; margin: 0; display: inline;">AGATGTGTATAAGAGACAG</pre>
   - min_len: 19
   - max_len: 19
   - onlist: None
   </details>
6. <details><summary>gDNA</summary>

   - sequence_type: randpm
   - sequence: <pre style="overflow-x: auto; text-align: left; margin: 0; display: inline;">X</pre>
   - min_len: 1
   - max_len: 99
   - onlist: None
   </details>
7. <details><summary>ME2</summary>

   - sequence_type: fixed
   - sequence: <pre style="overflow-x: auto; text-align: left; margin: 0; display: inline;">CTGTCTCTTATACACATCT</pre>
   - min_len: 19
   - max_len: 19
   - onlist: None
   </details>
8. <details><summary>S7</summary>

   - sequence_type: fixed
   - sequence: <pre style="overflow-x: auto; text-align: left; margin: 0; display: inline;">CCGAGCCCACGAGAC</pre>
   - min_len: 15
   - max_len: 15
   - onlist: None
   </details>
9. <details><summary>Sample Index</summary>

   - sequence_type: randm
   - sequence: <pre style="overflow-x: auto; text-align: left; margin: 0; display: inline;">NNNNNNNN</pre>
   - min_len: 8
   - max_len: 8
   - onlist: None
   </details>
10. <details><summary>Illumina P7</summary>

    - sequence_type: fixed
    - sequence: <pre style="overflow-x: auto; text-align: left; margin: 0; display: inline;">ATCTCGTATGCCGTCTTCTGCTTG</pre>
    - min_len: 24
    - max_len: 24
    - onlist: None
    </details>
