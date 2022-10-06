# Quartz-seq2
- DOI: [https://doi.org/10.1186/s13059-018-1407-3](https://doi.org/10.1186/s13059-018-1407-3)
- Description: Added umis to Quartz-seq
- Modalities: RNA
    
## Final Library
###### RNA
<pre style="overflow-x: auto; text-align: left; background-color: #f6f8fa">AATGATACGGCGACCACCGAGATCTACACTTGTATAGAATTCGCGGCCGCTCGCGATACNNNNNNNNNNNNNNNNNNNNNNNXXAGATCGGAAGAGCACACGTCTGAACTCCAGTCACNNNNNNATCTCGTATGCCGTCTTCTGCTTG</pre>
1. <details><summary>illumina_p5</summary>

   - sequence_type: fixed
   - sequence: <pre style="overflow-x: auto; text-align: left; margin: 0; display: inline;">AATGATACGGCGACCACCGAGATCTACAC</pre>
   - min_len: 29
   - max_len: 29
   - onlist: None
   </details>
2. <details><summary>double_T</summary>

   - sequence_type: fixed
   - sequence: <pre style="overflow-x: auto; text-align: left; margin: 0; display: inline;">TT</pre>
   - min_len: 2
   - max_len: 2
   - onlist: None
   </details>
3. <details><summary>gM_primer</summary>

   - sequence_type: fixed
   - sequence: <pre style="overflow-x: auto; text-align: left; margin: 0; display: inline;">GTATAGAATTCGCGGCCGCTCGCGAT</pre>
   - min_len: 24
   - max_len: 24
   - onlist: None
   </details>
4. <details><summary>link_1</summary>

   - sequence_type: fixed
   - sequence: <pre style="overflow-x: auto; text-align: left; margin: 0; display: inline;">AC</pre>
   - min_len: 2
   - max_len: 2
   - onlist: None
   </details>
5. <details><summary>cell_bc</summary>

   - sequence_type: onlist
   - sequence: <pre style="overflow-x: auto; text-align: left; margin: 0; display: inline;">NNNNNNNNNNNNNNN</pre>
   - min_len: 15
   - max_len: 15
   - onlist: {'filename': 'cell_bc_onlist.txt', 'md5': None}
   </details>
6. <details><summary>umi</summary>

   - sequence_type: random
   - sequence: <pre style="overflow-x: auto; text-align: left; margin: 0; display: inline;">NNNNNNNN</pre>
   - min_len: 8
   - max_len: 8
   - onlist: None
   </details>
7. <details><summary>ploy_T</summary>

   - sequence_type: random
   - sequence: <pre style="overflow-x: auto; text-align: left; margin: 0; display: inline;">X</pre>
   - min_len: 1
   - max_len: 98
   - onlist: None
   </details>
8. <details><summary>cDNA</summary>

   - sequence_type: random
   - sequence: <pre style="overflow-x: auto; text-align: left; margin: 0; display: inline;">X</pre>
   - min_len: 1
   - max_len: 98
   - onlist: None
   </details>
9. <details><summary>truseq_read_2</summary>

   - sequence_type: fixed
   - sequence: <pre style="overflow-x: auto; text-align: left; margin: 0; display: inline;">AGATCGGAAGAGCACACGTCTGAACTCCAGTCAC</pre>
   - min_len: 34
   - max_len: 34
   - onlist: None
   </details>
10. <details><summary>sample_index</summary>

    - sequence_type: random
    - sequence: <pre style="overflow-x: auto; text-align: left; margin: 0; display: inline;">NNNNNN</pre>
    - min_len: 6
    - max_len: 6
    - onlist: None
    </details>
11. <details><summary>illumina_p7</summary>

    - sequence_type: fixed
    - sequence: <pre style="overflow-x: auto; text-align: left; margin: 0; display: inline;">ATCTCGTATGCCGTCTTCTGCTTG</pre>
    - min_len: 24
    - max_len: 24
    - onlist: None
    </details>
