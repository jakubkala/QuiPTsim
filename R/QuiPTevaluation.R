#' function reads results of `create_simulation_data` function
#' attribute contains simulation details
#' @param path directory containing result files
#' @param title simulation title
#' @importFrom utils read.csv
#' @export
read_simulation_data <- function(path, title) {

  results <- read.csv(paste0(path, title, ".csv"))

  attr(results, "details") <- lapply(results[c("replication", "n_seq", "l_seq", "n_motifs",
                                               "n", "d","seqProbs", "motifProbs")], unique)

  results
}

#' subsets simple triplet matrix
#' @param filePath path of RDS file
#' @param n number of sequences to be subsetted
#' @param fraction fraction of positive sequences
#' @export
subset_matrix <- function(filePath, n, fraction) {
  matrix <- readRDS(filePath)
  target <- attr(matrix, "target")

  n_pos <- round(n * fraction)
  n_neg <- n - n_pos

  pos_indices <- sample(which(target), size = n_pos)
  neg_indices <- sample(which(!target), size = n_neg)

  sampled_matrix <- matrix[c(pos_indices, neg_indices), ]
  attr(sampled_matrix, "sequences") <- attr(matrix, "sequences")[c(pos_indices, neg_indices), ]
  attr(sampled_matrix, "motifs") <- attr(matrix, "motifs")[pos_indices]
  attr(sampled_matrix, "masks") <- attr(matrix, "masks")[pos_indices]
  attr(sampled_matrix, "target") <- c(rep(TRUE, n_pos), rep(FALSE, n_neg))

  sampled_matrix
}

#' function reads output files of `create_simulation_data`
#' @seealso [create_simulation_data()] [subset_matrix()]
#' @param filePath path of RDS file
#' @param n number of sequences to be subsetted (optional)
#' @param fraction fraction of positive sequences (optional)
#' @import slam
#' @export

read_ngram_matrix <- function(filePath, n = NULL, fraction = 0.5) {
  if (is.null(n)) {
    matrix <- readRDS(filePath)
  } else {
    matrix <- subset_matrix(filePath, n, fraction)
  }
  matrix
}

#' function combines two ngram matrices
#' @param m1 upper matrix
#' @param m2 lower matrix
#' @return combined ngram matrix
#' @importFrom pbapply  pblapply
#' @export

rbind_ngrams <- function(m1, m2) {

  m1_unique_colnames <- setdiff(colnames(m1), colnames(m2))
  m2_unique_colnames <- setdiff(colnames(m2), colnames(m1))

  m1_extended <- cbind(m1, matrix(0, nrow = nrow(m1), ncol = length(m2_unique_colnames)))
  m2_extended <- cbind(m2, matrix(0, nrow = nrow(m2), ncol = length(m1_unique_colnames)))


  colnames(m1_extended) <- c(colnames(m1), m2_unique_colnames)
  colnames(m2_extended) <- c(colnames(m2), m1_unique_colnames)

  m_extended <- rbind(m1_extended, m2_extended[, colnames(m1_extended)])

  attr(m_extended, "sequences") <- rbind(attr(m1, "sequences"), attr(m2, "sequences"))
  attr(m_extended, "motifs") <- c(attr(m1, "motifs"), attr(m2, "motifs"))
  attr(m_extended, "masks") <- c(attr(m1, "masks"), attr(m2, "masks"))
  attr(m_extended, "target") <- c(attr(m1, "target"), attr(m2, "target"))

  m_extended
}

#' function binds n-gram matrices
#' @param ... ngram_matrices (list of matrices can also be passed)
#' @return combined ngram matrix
#' @export

rbind_ngram_matrices <- function(...) {

  matrices <- list(...)

  # if list of matrices passed
  if (class(matrices) == "list"  & length(matrices) == 1) {
    matrices <- unlist(matrices, recursive = FALSE)
  }

  if (length(matrices) < 2) {
    stop("At least 2 matrices must be passed!")
  }

  m <- matrices[[1]]

  for (i in 2:length(matrices)) {
    m <- rbind_ngrams(m, matrices[[i]])
  }

  m
}









