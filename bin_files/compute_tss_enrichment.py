#!/usr/bin/env python3
import sys
import pysam
import numpy as np
from collections import defaultdict
from functools import partial

def get_outputs(idx, bulk_signal_counter, barcode_signal_counter, barcode_statistics):
    """
    Organize and return the results of data processing.

    Parameters
    ----------
    idx : int
        Identifier for the processing instance.
    bulk_signal_counter : numpy.ndarray
        Array storing the bulk signal counter.
    barcode_signal_counter : dict
        Dictionary storing barcode-specific signal counters.
    barcode_statistics : dict
        Dictionary storing barcode-specific statistics.

    Returns
    -------
    dict
        A dictionary containing the processed results.

    """
    print("Executing get_outputs()")
    return {
        "idx": idx,
        "bulk_signal": bulk_signal_counter,
        "barcode_signal": barcode_signal_counter,
        "barcode_statistics": barcode_statistics
    }


def _add_read_to_dictionary(bulk_signal_counter,
                            barcode_signal_counter,
                            fragment_position,
                            promoter_start,
                            promoter_end,
                            promoter_strand,
                            barcode,
                            stats_counter,
                            flank_size=50):  # Use the flank_size parameter
    """
    Update counters based on the information from each read fragment.

    Parameters
    ----------
    bulk_signal_counter : numpy.ndarray
        Array storing the bulk signal counter.
    barcode_signal_counter : defaultdict
        Default dictionary storing barcode-specific signal counters.
    fragment_position : int
        Position of the read fragment.
    promoter_start : int
        Start position of the promoter region.
    promoter_end : int
        End position of the promoter region.
    promoter_strand : str
        Strand information for the promoter.
    barcode : str
        Barcode associated with the read fragment.
    stats_counter : numpy.ndarray
        Array storing barcode-specific statistics.
    flank_size : int, optional
        Size of the flank region, default is 50.

    Returns
    -------
    None

    """
    print("Executing _add_read_to_dictionary()")
    if fragment_position < promoter_start or fragment_position > promoter_end - 1:
        # This position does not cover the promoter.
        return

    # We are adding to an array that covers each base pair from promoter_start to promoter_end.
    # This converts the genomic coordinates to the index that we need to update in the array.
    index = int(fragment_position - promoter_start)  # 0-based
    index_reduced = -1

    max_window = len(bulk_signal_counter) - 1  # max accessible array index
    tss_pos = int(max_window / 2)
    weight = 0

    if 0 <= index <= flank_size - 1:
        index_reduced = index
        weight = 1

    elif max_window - flank_size <= index <= max_window:
        index_reduced = index - (max_window - 2 * flank_size)
        weight = 1

    elif tss_pos - flank_size <= index <= tss_pos + flank_size:
        # Find the center of the region with max_window/2+flank_size
        index_reduced = int(index - (tss_pos - flank_size)) + flank_size
        weight = 1
        stats_counter[0] += 1

    # If the TSS is in the negative strand, we need to add from the end.
    if promoter_strand == "-":
        index = max_window - index
        if weight > 0:
            index_reduced = 2 * flank_size + 1 - index_reduced - 1

    # Finally, update the dictionary
    bulk_signal_counter[index] += 1  # Bulk TSS enrichment
    stats_counter[1] += 1  # Reads in TSS

    print('each barcode represents a unique cell')
    barcode_signal_counter[barcode][index_reduced] += weight  # Per barcode TSS enrichment
    return


def process_data(tabix_file, flank_size, strand_column, cpus, regions_file):

    print(f"Processing data from {tabix_file}")
    print(f"Flank size: {flank_size}")
    print(f"Strand column: {strand_column}")
    print(f"CPUs: {cpus}")
    print(f"Regions file: {regions_file}")

    # TSS +/- flank
    print('defaultdict and bulk_signal_counter are mutable and therefore, they are pass by reference to _add_read_to_dictionary')
    promoter_size = flank_size * 2
    bulk_signal_counter = np.zeros(promoter_size)
    barcode_signal_counter = defaultdict(partial(np.zeros, 2 * flank_size + 1))
    barcode_statistics = defaultdict(partial(np.zeros, 3))

    tabixfile = pysam.TabixFile(tabix_file)
    # Read regions from the specified file
    regions_list = np.loadtxt(regions_file, 'str', usecols=(0, 1, 2, strand_column - 1))

    for tss in regions_list:
        promoter_start = int(tss[1]) - flank_size
        promoter_end = int(tss[1]) + flank_size
        promoter_strand = tss[3]

        try:
            for fragment in tabixfile.fetch(str(tss[0]), max(0, promoter_start), promoter_end):
                fragment_fields = fragment.split("\t")
                fragment_start = int(fragment_fields[1])
                fragment_end = int(fragment_fields[2])
                barcode = fragment_fields[3]

                barcode_stats_helper = barcode_statistics[barcode]
                barcode_stats_helper[2] += 1

                _add_read_to_dictionary(bulk_signal_counter,
                                        barcode_signal_counter,
                                        fragment_start,
                                        promoter_start,
                                        promoter_end,
                                        promoter_strand,
                                        barcode,
                                        barcode_stats_helper,
                                        flank_size)

                _add_read_to_dictionary(bulk_signal_counter,
                                        barcode_signal_counter,
                                        fragment_end,
                                        promoter_start,
                                        promoter_end,
                                        promoter_strand,
                                        barcode,
                                        barcode_stats_helper,
                                        flank_size)

                barcode_statistics[barcode] = barcode_stats_helper

        except ValueError:
            print(f"No reads found for {tss[0]}:{max(1, promoter_start)}-{promoter_end}.")

    return get_outputs(0, bulk_signal_counter, barcode_signal_counter, barcode_statistics)


if __name__ == "__main__":
    # Read parameters from command-line arguments
    tabix_file = sys.argv[1]
    flank_size = int(sys.argv[2])
    strand_column = int(sys.argv[3])
    cpus = int(sys.argv[4])
    regions_file = sys.argv[5]
    print('The scripts aim to measure how open chromatin regions (accessible DNA) are distributed around genes starting points.')
    # Call the processing function
    process_data(tabix_file, flank_size, strand_column, cpus, regions_file)
