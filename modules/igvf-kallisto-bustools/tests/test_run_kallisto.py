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
        '--output_dir', 'tests/data/expected_output',
        '--genome-fasta', '/software/test_data/genome/IGVFFI7254HLWI_chr19.fasta.gz',
        '--gtf', '/software/test_data/gtf/IGVFFI5842FWGQ_chr19.gtf.gz'
    ])

    assert result.exit_code == 0
    assert 'Creating standard kallisto index in tests/data/expected_output.' in result.output
    assert 'Running command: kb ref -i tests/data/expected_output/index.idx -g tests/data/expected_output/t2g.txt -f1 tests/data/expected_output/transcriptome.fa  /software/test_data/genome/IGVFFI7254HLWI_chr19.fasta.gz /software/test_data/gtf/IGVFFI5842FWGQ_chr19.gtf.gz' in result.output
    assert 'Success' in result.output


@patch('subprocess.run')
def test_index_nac(mock_subprocess_run, runner):
    mock_subprocess_run.return_value = subprocess.CompletedProcess(args=['kb ref'], returncode=0, stdout='Success', stderr='')

    result = runner.invoke(cli, [
        'index', 'nac',
        '--output_dir', 'tests/data/expected_output',
        '--genome-fasta', '/software/test_data/genome/IGVFFI7254HLWI_chr19.fasta.gz',
        '--gtf', '/software/test_data/gtf/IGVFFI5842FWGQ_chr19.gtf.gz'
    ])

    assert result.exit_code == 0
    assert 'Creating nac kallisto index in tests/data/expected_output.' in result.output
    assert 'Running command: kb ref --workflow=nac -i tests/data/expected_output/index.idx -g tests/data/expected_output/t2g.txt -c1 ~tests/data/expected_output/cdna.txt -c2 ~tests/data/expected_output/nascent.txt -f1 ~tests/data/expected_output/cdna.fasta -f2 ~tests/data/expected_output/nascent.fasta /software/test_data/genome/IGVFFI7254HLWI_chr19.fasta.gz /software/test_data/gtf/IGVFFI5842FWGQ_chr19.gtf.gz' in result.output
    assert 'Success' in result.output


@patch('subprocess.run')
def test_quant_standard(mock_subprocess_run, runner):
    mock_subprocess_run.return_value = subprocess.CompletedProcess(args=['kb count'], returncode=0, stdout='Success', stderr='')

    result = runner.invoke(cli, [
        'quant', 'standard',
        '--index_dir', 'tests/data/expected_output',
        '--read_format', 'test_format',
        '--output_dir', 'tests/data/expected_output',
        '--strand', 'test_strand',
        '--threads', '4',
        '--barcode_onlist', 'tests/data/test_barcode_onlist',
        'tests/data/test_fastq1', 'tests/data/test_fastq2'
    ])

    assert result.exit_code == 0
    assert 'Running command: kb count --workflow standard -i tests/data/expected_output -o tests/data/expected_output -x test_format -t 4 --barcode tests/data/test_barcode_onlist --strand test_strand tests/data/test_fastq1 tests/data/test_fastq2' in result.output
    assert 'Success' in result.output