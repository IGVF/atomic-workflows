import click
import logging
import sys
import subprocess

# Configure logging
logging.basicConfig(stream=sys.stderr, level=logging.INFO)


@click.group()
@click.version_option(package_name="igvf-kallisto-bustools")
def cli():
    """Kallisto and bustools
    
    This script runs the kallisto and bustools pipeline.
    You can run the quantification step or the index creation step.
    """


# Index sub-command
@cli.group("index")
def index():
    """Manages the index creation step."""

@index.command("standard")
@click.option('--output_dir', type=click.Path(exists=True), help='Path to the output directory.', required=True)
@click.option('--genome-fasta', type=click.Path(exists=True), help='Path to the genome fasta file.', required=True)
@click.option('--gtf', type=click.Path(exists=True), help='Path to the GTF file.', required=True)
def index_standard(output_dir, genome_fasta, gtf):
    """
    Creates the kallisto reference index for standard analysis and archives the output directory.

    Args:
        output_dir (Path): The directory where the kallisto index and related files will be created.
        genome_fasta (File): The path to the genome FASTA file.
        gtf (File): The path to the GTF file.

    Returns:
        {output_dir}.tar.gz: A tarball of the output directory containing all the indexes.
    """
    logging.info(f"Creating standard kallisto index in {output_dir}.")
    # Create the command line string and run it using subprocess
    cmd = f"kb ref -i {output_dir}/index.idx -g {output_dir}/t2g.txt -f1 {output_dir}/transcriptome.fa  {genome_fasta} {gtf}"
    logging.info(f"Running command: {cmd}")
    try:
        result = subprocess.run(cmd, shell=True, capture_output=True, text=True, check=True)
        logging.info(f"Command output: {result.stdout}")
    except subprocess.CalledProcessError as e:
        logging.error(f"Command failed with error: {e.stderr}")

    # Archive the directory
    archive_cmd = f"tar -kzcvf {output_dir}.tar.gz {output_dir}"
    logging.info(f"Running archive command: {archive_cmd}")
    try:
        result = subprocess.run(archive_cmd, shell=True, capture_output=True, text=True, check=True)
        logging.info(f"Archive command output: {result.stdout}")
    except subprocess.CalledProcessError as e:
        logging.error(f"Archive command failed with error: {e.stderr}")


@index.command("nac")
@click.option('--output_dir', type=click.Path(exists=True), help='Path to the output directory.', required=True)
@click.option('--genome-fasta', type=click.Path(exists=True), help='Path to the genome fasta file.', required=True)
@click.option('--gtf', type=click.Path(exists=True), help='Path to the GTF file.', required=True)
def index_nac(output_dir, genome_fasta, gtf):
    """
    Creates the kallisto reference index for nac analysis and archives the output directory.

    Args:
        output_dir (str): The directory where the kallisto index and related files will be created.
        genome_fasta (str): The path to the genome FASTA file.
        gtf (str): The path to the GTF file.

    Returns:
        {output_dir}.tar.gz (File): A tarball of the output directory containing all the indexes.
    """
    logging.info(f"Creating nac kallisto index in {output_dir}.")
    # Create the command line string and run it using subprocess
    cmd = f"kb ref --workflow=nac -i {output_dir}/index.idx -g {output_dir}/t2g.txt -c1 ~{output_dir}/cdna.txt -c2 ~{output_dir}/nascent.txt -f1 ~{output_dir}/cdna.fasta -f2 ~{output_dir}/nascent.fasta ~{genome_fasta} {gtf}"
    logging.info(f"Running command: {cmd}")
    try:
        result = subprocess.run(cmd, shell=True, capture_output=True, text=True, check=True)
        logging.info(f"Command output: {result.stdout}")
    except subprocess.CalledProcessError as e:
        logging.error(f"Command failed with error: {e.stderr}")   
    # Archive the directory
    archive_cmd = f"tar -kzcvf {output_dir}.tar.gz {output_dir}"
    logging.info(f"Running archive command: {archive_cmd}")
    try:
        result = subprocess.run(archive_cmd, shell=True, capture_output=True, text=True, check=True)
        logging.info(f"Archive command output: {result.stdout}")
    except subprocess.CalledProcessError as e:
        logging.error(f"Archive command failed with error: {e.stderr}")


# Quantification sub-command
@cli.group("quant")
def quant():
    """Manages the quantification step."""


@quant.command("standard")
@click.option('--index_dir', type=click.Path(exists=True), help='Path to the index directory.', required=True)
@click.option('--read_format', type=str, help='String indicating the position of umi and barcode.', required=True)
@click.option('--output_dir', type=click.Path(exists=True), help='Path to the output directory.', required=True)
@click.option('--strand', type=str, help='Library strand orientation.', required=True)
@click.option('--threads', default=1, type=int, help='Number of threads to use. Default is 1.')
@click.option('--barcode_onlist', type=click.Path(exists=True), help='Barcode onlist file.', required=True)
@click.option('--replacement_list', type=click.Path(exists=True), help='Replacement list file.')
@click.argument('interleaved_fastqs', nargs=-1, type=click.Path(exists=True), help='FASTQ files to align. The file needs to be supply in interleaved format(Example: pairA_1.fastq pairA_2.fastq pairB_1.fastq pairB_2.fastq).')
def quant_standard(index_dir, read_format, output_dir, strand, threads, barcode_onlist, interleaved_fastqs, replacement_list):
    """
    Runs the standard quantification pipeline using kallisto and bustools.

    Parameters:
    index_dir (Path): Directory containing the kallisto index and transcript-to-gene mapping files.
    read_format (str): Format of the reads (e.g., '10xv2', '10xv3').
    output_dir (Path): Directory where the output files will be saved.
    strand (str): Strand specificity (e.g., 'unstranded', 'forward', 'reverse').
    threads (int): Number of threads to use for the computation.
    barcode_onlist (File): Path to the whitelist of barcodes.
    replacement_list (File): Path to the replacement list file.
    interleaved_fastqs (File): Path to the interleaved FASTQ files.

    Returns:
    Please refer to the kallisto and bustools documentation for the output files.
    """
    logging.info("Running standard quantification pipeline.")
    # Create the command line string and run it using subprocess
    cmd = f"kb count -i {index_dir}/index.idx -g {index_dir}/t2g.txt -x {read_format} -w {barcode_onlist} --strand {strand} -r {replacement_list} -o {output_dir} --h5ad --gene-names -t {threads} {interleaved_fastqs}"
    logging.info(f"Running command: {cmd}")
    try:
        result = subprocess.run(cmd, shell=True, capture_output=True, text=True, check=True)
        logging.info(f"Command output: {result.stdout}")
    except subprocess.CalledProcessError as e:
        logging.error(f"Command failed with error: {e.stderr}")


@quant.command("nac")
@click.option('--index_dir', type=click.Path(exists=True), help='Path to the index directory.', required=True)
@click.option('--read_format', type=str, help='String indicating the position of umi and barcode.', required=True)
@click.option('--output_dir', type=click.Path(exists=True), help='Path to the output directory.', required=True)
@click.option('--strand', type=str, help='Library strand orientation.', required=True)
@click.option('--threads', default=1, type=int, help='Number of threads to use. Default is 1.')
@click.option('--barcode_onlist', type=click.Path(exists=True), help='Barcode onlist file.', required=True)
@click.option('--replacement_list', type=click.Path(exists=True), help='Replacement list file.')
@click.argument('interleaved_fastqs', nargs=-1, type=click.Path(exists=True), help='FASTQ files to align. The file needs to be supply in interleaved format(Example: pairA_1.fastq pairA_2.fastq pairB_1.fastq pairB_2.fastq).')
def quant_nac(index_dir, read_format, replacement_list, barcode_onlist, strand, output_dir, threads, interleaved_fastqs):
    """
    Runs the nac quantification pipeline using kallisto and bustools.

    Parameters:
    index_dir (Path): Directory containing the kallisto index and transcript-to-gene mapping files.
    read_format (str): Format of the reads (e.g., '10xv2', '10xv3').
    output_dir (Path): Directory where the output files will be saved.
    strand (str): Strand specificity (e.g., 'unstranded', 'forward', 'reverse').
    threads (int): Number of threads to use for the computation.
    barcode_onlist (File): Path to the whitelist of barcodes.
    replacement_list (File): Path to the replacement list file.
    interleaved_fastqs (File): Path to the interleaved FASTQ files.

    Returns:
    Please refer to the kallisto and bustools documentation for the output files.
    """
    logging.info("Running nac quantification pipeline.")
    # Create the command line string and run it using subprocess
    cmd = f"kb count --workflow=nac -i {index_dir}/index.idx -g {index_dir}/t2g.txt -c1 {index_dir}/cdna.txt -c2 {index_dir}/nascent.txt --sum=total -x {read_format} -w {barcode_onlist} -r {replacement_list} --strand {strand} -o {output_dir} --h5ad --gene-names -t {threads} {interleaved_fastqs}"
    logging.info(f"Running command: {cmd}")
    try:
        result = subprocess.run(cmd, shell=True, capture_output=True, text=True, check=True)
        logging.info(f"Command output: {result.stdout}")
    except subprocess.CalledProcessError as e:
        logging.error(f"Command failed with error: {e.stderr}")


