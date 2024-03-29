% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/benchmark_ranking.R
\name{evaluate_filtering_results}
\alias{evaluate_filtering_results}
\title{Wrapper for `evaluate_selected_kmers` functions}
\usage{
evaluate_filtering_results(m, filtering_results, setup, validation_scheme)
}
\arguments{
\item{m}{k-mer matrix}

\item{filtering_results}{data.frame containing ranking of top k-mers}

\item{setup}{filter usage setup}

\item{validation_scheme}{list containing folds, n_kmers, cv_reps - validation setup}
}
\description{
Wrapper for `evaluate_selected_kmers` functions
}
