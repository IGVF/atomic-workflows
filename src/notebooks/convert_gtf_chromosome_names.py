import marimo

__generated_with = "0.11.17"
app = marimo.App()


@app.cell
def _():
    import marimo as mo
    import pandas as pd
    import gzip
    import io
    import requests
    return gzip, io, mo, pd, requests


@app.cell
def _(mo):
    mo.md(
        """
        # Convert GTF chromosome names.
        This notebook contains the steps necessary to convert convert the GTF file chromosome names to match the chromosome names in the genome reference FASTA file.
        """
    )
    return


@app.cell
def _(mo):
    hg38_url = "https://hgdownload.soe.ucsc.edu/goldenPath/hg38/bigZips/hg38.chromAlias.txt"
    IGVFFI7217ZMJZ_gencode_43_url = "https://api.data.igvf.org/reference-files/IGVFFI7217ZMJZ/@@download/IGVFFI7217ZMJZ.gtf.gz"


    mo.md(
        f"""
        ### File URLs for human:
        - [hg38 chromosome aliases]({hg38_url})
        - hg38 genome reference: [IGVFFI0653VCGH](https://api.data.igvf.org/reference-files/IGVFFI0653VCGH/@@download/IGVFFI0653VCGH.fasta.gz)
        - Gencode GTF version 43: [IGVFFI7217ZMJZ]({IGVFFI7217ZMJZ_gencode_43_url})
        """)
    return IGVFFI7217ZMJZ_gencode_43_url, hg38_url


@app.cell
def _(mo):
    mm39_url = "https://hgdownload.soe.ucsc.edu/goldenPath/mm39/bigZips/mm39.chromAlias.txt"
    IGVFFI5842FWGQ_gencode_36_url = "https://api.data.igvf.org/reference-files/IGVFFI5842FWGQ/@@download/IGVFFI5842FWGQ.gtf.gz"
    mo.md(
        f"""
        ### File URLs for mouse:
        - [mm39 chromosome aliases]({mm39_url})
        - mm39 genome reference: [IGVFFI9282QLXO](https://api.data.igvf.org/reference-files/IGVFFI9282QLXO/@@download/IGVFFI9282QLXO.fasta.gz)
        - Gencode GTF version 36: [IGVFFI5842FWGQ]({IGVFFI5842FWGQ_gencode_36_url})
        """)
    return IGVFFI5842FWGQ_gencode_36_url, mm39_url


@app.cell
def _(mo):
    mo.md("""## Convert hg38""")
    return


@app.cell
def _(hg38_url, mo, pd):
    hg38_mapping_df = pd.read_csv(
        hg38_url, sep="\t", header=None, index_col=0, skiprows=1
    )

    hg38_mapping_dict = {}
    for hg38_index, hg38_row in hg38_mapping_df.iterrows():
        # I am adding the mapping with itself because it makes
        # the next step easier.
        hg38_mapping_dict[hg38_index] = hg38_index
        for hg38_alias in hg38_row.dropna().values:
            hg38_mapping_dict[hg38_alias] = hg38_index

    mo.md(f"Loaded {len(hg38_mapping_dict)} chromosome aliases for hg38.")
    return hg38_alias, hg38_mapping_df, hg38_mapping_dict, hg38_index, hg38_row


@app.cell
def _(
    IGVFFI7217ZMJZ_gencode_43_url,
    gzip,
    hg38_mapping_dict,
    io,
    mo,
    requests,
):
    mo.md("Load the GTF file and convert the chromosome names.")

    response_hg38 = requests.get(IGVFFI7217ZMJZ_gencode_43_url, stream=True)
    response_hg38.raise_for_status()  # Check for HTTP errors

    with gzip.GzipFile(fileobj=io.BytesIO(response_hg38.content)) as gz_hg38:
        with open("IGVFFI7217ZMJZ_updated_chromosome_names.gtf", "w") as output_file_hg38, open("hg38_substitution_log.txt", "w") as log_file_hg38:
            for line_hg38 in gz_hg38:
                line_decode_hg38 = line_hg38.decode('utf-8').strip()
                if line_decode_hg38.startswith("#"):
                    output_file_hg38.write(line_decode_hg38 + "\n")
                else:
                    columns_hg38 = line_decode_hg38.split("\t")
                    try:
                        original_chromosome_hg38 = columns_hg38[0]
                        columns_hg38[0] = hg38_mapping_dict[columns_hg38[0]]
                        output_file_hg38.write("\t".join(columns_hg38) + "\n")
                        log_file_hg38.write(f"Substituted {original_chromosome_hg38} with {columns_hg38[0]}\n")
                    except KeyError:
                        log_file_hg38.write(f"Missing key: {columns_hg38[0]}\n")
                        print(f"Missing key: {columns_hg38[0]}")
    return columns_hg38, gz_hg38, line_hg38, line_decode_hg38, output_file_hg38, response_hg38


@app.cell
def _(mo):
    mo.md("""## Convert mm39""")
    return


@app.cell
def _(mm39_url, mo, pd):
    mm39_mapping_df = pd.read_csv(
        mm39_url, sep="\t", header=None, index_col=0, skiprows=1
    )

    mm39_mapping_dict = {}
    for mm39_index, mm39_row in mm39_mapping_df.iterrows():
        # I am adding the mapping with itself because it makes
        # the next step easier.
        mm39_mapping_dict[mm39_index] = mm39_index
        for mm39_alias in mm39_row.dropna().values:
            mm39_mapping_dict[mm39_alias] = mm39_index

    mo.md(f"Loaded {len(mm39_mapping_dict)} chromosome aliases for mm39.")
    return mm39_alias, mm39_mapping_df, mm39_mapping_dict, mm39_index, mm39_row


@app.cell
def _(
    IGVFFI5842FWGQ_gencode_36_url,
    gzip,
    mm39_mapping_dict,
    io,
    mo,
    requests,
):
    mo.md("Load the GTF file and convert the chromosome names.")

    response_mm39 = requests.get(IGVFFI5842FWGQ_gencode_36_url, stream=True)
    response_mm39.raise_for_status()  # Check for HTTP errors

    with gzip.GzipFile(fileobj=io.BytesIO(response_mm39.content)) as gz_mm39:
        with open("IGVFFI5842FWGQ_updated_chromosome_names.gtf", "w") as output_file_mm39, open("mm39_substitution_log.txt", "w") as log_file_mm39:
            for line_mm39 in gz_mm39:
                line_decode_mm39 = line_mm39.decode('utf-8').strip()
                if line_decode_mm39.startswith("#"):
                    output_file_mm39.write(line_decode_mm39 + "\n")
                else:
                    columns_mm39 = line_decode_mm39.split("\t")
                    try:
                        original_chromosome_mm39 = columns_mm39[0]
                        columns_mm39[0] = mm39_mapping_dict[columns_mm39[0]]
                        output_file_mm39.write("\t".join(columns_mm39) + "\n")
                        log_file_mm39.write(f"Substituted {original_chromosome_mm39} with {columns_mm39[0]}\n")
                    except KeyError:
                        log_file_mm39.write(f"Missing key: {columns_mm39[0]}\n")
                        print(f"Missing key: {columns_mm39[0]}")
    return columns_mm39, gz_mm39, line_mm39, line_decode_mm39, output_file_mm39, response_mm39


if __name__ == "__main__":
    app.run()
