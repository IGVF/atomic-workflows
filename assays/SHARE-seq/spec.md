# SHARE-seq
- DOI: [https://doi.org/10.1016/j.cell.2020.09.056](https://doi.org/10.1016/j.cell.2020.09.056)
- Description: The SHARE-seq method is developed based on the idea of combinatorial indexing stratgy that is used in sci-RNA-seq and SPLiT-seq
- Modalities: RNA, ATAC
    
## Final Library
###### RNA
<pre style="overflow-x: auto; text-align: left; background-color: #f6f8fa">AATGATACGGCGACCACCGAGATCTACACNNNNNNNNTCGTCGGCAGCGTCAGATGTGTATAAGAGACAGXXNNNNNNNNNNCTGTCTCTTATACACATCTCCGAGCCCACGAGACTCGGACGATCATGGGNNNNNNNNCAAGTATGCAGCGCGCTCAAGCACGTGGATNNNNNNNNAGTCGTACGCCGATGCGAAACATCGGCCACNNNNNNNNATCTCGTATGCCGTCTTCTGCTTG</pre>
1. <details><summary>illumina_p5</summary>

   - sequence_type: fixed
   - sequence: <pre style="overflow-x: auto; text-align: left; margin: 0; display: inline;">AATGATACGGCGACCACCGAGATCTACAC</pre>
   - min_len: 29
   - max_len: 29
   - onlist: None
   </details>
2. <details><summary>i5</summary>

   - sequence_type: onlist
   - sequence: <pre style="overflow-x: auto; text-align: left; margin: 0; display: inline;">NNNNNNNN</pre>
   - min_len: 8
   - max_len: 8
   - onlist: {'filename': 'RNA_i5_onlist.txt', 'md5': None}
   </details>
3. <details><summary>s5</summary>

   - sequence_type: fixed
   - sequence: <pre style="overflow-x: auto; text-align: left; margin: 0; display: inline;">TCGTCGGCAGCGTC</pre>
   - min_len: 13
   - max_len: 13
   - onlist: None
   </details>
4. <details><summary>ME1</summary>

   - sequence_type: fixed
   - sequence: <pre style="overflow-x: auto; text-align: left; margin: 0; display: inline;">AGATGTGTATAAGAGACAG</pre>
   - min_len: 19
   - max_len: 19
   - onlist: None
   </details>
5. <details><summary>cDNA</summary>

   - sequence_type: random
   - sequence: <pre style="overflow-x: auto; text-align: left; margin: 0; display: inline;">X</pre>
   - min_len: 1
   - max_len: 99
   - onlist: None
   </details>
6. <details><summary>poly_A</summary>

   - sequence_type: random
   - sequence: <pre style="overflow-x: auto; text-align: left; margin: 0; display: inline;">X</pre>
   - min_len: 1
   - max_len: 99
   - onlist: None
   </details>
7. <details><summary>UMI</summary>

   - sequence_type: random
   - sequence: <pre style="overflow-x: auto; text-align: left; margin: 0; display: inline;">NNNNNNNNNN</pre>
   - min_len: 10
   - max_len: 10
   - onlist: None
   </details>
8. <details><summary>ME2</summary>

   - sequence_type: fixed
   - sequence: <pre style="overflow-x: auto; text-align: left; margin: 0; display: inline;">CTGTCTCTTATACACATCT</pre>
   - min_len: 19
   - max_len: 19
   - onlist: None
   </details>
9. <details><summary>s7</summary>

   - sequence_type: fixed
   - sequence: <pre style="overflow-x: auto; text-align: left; margin: 0; display: inline;">CCGAGCCCACGAGAC</pre>
   - min_len: 15
   - max_len: 15
   - onlist: None
   </details>
10. <details><summary>linker1</summary>

    - sequence_type: fixed
    - sequence: <pre style="overflow-x: auto; text-align: left; margin: 0; display: inline;">TCGGACGATCATGGG</pre>
    - min_len: 15
    - max_len: 15
    - onlist: None
    </details>
11. <details><summary>bc1</summary>

    - sequence_type: onlist
    - sequence: <pre style="overflow-x: auto; text-align: left; margin: 0; display: inline;">NNNNNNNN</pre>
    - min_len: 8
    - max_len: 8
    - onlist: {'filename': 'bc_onlist.txt', 'md5': None}
    </details>
12. <details><summary>linker2</summary>

    - sequence_type: fixed
    - sequence: <pre style="overflow-x: auto; text-align: left; margin: 0; display: inline;">CAAGTATGCAGCGCGCTCAAGCACGTGGAT</pre>
    - min_len: 30
    - max_len: 30
    - onlist: None
    </details>
13. <details><summary>bc2</summary>

    - sequence_type: onlist
    - sequence: <pre style="overflow-x: auto; text-align: left; margin: 0; display: inline;">NNNNNNNN</pre>
    - min_len: 8
    - max_len: 8
    - onlist: {'filename': 'bc_onlist.txt', 'md5': None}
    </details>
14. <details><summary>linker3</summary>

    - sequence_type: fixed
    - sequence: <pre style="overflow-x: auto; text-align: left; margin: 0; display: inline;">AGTCGTACGCCGATGCGAAACATCGGCCAC</pre>
    - min_len: 30
    - max_len: 30
    - onlist: None
    </details>
15. <details><summary>bc3</summary>

    - sequence_type: onlist
    - sequence: <pre style="overflow-x: auto; text-align: left; margin: 0; display: inline;">NNNNNNNN</pre>
    - min_len: 8
    - max_len: 8
    - onlist: {'filename': 'bc_onlist.txt', 'md5': None}
    </details>
16. <details><summary>illumina_p7</summary>

    - sequence_type: fixed
    - sequence: <pre style="overflow-x: auto; text-align: left; margin: 0; display: inline;">ATCTCGTATGCCGTCTTCTGCTTG</pre>
    - min_len: 24
    - max_len: 24
    - onlist: {'filename': 'bc_onlist.txt', 'md5': None}
    </details>
###### ATAC
<pre style="overflow-x: auto; text-align: left; background-color: #f6f8fa">AATGATACGGCGACCACCGAGATCTACACNNNNNNNNTCGTCGGCAGCGTCAGATGTGTATAAGAGACAGXCTGTCTCTTATACACATCTCCGAGCCCACGAGACTCGGACGATCATGGGNNNNNNNNCAAGTATGCAGCGCGCTCAAGCACGTGGATNNNNNNNNAGTCGTACGCCGATGCGAAACATCGGCCACNNNNNNNNATCTCGTATGCCGTCTTCTGCTTG</pre>
1. <details><summary>illumina_p5</summary>

   - sequence_type: fixed
   - sequence: <pre style="overflow-x: auto; text-align: left; margin: 0; display: inline;">AATGATACGGCGACCACCGAGATCTACAC</pre>
   - min_len: 29
   - max_len: 29
   - onlist: None
   </details>
2. <details><summary>i5</summary>

   - sequence_type: onlist
   - sequence: <pre style="overflow-x: auto; text-align: left; margin: 0; display: inline;">NNNNNNNN</pre>
   - min_len: 10
   - max_len: 10
   - onlist: {'filename': 'ATAC_i5_onlist.txt', 'md5': None}
   </details>
3. <details><summary>s5</summary>

   - sequence_type: fixed
   - sequence: <pre style="overflow-x: auto; text-align: left; margin: 0; display: inline;">TCGTCGGCAGCGTC</pre>
   - min_len: 14
   - max_len: 14
   - onlist: None
   </details>
4. <details><summary>ME1</summary>

   - sequence_type: fixed
   - sequence: <pre style="overflow-x: auto; text-align: left; margin: 0; display: inline;">AGATGTGTATAAGAGACAG</pre>
   - min_len: 19
   - max_len: 19
   - onlist: None
   </details>
5. <details><summary>gDNA</summary>

   - sequence_type: random
   - sequence: <pre style="overflow-x: auto; text-align: left; margin: 0; display: inline;">X</pre>
   - min_len: 1
   - max_len: 98
   - onlist: None
   </details>
6. <details><summary>ME2</summary>

   - sequence_type: fixed
   - sequence: <pre style="overflow-x: auto; text-align: left; margin: 0; display: inline;">CTGTCTCTTATACACATCT</pre>
   - min_len: 19
   - max_len: 19
   - onlist: None
   </details>
7. <details><summary>s7</summary>

   - sequence_type: fixed
   - sequence: <pre style="overflow-x: auto; text-align: left; margin: 0; display: inline;">CCGAGCCCACGAGAC</pre>
   - min_len: 15
   - max_len: 15
   - onlist: None
   </details>
8. <details><summary>linker1</summary>

   - sequence_type: fixed
   - sequence: <pre style="overflow-x: auto; text-align: left; margin: 0; display: inline;">TCGGACGATCATGGG</pre>
   - min_len: 15
   - max_len: 15
   - onlist: None
   </details>
9. <details><summary>bc1</summary>

   - sequence_type: onlist
   - sequence: <pre style="overflow-x: auto; text-align: left; margin: 0; display: inline;">NNNNNNNN</pre>
   - min_len: 8
   - max_len: 8
   - onlist: {'filename': 'bc_onlist.txt', 'md5': None}
   </details>
10. <details><summary>linker2</summary>

    - sequence_type: fixed
    - sequence: <pre style="overflow-x: auto; text-align: left; margin: 0; display: inline;">CAAGTATGCAGCGCGCTCAAGCACGTGGAT</pre>
    - min_len: 30
    - max_len: 30
    - onlist: None
    </details>
11. <details><summary>bc2</summary>

    - sequence_type: onlist
    - sequence: <pre style="overflow-x: auto; text-align: left; margin: 0; display: inline;">NNNNNNNN</pre>
    - min_len: 8
    - max_len: 8
    - onlist: {'filename': 'bc_onlist.txt', 'md5': None}
    </details>
12. <details><summary>linker3</summary>

    - sequence_type: fixed
    - sequence: <pre style="overflow-x: auto; text-align: left; margin: 0; display: inline;">AGTCGTACGCCGATGCGAAACATCGGCCAC</pre>
    - min_len: 30
    - max_len: 30
    - onlist: None
    </details>
13. <details><summary>bc3</summary>

    - sequence_type: onlist
    - sequence: <pre style="overflow-x: auto; text-align: left; margin: 0; display: inline;">NNNNNNNN</pre>
    - min_len: 8
    - max_len: 8
    - onlist: {'filename': 'bc_onlist.txt', 'md5': None}
    </details>
14. <details><summary>illumina_p7</summary>

    - sequence_type: fixed
    - sequence: <pre style="overflow-x: auto; text-align: left; margin: 0; display: inline;">ATCTCGTATGCCGTCTTCTGCTTG</pre>
    - min_len: 24
    - max_len: 24
    - onlist: None
    </details>
