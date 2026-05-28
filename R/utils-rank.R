#' Min-max scale a numeric vector
#'
#' Normalizes a numeric vector to the \[0, 1\] range using min-max scaling.
#' Returns `0.5` for constant input (all values identical).
#'
#' @param x A numeric vector.
#'
#' @return A double vector of the same length as `x`, scaled to \[0, 1\].
#'
#' @examples
#' minmax_scale(c(1, 2, 3, 4, 5))
#' minmax_scale(c(5, 5, 5))  # returns rep(0.5, 3)
#'
#' @export
minmax_scale <- function(x) {
  rng <- range(x, na.rm = TRUE)
  if (rng[1] == rng[2]) return(rep(0.5, length(x)))
  (x - rng[1]) / (rng[2] - rng[1])
}


#' Normalized Shannon entropy
#'
#' Computes Shannon entropy of a numeric vector, normalized by `log(n)` where
#' `n` is the length of `values`. Returns a scalar in \[0, 1\].
#' Returns `0` for single-element vectors (entropy is undefined; treated as
#' minimum).
#'
#' @param values A numeric vector of non-negative values.
#'
#' @return A double scalar in \[0, 1\].
#'
#' @examples
#' calculate_entropy(c(1, 1, 1))    # maximum entropy -> 1
#' calculate_entropy(c(10, 0, 0))   # minimum entropy -> 0
#'
#' @export
calculate_entropy <- function(values) {
  n <- length(values)
  if (n <= 1L) return(0)
  values <- values + .Machine$double.eps
  values <- values / sum(values)
  raw <- -sum(values * log(values))
  raw / log(n)
}


#' Dense-rank normalize a numeric vector
#'
#' Applies dense ranking (ties share the same rank) and then normalizes ranks
#' to \[0, 1\] via [minmax_scale()].
#'
#' @param x A numeric vector.
#'
#' @return A double vector of the same length as `x`, in \[0, 1\].
#'
#' @examples
#' dense_rank_normalize(c(3, 1, 4, 1, 5))
#'
#' @export
dense_rank_normalize <- function(x) {
  minmax_scale(dplyr::dense_rank(x))
}
