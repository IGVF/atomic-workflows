#!/usr/bin/env python3

import argparse
import itertools
import matplotlib
import multiprocessing
import numpy as np
import operator
import pysam
from collections import defaultdict
from functools import partial
from typing import BinaryIO, TextIO

matplotlib.use('Agg')

def get_outputs(idx, bulk_signal_counter, barcode_signal_counter, barcode_statistics):
    return {
        "idx": idx,
        "bulk_signal": bulk_signal_counter,
        "barcode_signal": barcode_signal_counter,
        "barcode_statistics": barcode_statistics
    }

def compute_tss_score(idx: int, tabix_filename: BinaryIO, regions_bed: TextIO, flank: int = 2000):
    print(f"Processing index: {idx}")
    promoter_size = flank * 2
    bulk_signal_counter = np.zeros(promoter_size)
    barcode_signal_counter = defaultdict(partial(np.zeros, 301))
    barcode_statistics = defaultdict(partial(np.zeros, 3))

    print("Tabix filename:", tabix_filename)

    try:
        tabixfile = pysam.TabixFile(tabix_filename)
    except Exception as e:
        print(f"Error opening TabixFile: {e}")
        return get_outputs(idx, bulk_signal_counter, barcode_signal_counter, barcode_statistics)

    for tss in regions_bed:
        promoter_start = int(tss[1]) - flank
        promoter_end = int(tss[1]) + flank
        promoter_strand = tss[3]
        try:
            for fragment in tabixfile.fetch(str(tss[0]), max(0, promoter_start), promoter_end):
                fragment_fields = fragment.split("\t")
                print("Fragment fields:", fragment_fields)

                _add_read_to_dictionary(bulk_signal_counter, barcode_signal_counter,
                                        int(fragment_fields[1]), promoter_start, promoter_end, promoter_strand)
                _add_read_to_dictionary(bulk_signal_counter, barcode_signal_counter,
                                        int(fragment_fields[2]), promoter_start, promoter_end, promoter_strand)
        except ValueError:
            print(f"No reads found for {tss[0]}:{max(1, promoter_start)}-{promoter_end}.")

    return get_outputs(idx, bulk_signal_counter, barcode_signal_counter, barcode_statistics)

def _add_read_to_dictionary(bulk_signal_counter, barcode_signal_counter,
                            fragment_position, promoter_start, promoter_end, promoter_strand):
    if fragment_position < promoter_start or fragment_position > promoter_end - 1:
        return

    index = int(fragment_position - promoter_start)
    index_reduced = -1
    max_window = len(bulk_signal_counter) - 1
    tss_pos = int(max_window / 2)
    weight = 0

    if index >= 0 and index <= 99:
        index_reduced = index
        weight = 1
    elif index >= max_window - 99:
        index_reduced = index - (max_window - 300)
        weight = 1
    elif index >= tss_pos - 50 and index <= tss_pos + 50:
        index_reduced = int(index - (tss_pos - 50)) + 100
        weight = 1

    if promoter_strand == "-":
        index = max_window - index
        if weight > 0:
            index_reduced = 301 - index_reduced - 1

    bulk_signal_counter[index] += 1

    print("Bulk Signal Counter:", bulk_signal_counter)

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description="Add the description")

    parser.add_argument("tabix", help="Fragments file in tabix format and indexed.")
    parser.add_argument("-e", help="Number of bases to extend to each side. (default= 2000)", type=int, default=2000)
    parser.add_argument("-s", help="Column with strand information; 1-based. (default= 4)", type=int, default=4)
    parser.add_argument("-p", help="Number or threads for parallel processing (default= 1)", type=int, default=1)
    parser.add_argument("-w", "--window", type=int, default=20, help="Smoothing window size for plotting. (default= 20)")
    parser.add_argument("--prefix", help="Prefix for the metrics output file.")
    parser.add_argument("--regions", help="Bed file with the regions of interest")

    args = parser.parse_args()

    print("Command-line arguments:", args)

    if args.prefix:
        prefix = args.prefix
    else:
        prefix = "sample"

    regions_list = np.loadtxt(args.regions, 'str', usecols=(0, 1, 2, args.s-1))
    count_args = _prepare_args_for_counting(args.tabix, regions_list, args.e, args.p)

    print("Count arguments:", count_args)

    if args.p > 1:
        with multiprocessing.Pool(args.p) as pool:
            results = pool.starmap(compute_tss_score, count_args)
        results.sort(key=operator.itemgetter("idx"))
    else:
        results = list(itertools.starmap(compute_tss_score, count_args))

    per_barcode_output = f"{args.prefix}.tss_enrichment_barcode_stats.tsv"
    tss_enrichment_plot_fnp = f"{args.prefix}.tss_enrichment_bulk.png"

    print(f"Per barcode output: {per_barcode_output}")
    print(f"TSS enrichment plot filename: {tss_enrichment_plot_fnp}")

    with open(f"{args.prefix}.tss_score_bulk.txt", "w") as out_file:
        tss_score_bulk = compute_tss_enrichment(_merge_bulk_signal([result["bulk_signal"] for result in results]),
                                                args.window, tss_enrichment_plot_fnp)
        print(f"tss_enrichment\n{tss_score_bulk}", file=out_file)
