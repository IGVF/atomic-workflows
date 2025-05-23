import click
import gzip
import h5py
import logging
import numpy as np
import os
import shutil
import signal
import sys
import subprocess

# Configure logging
logging.basicConfig(stream=sys.stderr, level=logging.INFO)


def run_shell_cmd(cmd):
    p = subprocess.Popen(
        ['/bin/bash', '-o', 'pipefail'],  # to catch error in pipe
        stdin=subprocess.PIPE,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        universal_newlines=True,
        preexec_fn=os.setsid)  # to make a new process with a new PGID
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
        # kill all child processes
        try:
            os.killpg(pgid, signal.SIGKILL)
        except Exception:
            pass
        finally:
            raise Exception(err_str)
    else:
        logging.info(err_str)
    return stdout.strip('\n')


def check_and_unzip(file_path):
    """
    Checks if a file is gzipped and unzips it if necessary.

    Parameters:
    file_path (str): Path to the file to check and unzip.

    Returns:
    str: Path to the unzipped file.
    """
    if file_path.endswith('.gz'):
        file_name = file_path.split('/')[-1]
        unzipped_file_path = file_name[:-3]  # Remove the .gz extension
        with gzip.open(file_path, 'rb') as f_in:
            with open(unzipped_file_path, 'wb') as f_out:
                shutil.copyfileobj(f_in, f_out)
        return unzipped_file_path
    return file_path


def append_suffix_to_h5ad(h5ad_file, suffix):
    suffix = (f"_{suffix}").encode("utf-8")
    # Open the h5ad file for modification
    with h5py.File(h5ad_file, "r+") as h5file:
        # Access the dataset containing the list of byte strings
        dataset = h5file["/obs/barcode"]

        # Convert the dataset to regular Python strings, append the suffix, and convert back to bytes
        dataset[:] = np.array([item.decode('utf-8') + suffix.decode("utf-8") for item in dataset], dtype='S')

        # Save the modified dataset
        h5file.flush()



@click.group()
@click.version_option(package_name="igvf-kallisto-bustools")
def cli():
    """Kallisto and bustools

    This script runs the kallisto and bustools pipeline.
    You can run the quantification step or the index creation step.
    """
    pass


# Index sub-command
@cli.group("index")
def index():
    """Manages the index creation step."""
    pass

@index.command("nac")
@click.option('--temp_dir', type=str, help='Path to the temp directory.', required=False, default=None)
@click.option('--output_dir', type=click.Path(exists=True), help='Path to the output directory.', required=True)
@click.option('--genome_fasta', type=click.Path(exists=True), help='Path to the genome fasta file.', required=True)
@click.option('--gtf', type=click.Path(exists=True), help='Path to the GTF file.', required=True)
def index_nac(output_dir, temp_dir, genome_fasta, gtf):
    """
    Creates the kallisto reference index for nac analysis and archives the output directory.

    Args:
        temp_dir (str): Path to the temp directory.
        output_dir (str): The directory where the kallisto index and related files will be created.
        genome_fasta (str): The path to the genome FASTA file.
        gtf (str): The path to the GTF file.

    Returns:
        {output_dir}.tar.gz (File): A tarball of the output directory containing all the indexes.
    """
    logging.info(f"Creating nac kallisto index in {output_dir}.")
    temp_dir_param = f"--tmp {temp_dir}" if temp_dir else ""
    # Create the command line string and run it using subprocess
    cmd = f"kb ref {temp_dir_param} --workflow=nac -i {output_dir}/index.idx -g {output_dir}/t2g.txt -c1 {output_dir}/cdna.txt -c2 {output_dir}/nascent.txt -f1 {output_dir}/cdna.fasta -f2 {output_dir}/nascent.fasta {genome_fasta} {gtf}"
    run_shell_cmd(cmd)
    
    # Archive the directory
    archive_cmd = f"tar --exclude='*.fasta' -zcvf {output_dir}.tar.gz -C {output_dir} ."
    run_shell_cmd(archive_cmd)


# Quantification sub-command
@cli.group("quantify")
def quantify():
    """Manages the quantification step."""
    pass

@quantify.command("nac")
@click.option('--temp_dir', type=str, help='Path to the temp directory.', required=False, default=None)
@click.option('--index_dir', type=click.Path(exists=True), help='Path to the index directory.', required=True)
@click.option('--read_format', type=str, help='String indicating the position of umi and barcode.', required=True)
@click.option('--output_dir', type=click.Path(exists=True), help='Path to the output directory.', required=True)
@click.option('--strand', type=str, help='Library strand orientation.', required=True)
@click.option('--subpool', type=str, help='Subpool ID string to append to the barcode.', required=False, default=None)
@click.option('--threads', default=1, type=int, help='Number of threads to use. Default is 1.')
@click.option('--barcode_onlist', type=click.Path(exists=True), help='Barcode onlist file.', required=True)
@click.option('--replacement_list', type=click.Path(exists=True), help='Replacement list file.')
@click.argument('interleaved_fastqs', nargs=-1, type=str, required=True)
def quantify_nac(temp_dir, index_dir, read_format, output_dir, strand, subpool, threads, barcode_onlist, replacement_list, interleaved_fastqs):
    """
    Runs the nac quantification pipeline using kallisto and bustools.

    Parameters:
        temp_dir (str): Path to the temp directory.
        index_dir (Path): Directory containing the kallisto index and transcript-to-gene mapping files.
        read_format (str): Format of the reads.
        output_dir (Path): Directory where the output files will be saved.
        strand (str): Strand specificity (e.g., 'unstranded', 'forward', 'reverse').
        subpool (str): Subpool ID string to append to the barcode.
        threads (int): Number of threads to use for the computation.
        barcode_onlist (File): Path to the whitelist of barcodes.
        replacement_list (File): Path to the replacement list file.
        interleaved_fastqs (File): Path to the interleaved FASTQ files. The files need to be supplied in interleaved format(Example: pairA_1.fastq pairA_2.fastq pairB_1.fastq pairB_2.fastq).

    Returns:
        Please refer to the kallisto and bustools documentation for the output files.
    """
    logging.info("Running nac quantification pipeline.")
    # Create the command line string and run it using subprocess
    temp_dir_param = f"--tmp {temp_dir}" if temp_dir else ""
    replacement_list_param = f"-r {replacement_list}" if replacement_list else ""
    h5ad_location_suffix = f"_modified" if replacement_list else ""
    interleaved_fastqs_str = " ".join(interleaved_fastqs)
    cmd = f"kb count --workflow=nac {temp_dir_param} -i {index_dir}/index.idx -g {index_dir}/t2g.txt -c1 {index_dir}/cdna.txt -c2 {index_dir}/nascent.txt --sum=total -x {read_format} -w {barcode_onlist} {replacement_list_param} --strand {strand} -o {output_dir} --h5ad -t {threads} {interleaved_fastqs_str}"
    logging.info(f"Running command: {cmd}")
    run_shell_cmd(cmd)

    # Append the subpool to the barcodes in the h5ad file
    if subpool:
        h5ad_file = f"{output_dir}/counts_unfiltered{h5ad_location_suffix}/adata.h5ad"
        append_suffix_to_h5ad(h5ad_file, subpool)
        logging.info(f"Appended subpool '{subpool}' to barcodes in {h5ad_file}.")
        cmd = f"sed -i 's/$/_{subpool}/' {output_dir}/counts_unfiltered{h5ad_location_suffix}/cells_x_genes.barcodes.txt"
        logging.info(f"Running command: {cmd}")
        try:
            result = subprocess.run(cmd, shell=True, capture_output=True, text=True, check=True)
            logging.info(f"Command output: {result.stdout}")
        except subprocess.CalledProcessError as e:
            logging.error(f"Command failed with error: {e.stderr}")

    # Rename the h5ad file
    cmd = f"mv {output_dir}/counts_unfiltered{h5ad_location_suffix}/adata.h5ad {output_dir}.h5ad"
    logging.info(f"Running command: {cmd}")
    try:
        result = subprocess.run(cmd, shell=True, capture_output=True, text=True, check=True)
        logging.info(f"Command output: {result.stdout}")
    except subprocess.CalledProcessError as e:
        logging.error(f"Command failed with error: {e.stderr}")

    # Archive the directory
    archive_cmd = f"tar -zcvf {output_dir}.tar.gz {output_dir} -C /software README.md "
    logging.info(f"Running archive command: {archive_cmd}")
    try:
        result = subprocess.run(archive_cmd, shell=True, capture_output=True, text=True, check=True)
        logging.info(f"Archive command output: {result.stdout}")
    except subprocess.CalledProcessError as e:
        logging.error(f"Archive command failed with error: {e.stderr}")

