// Enable DSL2
nextflow.enable.dsl=2

process run_synpase_download {
  debug true
  executor = 'local' // Or specify your desired executor
  conda 'synapseclient'

  input:
    tuple val(synid_idx), val(synid_fastq1), val(synid_fastq2)
    val token
  output:
    path "idx_out.txt", emit: idx_out_path
    path "fastq1.txt", emit: fastq1_out_path
    path "fastq2.txt", emit: fastq2_out_path
  script:

  """
    #!/usr/bin/env python

    token='${token}'
    print("token is ",token)

    synid_idx='${synid_idx}'
    print("synid_idx without the brackets {}".format(synid_idx))
    synid_fastq1='${synid_fastq1}'
    print("synid_fastq1 without the brackets {}".format(synid_fastq1))
    synid_fastq2='${synid_fastq2}'
    print("synid_fastq2 without the brackets {}".format(synid_fastq2))
    
    import synapseclient
    syn = synapseclient.login(authToken=token)

    idx_file_entity = syn.get(synid_idx, downloadFile=True)
    print("idx_file_entity is ",idx_file_entity)
    idx_out = idx_file_entity.path
    print("finished download synid_idx ",synid_idx," to ",idx_out)
    with open('idx_out.txt', 'w') as out:
      out.write(idx_out)

    fastq1_file_entity = syn.get(synid_fastq1, downloadFile=True)
    print("fastq1_file_entity is ",fastq1_file_entity)
    fastq1_fastq_gz = fastq1_file_entity.path
    print("finished download synid_fastq1 ",synid_fastq1," to ",fastq1_fastq_gz)
    with open('fastq1.txt', 'w') as out:
      out.write(fastq1_fastq_gz)

    fastq2_file_entity = syn.get(synid_fastq2, downloadFile=True)
    print("fastq2_file_entity is ",fastq2_file_entity)
    fastq2_fastq_gz = fastq2_file_entity.path
    print("finished download synid_fastq2 ",synid_fastq2," to ",fastq2_fastq_gz)
    with open('fastq2.txt', 'w') as out:
      out.write(fastq2_fastq_gz)
  """
}


process run_synpase_upload {
  debug true
  executor = 'local' // Or specify your desired executor
  conda 'synapseclient'

  input:
    tuple val(destination_synid_idx)
    val token
    path file_to_upload
  script:

  """
    #!/usr/bin/env python

    token='${token}'
    print("token is ",token)

    destination_synid_idx='${destination_synid_idx}'
    print("destination_synid_idx is {}".format(destination_synid_idx))
    file_to_upload='${file_to_upload}'
    print("file_to_upload is {}".format(synid_fastq1))
    
    import synapseclient
    syn = synapseclient.login(authToken=token)

    file_entity = syn.File(file_to_upload, parent=destination_synid_idx)
    syn.store(file_entity)
    print("File copied to Synapse successfully.")

  """
}