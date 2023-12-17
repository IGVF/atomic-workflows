nextflow.enable.dsl=2

process run_downloadFiles {
  debug true
  label 'download'
  executor = 'local' // Or specify your desired executor
  disk '10 GB'
  // conda 'wget curl'
  input:
    tuple val(idx1), val(idx2),val(fastq1), val(fastq2), val(seqspec_raw_url)
  output:
    path "I1.fastq.gz", emit: I1_fastq_gz
    path "I2.fastq.gz", emit: I2_fastq_gz
    path "fastq1.fastq.gz", emit: fastq1_fastq_gz
    path "fastq2.fastq.gz", emit: fastq2_fastq_gz
    path "spec.yaml", emit: spec_yaml
  script:
  """
  echo $seqspec_raw_url
  if [ -z "$seqspec_raw_url" ]; then
    echo seqspec_raw_url file is not specified.
    touch spec.yaml
  else
    curl -Ls $seqspec_raw_url > spec.yaml
    echo finished download spec.yaml
  fi

  echo $idx1
  if [ -z "$idx1" ]; then
    echo idx1 file is not specified.
    touch I1.fastq.gz
  else
    curl -Ls $idx1 > I1.fastq.gz
    echo finished download I1.fastq.gz
  fi

  echo $idx2
  if [ -z "$idx2" ]; then
    echo idx2 file is not specified.
    touch I2.fastq.gz
  else
    curl -Ls $idx2 > I2.fastq.gz
    echo finished download I2.fastq.gz
  fi

  echo $fastq1
  if [ -z "$fastq1" ]; then
    echo fastq1 file is not specified.
    touch fastq1.fastq.gz
  else
    curl -Ls $fastq1 > fastq1.fastq.gz
    echo finished download fastq1.fastq.gz
  fi

  echo $fastq2
  if [ -z "$fastq2" ]; then
    echo fastq2 file is not specified.
    touch fastq2.fastq.gz
  else
    curl -Ls $fastq2 > fastq2.fastq.gz
    echo finished download fastq2.fastq.gz
  fi

  """
}

