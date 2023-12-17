# originally 3 files
# umi_rank_plot_file <- args[9] = umi_barcode_rank_plot
# gene_rank_plot_file <- args[10] = gene_barcode_rank_plot
# gene_umi_plot_file <- args[11] = gene_umi_scatter_plot

# Function to get vectors from x and y coordinates
get_vectors <- function(x, y) {
  smooth_spline <- smooth.spline(x, y, spar=1)
  second_deriv <- predict(smooth_spline, x, deriv=2)
  
  # Second derivative values can be noisy at the beginning and end of the graph; exclude the first 10% and last 10% 
  # of values when establishing uniformity of the second derivative sign
  ten_percent <- round(length(second_deriv$x) * 0.1)
  mid_second_deriv <- second_deriv$y[(ten_percent + 1):(length(second_deriv$y) - ten_percent)]
  
  if (all(mid_second_deriv >= 0) | all(mid_second_deriv <= 0)){
    print("Returning original vectors")
    return(list(x, y))
  } else {
    # Find absolute minimum
    abs_min_idx <- second_deriv$x[which.min(second_deriv$y)]
    # Find the last non-negative value before the absolute minimum
    left_vect <- second_deriv$y[1:abs_min_idx]
    endpt_1_idx <- tail(which(left_vect >= 0), n=1)
    # Find the first non-positive value after the absolute minimum
    right_vect <- second_deriv$y[abs_min_idx:length(second_deriv$y)]
    endpt_2_idx <- abs_min_idx + which(right_vect >= 0)[1] - 1
    
    # Error cases: revert to elbow finder
    # Used when the second derivative curve has both positive and negative values, 
    # but doesn't match the positive-negative-positive shape expected of a knee's second derivative
    if (length(endpt_1_idx) == 0 | length(endpt_2_idx) == 0){
      print("Returning original vectors")
      return(list(x, y))
    } else if (is.na(endpt_1_idx) | is.na(endpt_2_idx)){
      print("Returning original vectors")
      return(list(x, y))
    } else {
      print("Returning sliced vectors")
      return(list(x[endpt_1_idx:endpt_2_idx], y[endpt_1_idx:endpt_2_idx]))
    }
  }
}


elbow_knee_finder <- function(x, y, mode = "basic") {
  # With advanced mode, use a helper function to determine which vectors to perform the calculation on
  if (mode == "advanced") {
    # smooth.spline() function used in get_vectors() requires at least 4 unique
    # x values; preempt this error
    if (length(unique(x)) < 4) {
      return(NULL)
    } else {
      xy_vects <- get_vectors(x, y)
      x <- xy_vects[[1]]
      y <- xy_vects[[2]]
    }
  }
  # Error case: return null if vectors have length 0
  if (length(x) == 0 | length(y) == 0) {
    return(NULL)
  }
  # Get endpoints (point with the smallest x value, point with the largest x value)
  endpts_df <- data.frame(x_coords = c(x[1], x[length(x)]),
                          y_coords = c(y[1], y[length(y)]))
  # Fit a line between endpoints
  fit <- lm(endpts_df$y_coords ~ endpts_df$x_coords)
  # For each point, get the distance from the line
  distances <- numeric(length(x))
  for (i in 1:length(x)) {
    distances[i] <- abs(coef(fit)[2] * x[i] - y[i] + coef(fit)[1]) / sqrt(coef(fit)[2]^2 + 1^2)
  }

  # Get the point farthest from the line
  x_max_dist <- x[which.max(distances)]
  y_max_dist <- y[which.max(distances)]

  cat("elbow_knee_finder: Elbow/Knee Point:", c(x_max_dist, y_max_dist), "\n")
  return(c(x_max_dist, y_max_dist))
}




# Function to find the elbow/knee of a plot, and the elbow/knee of the points
# before the first elbow/knee (i.e., elbow/knee of all barcodes, and elbow/knee
# of top-ranked barcodes).
# Takes in xy coordinates of the plot and returns a vector of four coordinates:
# xy coordinates of the first elbow/knee and xy coordinates of the second elbow/knee.
get_elbow_knee_points <- function(x, y) {
  cat("get_elbow_knee_points: R function get_elbow_knee_points execution started.\n")

  # Check if there are enough data points to perform the analysis
  if (length(x) < 4 | length(y) < 4) {
    cat("get_elbow_knee_points: Insufficient data points. Unable to find elbow/knee points.\n")
    return(NULL)
  }

  point_1 <- elbow_knee_finder(x, y, mode = "basic")
  if (!is.null(point_1)) {
    point_2 <- elbow_knee_finder(x[1:point_1[1]], y[1:point_1[1]], mode = "advanced")
  } else {
    cat("get_elbow_knee_points: Unable to find elbow/knee points for the first plot.\n")
    return(NULL)
  }
  
  if (is.null(point_2)) {
    cat("get_elbow_knee_points: Unable to find elbow/knee points for the second plot.\n")
    return(NULL)
  }

  cat("get_elbow_knee_points: R function get_elbow_knee_points execution completed.\n")
  return(c(point_1, point_2))
}



# Define the print_rna_qc_metrics function
                                 
print_rna_qc_metrics <- function(barcode_metadata_file, umi_cutoff, gene_cutoff, umi_rank_plot_file, gene_rank_plot_file) {
  # , gene_umi_plot_file) {
  cat("Printing RNA QC metrics...\n")
  # Add your logic to print RNA QC metrics here
  
  # Read the table from the specified file
  cat("print_rna_qc_metrics: Reading barcode metadata from file:", barcode_metadata_file, "\n")
  barcode_metadata <- read.table(barcode_metadata_file, header = TRUE)
  
  # Print each argument
  cat("print_rna_qc_metrics: Parsed Arguments:\n")
  cat("print_rna_qc_metrics: Barcode Metadata File:", barcode_metadata_file, "\n")
  cat("print_rna_qc_metrics: UMI Cutoff:", umi_cutoff, "\n")
  cat("print_rna_qc_metrics: Gene Cutoff:", gene_cutoff, "\n")
  cat("print_rna_qc_metrics: UMI Rank Plot All:", umi_rank_plot_all, "\n")
  cat("print_rna_qc_metrics: UMI Rank Plot Top:", umi_rank_plot_top, "\n")
  
  # Impose UMI cutoff, sort in decreasing order, assign rank
  umi_filtered <- barcode_metadata$total_counts[barcode_metadata$total_counts >= umi_cutoff]
  umi_filtered_sort <- sort(umi_filtered, decreasing = TRUE)
  umi_rank <- 1:length(umi_filtered_sort)

  # Find elbow/knee of UMI barcode rank plot and top-ranked UMI barcode rank plot
  umi_points <- get_elbow_knee_points(x = umi_rank, y = log10(umi_filtered_sort))

  # For each valid plot, make factor for coloring plot points
  if (length(umi_points) > 0) { # Elbow found in first plot
    umi_plot1 <- TRUE
    is_top_ranked_umi <- factor(ifelse(umi_rank <= umi_points[1], 1, 0))
    if (length(umi_points) > 2) { # Elbow/knee found in second plot
      umi_plot2 <- TRUE
      umi_top_rank <- umi_rank[1:umi_points[1]]
      umi_top_umi <- umi_filtered_sort[1:umi_points[1]]
      is_top_top_ranked_umi <- factor(ifelse(umi_top_rank <= umi_points[3], 1, 0))
    } else {
      umi_plot2 <- FALSE
    }
  } else {
    umi_plot1 <- FALSE
  }
  
  # Impose gene cutoff, sort in decreasing order, assign rank
  gene_filtered <- barcode_metadata$genes[barcode_metadata$genes >= gene_cutoff]
  gene_filtered_sort <- sort(gene_filtered, decreasing=T)
  gene_rank <- 1:length(gene_filtered_sort)
  
  
  # Find elbow/knee of gene barcode rank plot and top-ranked gene barcode rank plot
  gene_points <- get_elbow_knee_points(x=gene_rank, y=log10(gene_filtered_sort))
  # For each valid plot, make factor for coloring plot points
  if (length(gene_points) > 0) { # Elbow found in first plot
    gene_plot1 <- TRUE
    is_top_ranked_gene <- factor(ifelse(gene_rank <= gene_points[1], 1, 0))
    if (length(gene_points) > 2) { # Elbow/knee found in second plot
      gene_plot2 <- TRUE
      gene_top_rank <- gene_rank[1:gene_points[1]]
      gene_top_gene <- gene_filtered_sort[1:gene_points[1]]
      is_top_top_ranked_gene <- factor(ifelse(gene_top_rank <= gene_points[3], 1, 0))
    } else {
      gene_plot2 <- FALSE
    }
  } else {
    gene_plot1 <- FALSE
  }

  ## Generate plots
  options(scipen=999)

  # Make UMI barcode rank plots
  png(umi_rank_plot_file, width=8, height=8, units='in', res=300)
  par(mfrow = c(2,1))

  # Plot 1 (all barcodes passing UMI filter vs log10(UMIs))
  if (umi_plot1) {
    plot(x=umi_rank,
         y=umi_filtered_sort,
         log="y",
         xlab=paste0(" Barcode rank (", length(umi_rank)-umi_points[1], " low quality cells)"), 
         ylab="log10(UMIs)",
         main="RNA UMIs per Barcode", 
         col=c("dimgrey","darkblue")[is_top_ranked_umi], 
         pch=16,
         ylim=c(1,100000))
    abline(v=umi_points[1], h=10^(umi_points[2]))
    text(umi_points[1], 10^(umi_points[2]),
         paste0("(", umi_points[1], ", ", 10^(umi_points[2]), ")"),
         adj=c(-0.1,-0.5))
  }
  
  # Plot 2 (top ranked barcodes vs log10(UMIs))
  if (umi_plot2) {
    plot(x=umi_top_rank,
         y=umi_top_umi,
         log="y",
         xlab="Barcode rank",
         ylab="log10(UMIs)",
         main="RNA UMIs per Top-Ranked Barcode",
         col=c("dimgrey","darkblue")[is_top_top_ranked_umi],
         pch=16,
         ylim=c(1,100000))
    abline(v=umi_points[3], h=10^(umi_points[4]))
    text(umi_points[3], 10^(umi_points[4]),
         paste("(", umi_points[3], ", ", 10^(umi_points[4]), ")", sep=""),
         adj=c(-0.1,-0.5))
  }
  dev.off()
  
  # Make gene barcode rank plots
  png(gene_rank_plot_file, width=8, height=8, units='in', res=300)
  par(mfrow = c(2,1))

  # Plot 1 (all barcodes passing gene filter vs log10(genes))
  if (gene_plot1) {
    plot(x=gene_rank,
         y=gene_filtered_sort,
         log="y",
         xlab=paste0(" Barcode rank (", length(gene_rank)-gene_points[1], " low quality cells)"), 
         ylab="log10(genes)",
         main="RNA Genes per Barcode", 
         col=c("dimgrey","darkblue")[is_top_ranked_gene], 
         pch=16,
         ylim=c(1,10000))
    abline(v=gene_points[1], h=10^(gene_points[2]))
    text(gene_points[1], 10^(gene_points[2]),
         paste0("(", gene_points[1], ", ", 10^(gene_points[2]), ")"),
         adj=c(-0.1,-0.5))
  }
  
  
  # Plot 2 (top ranked barcodes vs log10(genes))
  if (gene_plot2) {
    plot(x=gene_top_rank,
         y=gene_top_gene,
         log="y",
         xlab="Barcode rank",
         ylab="log10(genes)",
         main="RNA Genes per Top-Ranked Barcode",
         col=c("dimgrey","darkblue")[is_top_top_ranked_gene],
         pch=16,
         ylim=c(1,10000))
    abline(v=gene_points[3], h=10^(gene_points[4]))
    text(gene_points[3], 10^(gene_points[4]),
         paste("(", gene_points[3], ", ", 10^(gene_points[4]), ")", sep=""),
         adj=c(-0.1,-0.5))
  }
  dev.off()
  
}

# Define the main function with arguments

main <- function(barcode_metadata_file, umi_cutoff, gene_cutoff, umi_rank_plot_file, gene_rank_plot_file, gene_umi_plot_file) {
  cat("Hello, this is the main function!\n")
  cat("Barcode Metadata File:", barcode_metadata_file, "\n")
  cat("UMI Cutoff:", umi_cutoff, "\n")
  cat("Gene Cutoff:", gene_cutoff, "\n")
  cat("UMI Rank Plot File:", umi_rank_plot_file, "\n")  
  cat("Gene Rank Plot File:", gene_rank_plot_file, "\n") 
  cat("Gene UMI Plot File:", gene_umi_plot_file, "\n")
  
  # Call the print_rna_qc_metrics function with all required arguments
  # print_rna_qc_metrics(barcode_metadata_file, umi_cutoff, gene_cutoff, umi_rank_plot_file, gene_rank_plot_file) #, gene_umi_plot_file)
}

# Check if enough arguments are provided
if (length(commandArgs(trailingOnly = TRUE)) < 6) {
  stop("Insufficient arguments. Please provide barcode_metadata_file, umi_cutoff, gene_cutoff, umi_rank_plot_file, gene_rank_plot_file, and gene_umi_plot_file.")
}

# Retrieve command line arguments
barcode_metadata_file <- commandArgs(trailingOnly = TRUE)[1]
umi_cutoff <- as.integer(commandArgs(trailingOnly = TRUE)[2])
gene_cutoff <- as.integer(commandArgs(trailingOnly = TRUE)[3])
umi_rank_plot_file <- commandArgs(trailingOnly = TRUE)[4]
gene_rank_plot_file <- commandArgs(trailingOnly = TRUE)[5]
gene_umi_plot_file <- commandArgs(trailingOnly = TRUE)[6]

# Call the main function with arguments
     barcode_metadata_file, umi_cutoff, gene_cutoff, umi_rank_plot_file, gene_rank_plot_file
main(barcode_metadata_file, umi_cutoff, gene_cutoff, umi_rank_plot_file, gene_rank_plot_file, gene_umi_plot_file)