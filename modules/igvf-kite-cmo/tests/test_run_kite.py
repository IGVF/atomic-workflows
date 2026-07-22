import pytest
import subprocess
from unittest.mock import patch
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
        'index', 'kite',
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
        'index', 'kite',
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
        'quantify', 'kite',
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
