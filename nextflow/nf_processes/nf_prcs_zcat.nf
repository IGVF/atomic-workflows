// Enable DSL2
nextflow.enable.dsl=2


process run_zcat {

  // Set debug to true
  debug true
  
  // Label the process as 'zcat'
  label 'zcat'

  // Define input path
  input:
    val script_file
    path zcat_file

  // Define output path
  output:
    path "${zcat_file.baseName}", emit: zcat_file_out

  // Script section
  script:
  """
    echo 'Start run_zcat'
    echo "Script file is: $script_file"
    echo "Zcat file is: $zcat_file"
    echo "Output file is: ${zcat_file.baseName}"

    /usr/local/bin/$script_file $zcat_file ${zcat_file.baseName}
    
    echo 'Finished run_zcat'
  """
}
