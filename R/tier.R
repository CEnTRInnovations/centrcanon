#' Classify scores into performance tiers
#'
#' Cuts a numeric score vector into four ordered tiers using the 40th, 60th,
#' and 80th percentiles as break points.
#'
#' @param scores A numeric vector of scores.
#'
#' @return An ordered factor with levels
#'   `"Low" < "Medium" < "High" < "Very High"`.
#'
#' @details
#' Quantile type 1 (inverse empirical CDF) is used so that break points are
#' always actual observed values rather than interpolated midpoints. This
#' ensures a score exactly at the 40th percentile falls into "Medium", not
#' "Low".
#'
#' @examples
#' calculate_tier(c(0.1, 0.3, 0.5, 0.7, 0.9))
#'
#' @export
calculate_tier <- function(scores) {
  tier_labels <- c("Low", "Medium", "High", "Very High")
  raw_breaks <- stats::quantile(
    scores, probs = c(0.4, 0.6, 0.8), na.rm = TRUE, type = 1
  )
  # Guard: duplicate breaks crash cut() when percentiles coincide on tied data.
  breaks <- unique(c(-Inf, raw_breaks, Inf))
  n_intervals <- length(breaks) - 1L
  labels <- tier_labels[
    (length(tier_labels) - n_intervals + 1L):length(tier_labels)
  ]
  cut(
    scores,
    breaks         = breaks,
    labels         = labels,
    include.lowest = TRUE,
    right          = FALSE,
    ordered_result = TRUE
  )
}
