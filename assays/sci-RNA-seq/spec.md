# sci-RNA-seq
- DOI: [https://doi.org/10.1126/science.aam8940](https://doi.org/10.1126/science.aam8940)
- Description: combinatorial single-cell RNA-seq
- Modalities: RNA
    
## Final Library
###### RNA
<pre style="overflow-x: auto; text-align: left; background-color: #f6f8fa">AATGATACGGCGACCACCGAGATCTACACNNNNNNNNNNACACTCTTTCCCTACACGACGCTCTTCCGATCTNNNNNNNNNNNNNNNNNNXXCTGTCTCTTATACACATCTCCGAGCCCACGAGACNNNNNNNNNNATCTCGTATGCCGTCTTCTGCTTG</pre>
1. <details><summary>illumina_p5</summary>

   - sequence_type: fixed
   - sequence: <pre style="overflow-x: auto; text-align: left; margin: 0; display: inline;">AATGATACGGCGACCACCGAGATCTACAC</pre>
   - min_len: 29
   - max_len: 29
   - onlist: None
   </details>
2. <details><summary>i5</summary>

   - sequence_type: onlist
   - sequence: <pre style="overflow-x: auto; text-align: left; margin: 0; display: inline;">NNNNNNNNNN</pre>
   - min_len: 10
   - max_len: 10
   - onlist: {'filename': 'i5_onlist.txt', 'md5': None}
   </details>
3. <details><summary>truseq_read_1_adapter</summary>

   - sequence_type: fixed
   - sequence: <pre style="overflow-x: auto; text-align: left; margin: 0; display: inline;">ACACTCTTTCCCTACACGACGCTCTTCCGATCT</pre>
   - min_len: 33
   - max_len: 33
   - onlist: None
   </details>
4. <details><summary>read_1</summary>

   - sequence_type: joined
   - sequence: <pre style="overflow-x: auto; text-align: left; margin: 0; display: inline;">NNNNNNNNNNNNNNNNNN</pre>
   - min_len: 18
   - max_len: 18
   - onlist: None
   </details>
5. <details><summary>poly_T</summary>

   - sequence_type: random
   - sequence: <pre style="overflow-x: auto; text-align: left; margin: 0; display: inline;">X</pre>
   - min_len: 1
   - max_len: 98
   - onlist: None
   </details>
6. <details><summary>read_2</summary>

   - sequence_type: joined
   - sequence: <pre style="overflow-x: auto; text-align: left; margin: 0; display: inline;">X</pre>
   - min_len: 1
   - max_len: 98
   - onlist: None
   </details>
7. <details><summary>i7_primer</summary>

   - sequence_type: joined
   - sequence: <pre style="overflow-x: auto; text-align: left; margin: 0; display: inline;">CTGTCTCTTATACACATCTCCGAGCCCACGAGAC</pre>
   - min_len: 34
   - max_len: 34
   - onlist: None
   </details>
8. <details><summary>i7</summary>

   - sequence_type: fixed
   - sequence: <pre style="overflow-x: auto; text-align: left; margin: 0; display: inline;">NNNNNNNNNN</pre>
   - min_len: 10
   - max_len: 10
   - onlist: {'filename': 'i7_onlist.txt', 'md5': None}
   </details>
9. <details><summary>illumina_p7</summary>

   - sequence_type: fixed
   - sequence: <pre style="overflow-x: auto; text-align: left; margin: 0; display: inline;">ATCTCGTATGCCGTCTTCTGCTTG</pre>
   - min_len: 24
   - max_len: 24
   - onlist: None
   </details>
