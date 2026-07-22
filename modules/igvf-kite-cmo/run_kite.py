import csv
import gzip
import io
import click
import logging
import os
import requests
import signal
import subprocess
import sys
from dotenv import find_dotenv, load_dotenv

# Configure logging
logging.basicConfig(stream=sys.stderr, level=logging.INFO)

IGVF_API_BASE = "https://api.data.igvf.org"


def igvf_session():
    load_dotenv(find_dotenv(usecwd=True))
    session = requests.Session()
    key = os.environ.get("IGVF_API_KEY")
    secret = os.environ.get("IGVF_SECRET_KEY")
    if key and secret:
        session.auth = (key, secret)
    return session


def download_igvf_tabular_file(accession, session):
    url = f"{IGVF_API_BASE}/tabular-files/{accession}/@@download/{accession}.csv.gz"
    logging.info(f"Downloading {accession} from {url}")
    resp = session.get(url, stream=True, allow_redirects=True)
    resp.raise_for_status()
    return resp.content


def run_shell_cmd(cmd):
    p = subprocess.Popen(
        ['/bin/bash', '-o', 'pipefail'],
        stdin=subprocess.PIPE,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        universal_newlines=True,
        preexec_fn=os.setsid)
    pid = p.pid
    pgid = os.getpgid(pid)
    logging.info('run_shell_cmd: PID={}, PGID={}, CMD={}'.format(pid, pgid, cmd))
    stdout, stderr = p.communicate(cmd)
    rc = p.returncode
    err_str = (
        'PID={pid}, PGID={pgid}, RC={rc}'
        'STDERR={stde}\nSTDOUT={stdo}'
    ).format(
        pid=pid, pgid=pgid, rc=rc, stde=stderr.strip(), stdo=stdout.strip()
    )
    if rc:
        try:
            os.killpg(pgid, signal.SIGKILL)
        except Exception:
            pass
        finally:
            raise Exception(err_str)
    else:
        logging.info(err_str)
    return stdout.strip('\n')


@click.group()
@click.version_option(package_name="igvf-kite-cmo")
def cli():
    """KITE CMO quantification pipeline.

    Runs the kb-python KITE workflow to quantify Cell Multiplexing Oligo (CMO)
    tags per cell barcode for 10x Genomics multiome experiments.
    """
    pass


@cli.command("index")
@click.option('--output_dir', type=click.Path(exists=True), required=True,
              help='Directory where index files will be saved.')
@click.option('--cmo_barcodes', type=click.Path(exists=True), required=True,
              help='CMO barcode TSV file (two columns: sequence, name; no header).')
@click.option('--temp_dir', type=str, required=False, default=None,
              help='Path to a temporary directory.')
def index(output_dir, cmo_barcodes, temp_dir):
    """
    Creates the kb KITE index from a CMO barcode TSV and archives the output.

    Args:
        output_dir (str): Directory where index files will be saved.
        cmo_barcodes (str): CMO barcode TSV (sequence\\tname, no header).
        temp_dir (str): Optional temporary directory.

    Returns:
        {output_dir}.tar.gz: Tarball containing the kite index files.
    """
    logging.info(f"Creating KITE index in {output_dir}.")
    temp_dir_param = f"--tmp {temp_dir}" if temp_dir else ""
    cmd = (
        f"kb ref {temp_dir_param} --workflow kite "
        f"-i {output_dir}/cmo.idx "
        f"-g {output_dir}/cmo_t2g.txt "
        f"-f1 {output_dir}/cmo_cdna.fa "
        f"{cmo_barcodes}"
    )
    run_shell_cmd(cmd)

    archive_cmd = f"tar -zcvf {output_dir}.tar.gz -C {output_dir} ."
    run_shell_cmd(archive_cmd)
    logging.info(f"Index archive created: {output_dir}.tar.gz")


@cli.command("quantify")
@click.option('--index_dir', type=click.Path(exists=True), required=True,
              help='Directory containing the KITE index files (cmo.idx, cmo_t2g.txt).')
@click.option('--output_dir', type=click.Path(exists=True), required=True,
              help='Directory where kb count output files will be saved.')
@click.option('--barcode_onlist', type=click.Path(exists=True), required=True,
              help='Cell barcode whitelist (.tsv or .tsv.gz).')
@click.option('--read_format', type=str, required=False, default='0,0,16:0,16,28:1,0,15',
              help='kb technology string (CB:UMI:cDNA positions). Default: 0,0,16:0,16,28:1,0,15.')
@click.option('--threads', type=int, default=8,
              help='Number of threads. Default: 8.')
@click.option('--memory', type=str, default='4G',
              help='Memory limit for bustools sort. Default: 4G.')
@click.option('--temp_dir', type=str, required=False, default=None,
              help='Path to a temporary directory.')
@click.argument('fastqs', nargs=2, type=str, required=True)
def quantify(index_dir, output_dir, barcode_onlist, read_format, threads, memory, temp_dir, fastqs):
    """
    Runs the KITE CMO quantification pipeline.

    Expects two positional FASTQ arguments: R1 (trimmed, 28 bp) then R2.

    Args:
        index_dir (str): Directory with cmo.idx and cmo_t2g.txt.
        output_dir (str): Output directory for kb count results.
        barcode_onlist (str): Cell barcode whitelist file.
        read_format (str): kb technology string (CB:UMI positions).
        threads (int): Number of threads.
        memory (str): Memory limit for bustools sort.
        temp_dir (str): Optional temporary directory.
        fastqs (tuple): R1 and R2 FASTQ paths (trimmed R1 first).

    Returns:
        {output_dir}/counts_unfiltered/adata.h5ad: Unfiltered CMO counts in h5ad format.
        {output_dir}.tar.gz: Tarball of the full output directory.
    """
    r1, r2 = fastqs
    logging.info(f"Running KITE quantification. R1={r1}, R2={r2}, output={output_dir}.")
    temp_dir_param = f"--tmp {temp_dir}" if temp_dir else ""
    cmd = (
        f"kb count --workflow kite {temp_dir_param} "
        f"-i {index_dir}/cmo.idx "
        f"-g {index_dir}/cmo_t2g.txt "
        f"-x {read_format} "
        f"-w {barcode_onlist} "
        f"--h5ad "
        f"-t {threads} "
        f"-m {memory} "
        f"-o {output_dir} "
        f"{r1} {r2}"
    )
    logging.info(f"Running command: {cmd}")
    run_shell_cmd(cmd)

    archive_cmd = f"tar -zcvf {output_dir}.tar.gz {output_dir}"
    logging.info(f"Running archive command: {archive_cmd}")
    run_shell_cmd(archive_cmd)
    logging.info(f"Done. Results: {output_dir}")


@cli.command("prepare-barcodes")
@click.option('--accession', type=str, default=None,
              help='IGVF file accession (e.g. IGVFFI9308MNHO). Downloads the CSV.gz from the IGVF portal.')
@click.option('--input', 'input_file', type=click.Path(exists=True), default=None,
              help='Local CSV or CSV.gz file to use instead of downloading from IGVF.')
@click.option('--sequence-col', type=str, default='multiseq_bc',
              help='Column name for the CMO barcode sequence. Default: multiseq_bc.')
@click.option('--name-col', type=str, default='CMO ID',
              help='Column name for the CMO label. Default: CMO ID.')
@click.option('--output', type=str, required=True,
              help='Output path for the gzipped two-column TSV (sequence\\tname, no header).')
def prepare_barcodes(accession, input_file, sequence_col, name_col, output):
    """
    Converts a CMO barcode CSV (from IGVF or a local file) to a gzipped two-column TSV
    for use with the KITE index command.

    Exactly one of --accession or --input must be provided.

    Args:
        accession (str): IGVF file accession for the CMO barcode CSV.
        input_file (str): Local CSV or CSV.gz path.
        sequence_col (str): Column name for barcode sequences (IGVF: multiseq_bc).
        name_col (str): Column name for barcode labels (IGVF: CMO ID).
        output (str): Output .tsv.gz path.

    Returns:
        output: Gzipped TSV with columns (sequence, name), no header.
    """
    if (accession is None) == (input_file is None):
        raise click.UsageError("Provide exactly one of --accession or --input.")

    if accession:
        session = igvf_session()
        raw = download_igvf_tabular_file(accession, session)
    else:
        with open(input_file, 'rb') as fh:
            raw = fh.read()

    text = gzip.decompress(raw).decode() if raw[:2] == b'\x1f\x8b' else raw.decode()

    reader = csv.DictReader(io.StringIO(text))
    fieldnames = reader.fieldnames or []
    if sequence_col not in fieldnames:
        raise click.ClickException(
            f"Column '{sequence_col}' not found. Available columns: {fieldnames}"
        )
    if name_col not in fieldnames:
        raise click.ClickException(
            f"Column '{name_col}' not found. Available columns: {fieldnames}"
        )

    rows = [(row[sequence_col], row[name_col]) for row in reader]
    logging.info(f"Writing {len(rows)} barcodes to {output}")

    with gzip.open(output, 'wt') as out:
        for seq, name in rows:
            out.write(f"{seq}\t{name}\n")

    logging.info(f"Done. Barcode file written to {output}")


if __name__ == "__main__":
    cli()
