#!/usr/bin/env python3

"""
This script takes in the Picard CollectInsertSizeMetrics histogram txt file output,
and generates the histogram as a png.
This script is copied from: https://raw.githubusercontent.com/IGVF/atomic-workflows/dev/src/python/plot_insert_size_hist.py and adjusted to work with the nextflow pipeline
"""

import sys
import argparse
import pandas as pd
from plotnine import ggplot, aes, geom_line, geom_area, labs, scale_y_continuous, theme_classic

def label_func(breaks):
  return ["{:.0e}".format(x) for x in breaks]
  
def plot_hist(df, pkr, out_file):
  plot = (ggplot(df, aes(x="insert_size", y="count")) +
          geom_line(color="red") +
          geom_area(fill="red") +
          labs(title = f"Insert Size Histogram ({pkr})",
               x = "Insert size",
               y = "Count") + 
          scale_y_continuous(labels = label_func) +
          theme_classic())
  plot.save(filename = out_file, dpi=1000)
    
def get_hist_vals(histogram_file):
  """Get dataframe of histogram values"""
  with open(histogram_file, "r") as f:
    begin_vals = False
    insert_size = []
    count = []
    for line in f:
      vals = line.rstrip().split(sep="\t")
      if begin_vals and len(vals) == 2: # last line is blank
        insert_size.append(int(vals[0]))
        count.append(int(vals[1]))
      elif vals[0] == "insert_size": # desired values occur after line beginning with "insert_size"
        begin_vals = True

  df = pd.DataFrame(list(zip(insert_size, count)), columns=["insert_size","count"])

  return(df)

def parse_arguments():
  parser = argparse.ArgumentParser(description="Plot barcodes by RNA and ATAC QC status")
  parser.add_argument("--histogram_file", type=str, help="histogram_file")
  parser.add_argument("--pkr", type=str, help="pkr")
  parser.add_argument("--out_file", type=str, help="out_file")

  return parser.parse_args()

  
def main():
  print("Starting histogram plotting script")

  # In plot_insert_size_hist.py
  print("Received arguments:", sys.argv)
  # Parse command-line arguments
  args = parse_arguments()

  # Access the parsed arguments
  histogram_file = args.histogram_file
  pkr = args.pkr
  out_file = args.out_file

  # Print the parsed arguments
  print(f'Received arguments:')
  print(f'histogram_file: {histogram_file}')
  print(f'pkr: {pkr}')
  print(f'out_file: {out_file}')


  df = get_hist_vals(histogram_file)
  
  plot_hist(df, pkr, out_file)

  print("Finished plotting")

if __name__ == "__main__":
    main()
