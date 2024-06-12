version 1.0

import "../tasks/task_chromap_index.wdl" as chromap_index

workflow generate_chromap_index{
    call chromap_index.generate_chromap_index as chromap

    output{
        File chromap_index_tar = chromap.atac_chromap_index
    }
}