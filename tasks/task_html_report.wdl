version 1.0

# TASK
# SHARE-html-report
# Gather information from log files


task html_report {
    meta {
        version: 'v1.0'
        author: 'Neva C. Durand (neva@broadinstitute.org) at Broad Institute of MIT and Harvard'
        description: 'Broad Institute of MIT and Harvard SHARE-Seq pipeline: create html report task'
    }

    input {
        # This function takes as input the files to append to the report
        # and the metrics and writes out an html file

        String? prefix

        # Stats for ATAC and RNA, will go at top of html from terra table
        File? atac_metrics
        File? rna_metrics

        ## JPEG files to be encoded and appended to html
        Array[File?] image_files

        ## Raw text logs to append to end of html
        Array[String?] log_files

        ## Outputs from tasks
        File? joint_qc_vals
        File? atac_archr_vals
        File? atac_tss_vals

        String docker_image = ' polumechanos/html_report:igvf'

    }

    String output_file = "${default="share-seq" prefix}.html"
    # need to select from valid files since some are optional
    Array[File] valid_image_files = select_all(image_files)
    Array[String] valid_log_files = select_all(log_files)
    String output_csv_file = "${default="share-seq" prefix}.csv"

    command <<<

        echo "~{sep="\n" valid_image_files}" > image_list.txt
        echo "~{sep="\n" valid_log_files}" > log_list.txt
        
        PYTHONIOENCODING=utf-8 python3 /software/write_html.py ~{output_file} image_list.txt log_list.txt ~{output_csv_file} atac_metrics rna_metrics
        
        echo 'PKR,~{prefix}' | cat - ~{output_csv_file} > temp && mv temp ~{output_csv_file} 

    >>>
    output {
        File html_report_file = "~{output_file}"
        File csv_summary_file = "~{output_csv_file}"
    }

    runtime {
        docker: "${docker_image}"
    }
}