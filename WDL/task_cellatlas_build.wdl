task CellAtlasBuild {
    input {
        Array[File] fastqs
        String modality
        File spec_yaml
        File genome_fasta_gz
        File feature_barcodes_txt
        File genome_gtf_gz
    }

    command {
        cellatlas build \
        -o out \
        -s ~{spec_yaml} \
        -fa ~{genome_fasta_gz} \
        -fb ~{feature_barcodes_txt} \
        -g ~{genome_gtf_gz} \
        -m ~{modality} \
        ~{sep=" " fastqs}
    }

    output {
        Directory outDir = "out"
    }

    runtime {
        docker: "myregistry/cellatlasenv:latest"
    }
}
