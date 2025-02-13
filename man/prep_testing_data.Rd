% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/prep_testing_data.R
\name{prep_testing_data}
\alias{prep_testing_data}
\title{Align test data and apply fPCA using elastic method applied to training data}
\usage{
prep_testing_data(f, time, train_prep, optim_method = "DP")
}
\arguments{
\item{f}{Matrix (size M x N) of test data with N functions and M samples.}

\item{time}{Vector of size M describing the sample points}

\item{train_prep}{Object returned from applying "prep_training_data" to
training data.}

\item{optim_method}{Method used for optimization when computing the Karcher
mean. "DP", "DPo", and "RBFGS".}
}
\value{
List containing (varies slightly based on fpca method used):
\itemize{
  \item time: vector of times when functions are observed (length of M)
  \item f0: original test data functions - matrix (M x N) of N functions
        with M samples
  \item fn: aligned test data functions - similar structure to f0
  \item q0: original test data SRSFs - similar structure to f0
  \item qn: aligned test data SRSFs - similar structure to f0
  \item mqn: training data SRSF mean (test data functions are aligned to
        this function)
  \item gam: test data warping functions - similar structure to f0
  \item coef: test data principal component coefficients
  \item psi: test data warping function SRVFs - similar structure to f0
        (jfpca and hfpca only)
  \item nu: test data shooting functions - similar structure to f0 (jfpca
        and hfpca only)
  \item g: test data combination of aligned and shooting functions (jfpca
        only)
}
}
\description{
Applies steps 2 and 3 of the VEESA pipeline (alignment and elastic fPCA
    (jfpca, hfpca, or vfpca)) to the testing data based on the training
    data prepared using "prep_training_data".
}
\examples{
# Load packages
library(dplyr)
library(tidyr)

# Select a subset of functions from shifted peaks data
sub_ids <-
  shifted_peaks$data |>
  select(data, group, id) |>
  distinct() |>
  group_by(data, group) |>
  slice(1:5) |>
  ungroup()

# Create a smaller version of shifted data
shifted_peaks_sub <-
  shifted_peaks$data |>
  filter(id \%in\% sub_ids$id)

# Extract times
shifted_peaks_times = unique(shifted_peaks_sub$t)

# Convert training data to matrix
shifted_peaks_train_matrix <-
  shifted_peaks_sub |>
  filter(data == "Training") |>
  select(-t) |>
  mutate(index = paste0("t", index)) |>
  pivot_wider(names_from = index, values_from = y) |>
  select(-data, -id, -group) |>
  as.matrix() |>
  t()

# Obtain veesa pipeline training data
veesa_train <-
  prep_training_data(
    f = shifted_peaks_train_matrix,
    time = shifted_peaks_times,
    fpca_method = "jfpca"
  )

# Convert testing data to matrix
shifted_peaks_test_matrix <-
  shifted_peaks_sub |>
  filter(data == "Testing") |>
  select(-t) |>
  mutate(index = paste0("t", index)) |>
  pivot_wider(names_from = index, values_from = y) |>
  select(-data, -id, -group) |>
  as.matrix() |>
  t()

# Obtain veesa pipeline testing data
veesa_test <- prep_testing_data(
  f = shifted_peaks_test_matrix,
  time = shifted_peaks_times,
  train_prep = veesa_train,
  optim_method = "DP"
 )
}
