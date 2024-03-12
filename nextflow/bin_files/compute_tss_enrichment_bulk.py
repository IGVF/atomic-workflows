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
import os

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
  print(f"Processing promoter_size: {promoter_size}")
  bulk_signal_counter = np.zeros(promoter_size)
  print(f"Processing bulk_signal_counter: {bulk_signal_counter}")
  barcode_signal_counter = defaultdict(partial(np.zeros, 301))
  print(f"Processing barcode_signal_counter: {barcode_signal_counter}")
  barcode_statistics = defaultdict(partial(np.zeros, 3))
  print(f"Processing barcode_statistics: {barcode_statistics}")

  tabixfile = None  # Initialize tabixfile before the try block

  try:
    print(f"Processing tabix_filename: {tabix_filename}")

    # Check if the file exists before attempting to open
    if not os.path.exists(tabix_filename):
      print(f"Error: file not found: {tabix_filename}")
      return get_outputs(idx, bulk_signal_counter, barcode_signal_counter, barcode_statistics)

    # Remove '.tbi' extension if present
    if tabix_filename.endswith('.tbi'):
      tabix_filename = tabix_filename[:-4]

    tabixfile = pysam.TabixFile(tabix_filename)
  except Exception as e:
    print(f"Error opening TabixFile: {e}")
    return get_outputs(idx, bulk_signal_counter, barcode_signal_counter, barcode_statistics)

  for tss in regions_bed:
    print(f"Processing TSS: {tss}")
    promoter_start = int(tss[1]) - flank
    promoter_end = int(tss[1]) + flank
    promoter_strand = tss[3]
    try:
      for fragment in tabixfile.fetch(str(tss[0]), max(0, promoter_start), promoter_end):
        fragment_fields = fragment.split("\t")

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

def plot_tss_enrichment(raw_signal, smoothed_signal, out_file):
  fig = plt.figure(figsize=(8.0, 5.0))
  plt.plot(raw_signal, 'k.')
  plt.plot(smoothed_signal, 'r')
  plt.ylabel('TSS enrichment')
  plt.xticks([0, 2000, 4000], ['-2000', 'TSS', '+2000'])
  fig.savefig(out_file)
  plt.close(fig)

def compute_tss_enrichment(array_counts, window_size, png_file):
  size = len(array_counts)
  normalization_factor = np.mean(array_counts[np.r_[0:100, size-100-1:size]])

  raw_signal = array_counts / max(0.2, normalization_factor)
  smoothed_signal = np.convolve(array_counts, np.ones(window_size), 'same') / window_size / normalization_factor

  plot_tss_enrichment(raw_signal, smoothed_signal, png_file)

  return max(smoothed_signal)

def compute_tss_enrichment_barcode(array_counts):
  size = len(array_counts)
  normalization_factor = 2 * (np.sum(array_counts[np.r_[0:100, size-100:size]])) / 200

  reads_in_tss = np.sum(array_counts[100:201])
  tss_enrichment = 2 * reads_in_tss / 101 / max(0.2, normalization_factor)

  return tss_enrichment, reads_in_tss

def _prepare_args_for_counting(
  tabix_file: BinaryIO,
  regions_list: list,
  flank_size: int,
  cpus: int):
  input_args = []
  for idx, chunk in enumerate(np.array_split(regions_list, cpus)):
    input_args.append(
      (idx, tabix_file, chunk, flank_size)
    )

  return input_args

def _merge_barcode_results(barcode, results, barcode_stats):
  tmp_signal = np.zeros(301)
  tmp_statistic = np.zeros(3)

  for result, statistic in zip(results, barcode_stats):
    if barcode in result:
      tmp_signal += result[barcode]
    if barcode in statistic:
      tmp_statistic += statistic[barcode]

  return tmp_signal, tmp_statistic

def _merge_bulk_signal(results):
  tmp = np.ones(len(results[0]))
  for result in results:
    tmp += result
  return tmp

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

  if args.prefix:
    prefix = args.prefix
  else:
    prefix = "sample"

  regions_list = np.loadtxt(args.regions, 'str', usecols=(0, 1, 2, args.s-1))
  count_args = _prepare_args_for_counting(args.tabix, regions_list, args.e, args.p)

  if args.p > 1:
    with multiprocessing.Pool(args.p) as pool:
      results = pool.starmap(compute_tss_score, count_args)
    results.sort(key=operator.itemgetter("idx"))
