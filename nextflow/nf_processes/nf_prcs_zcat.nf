// Enable DSL2
nextflow.enable.dsl=2

process run_zcat {
  debug true
  label 'zcat'
  input:
    path zcat_file
  output:
    path "${zcat_file.baseName}", emit: zcat_file_out
  script:
  """
    echo start run_zcat
    echo 'zcat file is: $zcat_file'
    echo 'Files before processing:'
    ls -lt
    if [[ -e $zcat_file && $zcat_file == *.gz ]]; then
      zcat $zcat_file > ${zcat_file.baseName}
    elif [[ -e $zcat_file ]]; then
      cp $zcat_file ${zcat_file.baseName}
    else
      echo "Error: File $zcat_file not found."
      exit 1
    fi
    echo 'Files after processing:'
    ls -lt
    echo finished run_zcat
  """
}
