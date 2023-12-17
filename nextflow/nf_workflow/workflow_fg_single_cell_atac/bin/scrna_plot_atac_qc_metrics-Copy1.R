#!/usr/bin/Rscript
# Copied from here: https://github.com/IGVF/atomic-workflows/blob/dev/src/R/atac_qc_plots.R
# adjusted to work with workflow
### Takes ATAC barcode metadata tsv file, and outputs barcode rank plots as a png file.


# Function to find and source a file in PATH
source_file_in_path <- function(file_name) {
  # Get the directories listed in PATH
  print("At source_file_in_path"
  path_dirs <- unlist(strsplit(Sys.getenv("PATH"), ":"))

  # Iterate over each directory
  for (dir in path_dirs) {
    file_path <- file.path(dir, file_name)

    # Check if the file exists in the directory
    if (file.exists(file_path)) {
      cat("Found file:", file_path, "\n")

      # Source the file
      source(file_path)

      # Exit the loop once the file is found and sourced
      break
    }
  }
}

## Get arguments, read input
args <- commandArgs()

r_qc_plot_helper_script <- commandArgs(trailingOnly = TRUE)[1]
print("scrna_plot_atac_qc_metrics: r_qc_plot_helper_script is: ",r_qc_plot_helper_script)
barcode_metadata_file <- commandArgs(trailingOnly = TRUE)[2]
print("scrna_plot_atac_qc_metrics: barcode_metadata_file is: ",barcode_metadata_file)
fragment_cutoff <- as.integer(commandArgs(trailingOnly = TRUE)[3])
print("scrna_plot_atac_qc_metrics: fragment_cutoff is: ",fragment_cutoff)
fragment_rank_plot_file <- commandArgs(trailingOnly = TRUE)[4]
print("scrna_plot_atac_qc_metrics: fragment_rank_plot_file is: ",fragment_rank_plot_file)

# Source the helper script if found in PATH
source_file_in_path(r_qc_plot_helper_script)


print("scrna_plot_atac_qc_metrics: Reading barcode metadata...")
barcode_metadata <- read.table(barcode_metadata_file, header=T)
print("scrna_plot_atac_qc_metrics: Barcode metadata read successfully.")

## Print the head of the barcode_metadata data frame
print("scrna_plot_atac_qc_metrics: Head of barcode_metadata data:")
print(head(barcode_metadata))

## Get plot inputs

# Impose fragment cutoff, sort in decreasing order, assign rank
# 1 fragment = 2 reads
print("scrna_plot_atac_qc_metrics: Processing fragment data...")
fragment <- barcode_metadata$unique
fragment_filtered <- fragment[fragment >= fragment_cutoff]
fragment_filtered_sort <- sort(fragment_filtered, decreasing=T)
fragment_rank <- 1:length(fragment_filtered_sort)
print("scrna_plot_atac_qc_metrics: Fragment data processed successfully.")

# Find elbow/knee of fragment barcode rank plot and top-ranked fragment barcode rank plot
print("scrna_plot_atac_qc_metrics: Finding elbow/knee points...")
fragment_points <- get_elbow_knee_points(x=fragment_rank, y=log10(fragment_filtered_sort))
print("scrna_plot_atac_qc_metrics: Elbow/knee points found successfully.")
# For each valid plot, make factor for coloring plot points
if (length(fragment_points) > 0) { # Elbow found in first plot
  fragment_plot1 <- TRUE
  is_top_ranked_fragment <- factor(ifelse(fragment_rank <= fragment_points[1], 1, 0))
  if (length(fragment_points) > 2) { # Elbow/knee found in second plot
    fragment_plot2 <- TRUE
    fragment_top_rank <- fragment_rank[1:fragment_points[1]]
    fragment_top_fragment <- fragment_filtered_sort[1:fragment_points[1]]
    is_top_top_ranked_fragment <- factor(ifelse(fragment_top_rank <= fragment_points[3], 1, 0))
  } else {
    fragment_plot2 <- FALSE
  }
} else {
    fragment_plot1 <- FALSE
}

## Generate plots

options(scipen=999)

# Make fragment barcode rank plots
print("scrna_plot_atac_qc_metrics: Generating fragment barcode rank plots...")
png(fragment_rank_plot_file, width=8, height=8, units='in', res=300)
par(mfrow = c(2,1))

# Plot 1 (all barcodes passing fragment filter vs log10(fragments))
if (fragment_plot1) {
  plot(x=fragment_rank,
       y=fragment_filtered_sort,
       log="y",
       xlab=paste0(" Barcode rank (", length(fragment_rank)-fragment_points[1], " low quality cells)"),
       ylab="Fragments per barcode (log10 scale)",
       main="ATAC Fragments per Barcode",
       col=c("dimgrey","darkblue")[is_top_ranked_fragment],
       pch=16,
       ylim=c(1,100000))
  abline(v=fragment_points[1], h=10^(fragment_points[2]))
  text(fragment_points[1], 10^(fragment_points[2]),
       paste0("(", fragment_points[1], ", ", 10^(fragment_points[2]), ")"),
       adj=c(-0.1,-0.5))
}

# Plot 2 (top ranked barcodes vs log10(fragments))
if (fragment_plot2) {
  plot(x=fragment_top_rank,
       y=fragment_top_fragment,
       log="y",
       xlab="Barcode rank",
       ylab="Fragments per barcode (log10 scale)",
       main="ATAC Fragments per Top-Ranked Barcode",
       col=c("dimgrey","darkblue")[is_top_top_ranked_fragment],
       pch=16,
       ylim=c(1,100000))
  abline(v=fragment_points[3], h=10^(fragment_points[4]))
  text(fragment_points[3]
