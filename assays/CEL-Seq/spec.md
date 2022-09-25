# CEL-Seq
- DOI: [https://doi.org/10.1016/j.celrep.2012.08.003](https://doi.org/10.1016/j.celrep.2012.08.003)
- Description: barcoding and pooling samples before amplifying RNA with in vitro transcription
- Modalities: RNA
    
## Final Library
###### RNA
<pre style="overflow-x: auto; text-align: left; background-color: #f6f8fa">AATGATACGGCGACCACCGAGATCTACACGTTCAGAGTTCTACAGTCCGACGATCNNNNNNNNXXTGGAATTCTCGGGTGCCAAGGAACTCCAGTCACNNNNNNATCTCGTATGCCGTCTTCTGCTTG</pre>
1. <details><summary>Illumina P5</summary>

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
3. <details><summary>Cell Barcode</summary>

   - sequence_type: random
   - sequence: <pre style="overflow-x: auto; text-align: left; margin: 0; display: inline;">NNNNNNNN</pre>
   - min_len: 8
   - max_len: 8
   - onlist: None
   </details>
4. <details><summary>Poly-T</summary>

   - sequence_type: random
   - sequence: <pre style="overflow-x: auto; text-align: left; margin: 0; display: inline;">X</pre>
   - min_len: 1
   - max_len: 98
   - onlist: None
   </details>
5. <details><summary>cDNA</summary>

   - sequence_type: random
   - sequence: <pre style="overflow-x: auto; text-align: left; margin: 0; display: inline;">X</pre>
   - min_len: 1
   - max_len: 98
   - onlist: None
   </details>
6. <details><summary>RA3</summary>

   - sequence_type: fixed
   - sequence: <pre style="overflow-x: auto; text-align: left; margin: 0; display: inline;">TGGAATTCTCGGGTGCCAAGG</pre>
   - min_len: 21
   - max_len: 21
   - onlist: None
   </details>
7. <details><summary>Link 1</summary>

   - sequence_type: fixed
   - sequence: <pre style="overflow-x: auto; text-align: left; margin: 0; display: inline;">AACTCCAGTCAC</pre>
   - min_len: 12
   - max_len: 12
   - onlist: None
   </details>
8. <details><summary>Sample BC</summary>

   - sequence_type: onlist
   - sequence: <pre style="overflow-x: auto; text-align: left; margin: 0; display: inline;">NNNNNN</pre>
   - min_len: 6
   - max_len: 6
   - onlist: sample_bc_onlist.txt
   </details>
9. <details><summary>Illumina P7</summary>

   - sequence_type: fixed
   - sequence: <pre style="overflow-x: auto; text-align: left; margin: 0; display: inline;">ATCTCGTATGCCGTCTTCTGCTTG</pre>
   - min_len: 24
   - max_len: 24
   - onlist: None
   </details>
