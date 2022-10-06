# CEL-Seq2
- DOI: [https://doi.org/10.1186/s13059-016-0938-8](https://doi.org/10.1186/s13059-016-0938-8)
- Description: Improvement CEL-Seq, now with UMIs! Implemented on Fluidigm's C1
- Modalities: RNA
    
## Final Library
###### RNA
<pre style="overflow-x: auto; text-align: left; background-color: #f6f8fa">AATGATACGGCGACCACCGAGATCTACACGTTCAGAGTTCTACAGTCCGACGATCNNNNNNNNNNNNXXTGGAATTCTCGGGTGCCAAGGAACTCCAGTCACNNNNNNATCTCGTATGCCGTCTTCTGCTTG</pre>
1. <details><summary>illumina_p5</summary>

   - sequence_type: fixed
   - sequence: <pre style="overflow-x: auto; text-align: left; margin: 0; display: inline;">AATGATACGGCGACCACCGAGATCTACAC</pre>
   - min_len: 29
   - max_len: 29
   - onlist: None
   </details>
2. <details><summary>RA5</summary>

   - sequence_type: fixed
   - sequence: <pre style="overflow-x: auto; text-align: left; margin: 0; display: inline;">GTTCAGAGTTCTACAGTCCGACGATC</pre>
   - min_len: 26
   - max_len: 26
   - onlist: None
   </details>
3. <details><summary>umi</summary>

   - sequence_type: random
   - sequence: <pre style="overflow-x: auto; text-align: left; margin: 0; display: inline;">NNNNNN</pre>
   - min_len: 6
   - max_len: 6
   - onlist: None
   </details>
4. <details><summary>cell_bc</summary>

   - sequence_type: random
   - sequence: <pre style="overflow-x: auto; text-align: left; margin: 0; display: inline;">NNNNNN</pre>
   - min_len: 6
   - max_len: 6
   - onlist: None
   </details>
5. <details><summary>poly_T</summary>

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
7. <details><summary>RA3</summary>

   - sequence_type: fixed
   - sequence: <pre style="overflow-x: auto; text-align: left; margin: 0; display: inline;">TGGAATTCTCGGGTGCCAAGG</pre>
   - min_len: 21
   - max_len: 21
   - onlist: None
   </details>
8. <details><summary>link_1</summary>

   - sequence_type: fixed
   - sequence: <pre style="overflow-x: auto; text-align: left; margin: 0; display: inline;">AACTCCAGTCAC</pre>
   - min_len: 12
   - max_len: 12
   - onlist: None
   </details>
9. <details><summary>sample_bc</summary>

   - sequence_type: onlist
   - sequence: <pre style="overflow-x: auto; text-align: left; margin: 0; display: inline;">NNNNNN</pre>
   - min_len: 6
   - max_len: 6
   - onlist: {'filename': 'sample_bc_onlist.txt', 'md5': None}
   </details>
10. <details><summary>illumina_p7</summary>

    - sequence_type: fixed
    - sequence: <pre style="overflow-x: auto; text-align: left; margin: 0; display: inline;">ATCTCGTATGCCGTCTTCTGCTTG</pre>
    - min_len: 24
    - max_len: 24
    - onlist: None
    </details>
