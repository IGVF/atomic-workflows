import csv
import gzip
import io
import pytest
import subprocess
from unittest.mock import patch, MagicMock
from click.testing import CliRunner
from run_kite import cli


@pytest.fixture
def runner():
    return CliRunner()


@patch('run_kite.run_shell_cmd')
def test_index_kite(mock_run_shell_cmd, runner, tmp_path):
    mock_run_shell_cmd.return_value = ""
    cmo_barcodes = tmp_path / "cmo_barcodes.tsv"
    cmo_barcodes.write_text("TTGTCACGGTAATTA\tCMO01\n")
    output_dir = tmp_path / "index_out"
    output_dir.mkdir()

    result = runner.invoke(cli, [
        'index',
        '--output_dir', str(output_dir),
        '--cmo_barcodes', str(cmo_barcodes),
    ])

    assert result.exit_code == 0, result.output
    assert mock_run_shell_cmd.call_count == 2
    kb_ref_cmd = mock_run_shell_cmd.call_args_list[0][0][0]
    assert 'kb ref' in kb_ref_cmd
    assert '--workflow kite' in kb_ref_cmd
    assert 'cmo.idx' in kb_ref_cmd
    assert 'cmo_t2g.txt' in kb_ref_cmd
    assert 'cmo_cdna.fa' in kb_ref_cmd


@patch('run_kite.run_shell_cmd')
def test_index_kite_with_temp_dir(mock_run_shell_cmd, runner, tmp_path):
    mock_run_shell_cmd.return_value = ""
    cmo_barcodes = tmp_path / "cmo_barcodes.tsv"
    cmo_barcodes.write_text("TTGTCACGGTAATTA\tCMO01\n")
    output_dir = tmp_path / "index_out"
    output_dir.mkdir()

    result = runner.invoke(cli, [
        'index',
        '--output_dir', str(output_dir),
        '--cmo_barcodes', str(cmo_barcodes),
        '--temp_dir', str(tmp_path),
    ])

    assert result.exit_code == 0, result.output
    kb_ref_cmd = mock_run_shell_cmd.call_args_list[0][0][0]
    assert f'--tmp {tmp_path}' in kb_ref_cmd


@patch('run_kite.run_shell_cmd')
def test_quantify_kite(mock_run_shell_cmd, runner, tmp_path):
    mock_run_shell_cmd.return_value = ""
    index_dir = tmp_path / "index"
    index_dir.mkdir()
    output_dir = tmp_path / "counts"
    output_dir.mkdir()
    onlist = tmp_path / "onlist.tsv"
    onlist.write_text("ACGT\n")
    r1 = tmp_path / "R1.fastq.gz"
    r1.write_text("")
    r2 = tmp_path / "R2.fastq.gz"
    r2.write_text("")

    result = runner.invoke(cli, [
        'quantify',
        '--index_dir', str(index_dir),
        '--output_dir', str(output_dir),
        '--barcode_onlist', str(onlist),
        str(r1), str(r2),
    ])

    assert result.exit_code == 0, result.output
    assert mock_run_shell_cmd.call_count == 2
    kb_count_cmd = mock_run_shell_cmd.call_args_list[0][0][0]
    assert 'kb count' in kb_count_cmd
    assert '--workflow kite' in kb_count_cmd
    assert 'cmo.idx' in kb_count_cmd
    assert '0,0,16:0,16,28:1,0,15' in kb_count_cmd
    assert '--h5ad' in kb_count_cmd


def _make_csv_gz(rows, fieldnames):
    buf = io.StringIO()
    writer = csv.DictWriter(buf, fieldnames=fieldnames)
    writer.writeheader()
    writer.writerows(rows)
    return gzip.compress(buf.getvalue().encode())


def test_prepare_barcodes_local_file(runner, tmp_path):
    csv_gz = tmp_path / "barcodes.csv.gz"
    rows = [
        {'sequence': 'TTGTCACGGTAATTA', 'name': 'CMO301'},
        {'sequence': 'CCGTGCCTAGCAAGT', 'name': 'CMO302'},
    ]
    csv_gz.write_bytes(_make_csv_gz(rows, ['sequence', 'name']))
    output = tmp_path / "out.tsv.gz"

    result = runner.invoke(cli, [
        'prepare-barcodes',
        '--input', str(csv_gz),
        '--output', str(output),
    ])

    assert result.exit_code == 0, result.output
    with gzip.open(output, 'rt') as fh:
        lines = fh.read().splitlines()
    assert lines == ['TTGTCACGGTAATTA\tCMO301', 'CCGTGCCTAGCAAGT\tCMO302']


@patch('run_kite.igvf_session')
@patch('run_kite.download_igvf_tabular_file')
def test_prepare_barcodes_accession(mock_download, mock_session, runner, tmp_path):
    rows = [{'sequence': 'TTGTCACGGTAATTA', 'name': 'CMO301'}]
    mock_download.return_value = _make_csv_gz(rows, ['sequence', 'name'])
    mock_session.return_value = MagicMock()
    output = tmp_path / "out.tsv.gz"

    result = runner.invoke(cli, [
        'prepare-barcodes',
        '--accession', 'IGVFFI9308MNHO',
        '--output', str(output),
    ])

    assert result.exit_code == 0, result.output
    mock_download.assert_called_once()
    with gzip.open(output, 'rt') as fh:
        lines = fh.read().splitlines()
    assert lines == ['TTGTCACGGTAATTA\tCMO301']


def test_prepare_barcodes_custom_columns(runner, tmp_path):
    csv_gz = tmp_path / "barcodes.csv.gz"
    rows = [{'seq': 'TTGTCACGGTAATTA', 'label': 'CMO301'}]
    csv_gz.write_bytes(_make_csv_gz(rows, ['seq', 'label']))
    output = tmp_path / "out.tsv.gz"

    result = runner.invoke(cli, [
        'prepare-barcodes',
        '--input', str(csv_gz),
        '--sequence-col', 'seq',
        '--name-col', 'label',
        '--output', str(output),
    ])

    assert result.exit_code == 0, result.output
    with gzip.open(output, 'rt') as fh:
        lines = fh.read().splitlines()
    assert lines == ['TTGTCACGGTAATTA\tCMO301']


def test_prepare_barcodes_missing_column(runner, tmp_path):
    csv_gz = tmp_path / "barcodes.csv.gz"
    rows = [{'sequence': 'TTGTCACGGTAATTA', 'name': 'CMO301'}]
    csv_gz.write_bytes(_make_csv_gz(rows, ['sequence', 'name']))
    output = tmp_path / "out.tsv.gz"

    result = runner.invoke(cli, [
        'prepare-barcodes',
        '--input', str(csv_gz),
        '--name-col', 'label',
        '--output', str(output),
    ])

    assert result.exit_code != 0
    assert 'label' in result.output


def test_prepare_barcodes_mutual_exclusion(runner, tmp_path):
    output = tmp_path / "out.tsv.gz"

    result = runner.invoke(cli, ['prepare-barcodes', '--output', str(output)])
    assert result.exit_code != 0

    csv_gz = tmp_path / "f.csv.gz"
    csv_gz.write_bytes(_make_csv_gz([], ['sequence', 'name']))
    result = runner.invoke(cli, [
        'prepare-barcodes',
        '--accession', 'IGVFFI9308MNHO',
        '--input', str(csv_gz),
        '--output', str(output),
    ])
    assert result.exit_code != 0
