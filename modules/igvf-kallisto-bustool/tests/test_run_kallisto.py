import pytest
import subprocess
from unittest.mock import patch
from click.testing import CliRunner
from run_kallisto import cli

@pytest.fixture
def runner():
    return CliRunner()

@patch('subprocess.run')
def test_index_standard(mock_subprocess_run, runner):
    mock_subprocess_run.return_value = subprocess.CompletedProcess(args=['kb ref'], returncode=0, stdout='Success', stderr='')

    result = runner.invoke(cli, [
        'index', 'standard',
        '--output_dir', 'test_output',
        '--genome-fasta', 'test_genome.fa',
        '--gtf', 'test_annotations.gtf'
    ])

    assert result.exit_code == 0
    assert 'Creating standard kallisto index in test_output.' in result.output
    assert 'Running command: kb ref -i test_output/index.idx -g test_output/t2g.txt -f1 test_output/transcriptome.fa  test_genome.fa test_annotations.gtf' in result.output
    assert 'Success' in result.output

@patch('subprocess.run')
def test_index_nac(mock_subprocess_run, runner):
    mock_subprocess_run.return_value = subprocess.CompletedProcess(args=['kb ref'], returncode=0, stdout='Success', stderr='')

    result = runner.invoke(cli, [
        'index', 'nac',
        '--output_dir', 'test_output',
        '--genome-fasta', 'test_genome.fa',
        '--gtf', 'test_annotations.gtf'
    ])

    assert result.exit_code == 0
    assert 'Creating nac kallisto index in test_output.' in result.output
    assert 'Running command: kb ref --workflow=nac -i test_output/index.idx -g test_output/t2g.txt -c1 ~test_output/cdna.txt -c2 ~test_output/nascent.txt -f1 ~test_output/cdna.fasta -f2 ~test_output/nascent.fasta ~test_genome.fa test_annotations.gtf' in result.output
    assert 'Success' in result.output

@patch('subprocess.run')
def test_quant_standard(mock_subprocess_run, runner):
    mock_subprocess_run.return_value = subprocess.CompletedProcess(args=['kb count'], returncode=0, stdout='Success', stderr='')

    result = runner.invoke(cli, [
        'quant', 'standard',
        '--index_dir', 'test_index',
        '--read_format', 'test_format',
        '--output_dir', 'test_output',
        '--strand', 'test_strand',
        '--threads', '4',
        '--barcode_onlist', 'test_barcode_onlist',
        'test_fastq1', 'test_fastq2'
    ])

    assert result.exit_code == 0
    assert 'Running command: kb count --workflow standard -i test_index -o test_output -x test_format -t 4 --barcode test_barcode_onlist --strand test_strand test_fastq1 test_fastq2' in result.output
    assert 'Success' in result.output

@patch('subprocess.run')
def test_quant_nac(mock_subprocess_run, runner):
    mock_subprocess_run.return_value = subprocess.CompletedProcess(args=['kb count'], returncode=0, stdout='Success', stderr='')

    result = runner.invoke(cli, [
        'quant', 'nac',
        '--index_dir', 'test_index',
        '--read_format', 'test_format',
        '--output_dir', 'test_output',
        '--strand', 'test_strand',
        '--threads', '4',
        '--barcode_onlist', 'test_barcode_onlist',
        'test_fastq1', 'test_fastq2'
    ])

    assert result.exit_code == 0
    assert 'Running command: kb count --workflow nac -i test_index -o test_output -x test_format -t 4 --barcode test_barcode_onlist --strand test_strand test_fastq1 test_fastq2' in result.output
    assert 'Success' in result.output