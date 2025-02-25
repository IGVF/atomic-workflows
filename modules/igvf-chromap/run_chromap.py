import click
import csv
import gzip
import logging
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


def process_fragments(subpool, fragments_file):
    temp_file = "temp_fragments.tsv"
    with open(fragments_file, 'r', newline='') as infile, open(temp_file, 'w', newline='') as outfile:
        reader = csv.reader(infile, delimiter='\t')  # Read as tab-separated values
        writer = csv.writer(outfile, delimiter='\t')

        for row in reader:
            if len(row) >= 4:  # Ensure at least 4 columns exist
                row[3] = f"{row[3]}_{subpool}"  # Modify the 4th column (index 3)
            writer.writerow(row)  # Write the modified row

    shutil.move(temp_file, fragments_file)  # Replace the original file with the modified file
    return


def process_summary(subpool, barcode_log):
    temp_file = "temp_summary.csv"
    with open(barcode_log, 'r', newline='') as infile, open(temp_file, 'w', newline='') as outfile:
        reader = csv.reader(infile)
        writer = csv.writer(outfile)

        for i, row in enumerate(reader):
            if i == 0:
                writer.writerow(row)  # Write header as is
            else:
                row[0] = f"{row[0]}_{subpool}"  # Append subpool to the first column
                writer.writerow(row)  # Write the modified row

    shutil.move(temp_file, barcode_log)  # Replace the original file with the modified file
    return

@click.group()
@click.version_option(package_name="igvf-chromap")
def cli():
    """Chromap

    This script runs the chromap pipeline.
    You can run the alignment step or the index creation step.
    """
    pass


# Index sub-command
@cli.command("index")

@click.option('--output_dir', type=click.Path(exists=True), help='Path to the output directory.', required=True)
@click.option('--genome_fasta', type=click.Path(exists=True), help='Path to the genome fasta file.', required=True)
def index_nac(output_dir, genome_fasta):
    """
    Creates the chromap reference index and archives the output directory.

    Args:
        output_dir (str): The directory where the chromap index and related files will be created.
        genome_fasta (str): The path to the genome FASTA file.

    Returns:
        {output_dir}.tar.gz (File): A tarball of the output directory containing all the indexes.
    """
    logging.info(f"Creating  chromap index in {output_dir}.")
    genome_fasta = check_and_unzip(genome_fasta)
    # Create the command line string and run it using subprocess
    cmd = f"chromap -i -r {genome_fasta} -o {output_dir}/index"
    run_shell_cmd(cmd)
    
    # Archive the directory
    archive_cmd = f"tar -kzcvf {output_dir}.tar.gz {output_dir}"
    logging.info(f"Running archive command: {archive_cmd}")
    try:
        result = subprocess.run(archive_cmd, shell=True, capture_output=True, text=True, check=True)
        logging.info(f"Archive command output: {result.stdout}")
    except subprocess.CalledProcessError as e:
        logging.error(f"Archive command failed with error: {e.stderr}")


# Alignment sub-command
@cli.command("align")

@click.option('--index_dir', type=click.Path(exists=True), help='Path to the index directory.', required=True)
@click.option('--read_format', type=str, help='String indicating the position and the file containing the barcode.', required=True)
@click.option('--reference_fasta', type=click.Path(exists=True), help='Path to the reference fasta file.', required=True)
@click.option('--prefix', type=str, help='Path to the output directory.', required=False, default="output")
@click.option('--subpool', type=str, help='Subpool ID string to append to the barcode.', required=False, default=None)
@click.option('--threads', default=1, type=int, help='Number of threads to use. Default is 1.')
@click.option('--barcode_onlist', type=click.Path(exists=True), help='Barcode onlist file.', required=True)
@click.option('--barcode_translate', type=click.Path(exists=True), help='Barcode conversion file for 10x.', required=True)
@click.option('--read1', type=str, default=None, help='FASTQ read1.', required=True)
@click.option('--read2', type=str, default=None, help='FASTQ read2.', required=True)
@click.option('--read_barcode', type=str, default=None, help='FASTQ barcode.')
def align(index_dir, read_format, reference_fasta, prefix, subpool, threads, barcode_onlist, barcode_translate, read1, read2, read_barcode):
    """
    Aligns reads to the reference using chromap and generates a fragments file.

    Parameters:
        index_dir (Path): Directory containing the chromap.
        read_format (str): Format of the reads.
        reference_fasta (Path): Path to the reference fasta file.
        prefix (str): Prefix for the output files.
        subpool (str): Subpool ID string to append to the barcode.
        threads (int): Number of threads to use for the computation.
        barcode_onlist (File): Path to the whitelist of barcodes.
        barcode_translate (File): Path to the barcode translation file for 10x data.
        read1 (File): Path to the FASTQ file containing read 1.
        read2 (File): Path to the FASTQ file containing read 2.
        read_barcode (File): Path to the FASTQ file containing the barcode.

    Returns:
        Please refer to the chromap documentation for the output files.
    """
    logging.info("Running alignment.")
    # Create the command line string and run it using subprocess
    barcode_translate_param = f"--barcode-translate {barcode_translate}" if barcode_translate else ""

    cmd = f"chromap -x {index_dir}/index --read-format {read_format} -r {reference_fasta} --remove-pcr-duplicates --remove-pcr-duplicates-at-cell-level --trim-adapters --low-mem --BED -l 2000 --bc-error-threshold 1 -t {threads} --bc-probability-threshold 0.90 -q 30 --barcode-whitelist {barcode_onlist} {barcode_translate_param} -o {prefix}.fragments.tsv --summary {prefix}.barcode.summary.csv -1 {read1} -2 {read2} -b {read_barcode} > {prefix}.log.txt 2>&1"
    run_shell_cmd(cmd)

    # Append the subpool to the barcodes in the fragment file.
    if subpool:
        process_fragments(subpool, f"{prefix}.fragments.tsv")
        process_summary(subpool, f"{prefix}.barcode.summary.csv")


    # Compress the fragments file and create an index using tabix
    bgzip_cmd = f"bgzip -c {prefix}.fragments.tsv > {prefix}.fragments.tsv.gz"
    logging.info(f"Running bgzip command: {bgzip_cmd}")
    try:
        result = subprocess.run(bgzip_cmd, shell=True, capture_output=True, text=True, check=True)
        logging.info(f"bgzip command output: {result.stdout}")
    except subprocess.CalledProcessError as e:
        logging.error(f"bgzip command failed with error: {e.stderr}")

    tabix_cmd = f"tabix --zero-based --preset bed {prefix}.fragments.tsv.gz"
    logging.info(f"Running tabix command: {tabix_cmd}")
    try:
        result = subprocess.run(tabix_cmd, shell=True, capture_output=True, text=True, check=True)
        logging.info(f"tabix command output: {result.stdout}")
    except subprocess.CalledProcessError as e:
        logging.error(f"tabix command failed with error: {e.stderr}")
