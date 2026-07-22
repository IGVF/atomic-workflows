import click
import logging
import os
import signal
import subprocess
import sys

# Configure logging
logging.basicConfig(stream=sys.stderr, level=logging.INFO)


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


# Index sub-command
@cli.group("index")
def index():
    """Manages the KITE index creation step."""
    pass


@index.command("kite")
@click.option('--output_dir', type=click.Path(exists=True), required=True,
              help='Directory where index files will be saved.')
@click.option('--cmo_barcodes', type=click.Path(exists=True), required=True,
              help='CMO barcode TSV file (two columns: sequence, name; no header).')
@click.option('--temp_dir', type=str, required=False, default=None,
              help='Path to a temporary directory.')
def index_kite(output_dir, cmo_barcodes, temp_dir):
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


# Quantification sub-command
@cli.group("quantify")
def quantify():
    """Manages the KITE quantification step."""
    pass


@quantify.command("kite")
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
def quantify_kite(index_dir, output_dir, barcode_onlist, read_format, threads, memory, temp_dir, fastqs):
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
