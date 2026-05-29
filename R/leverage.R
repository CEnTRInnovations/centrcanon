# Classify nodes into leverage quadrants based on degree and eigenvector
# centrality. Nodes at or above the median on an axis are treated as "high".
# Vectorized — all four arguments may be equal-length vectors or length-1
# scalars.
#
# @param degree,eigen_centrality Numeric vectors. Normalized centrality values.
# @param degree_median,eigen_median Numeric scalars. Median thresholds.
#
# @return Character vector of quadrant labels, same length as `degree`.
# @noRd
classify_leverage_quadrant <- function(degree, eigen_centrality,
                                       degree_median, eigen_median) {
  high_degree <- degree >= degree_median
  high_eigen  <- eigen_centrality >= eigen_median
  dplyr::case_when(
    high_degree  & high_eigen  ~ "Shared Foundation",
    !high_degree & high_eigen  ~ "Connective Concept",
    high_degree  & !high_eigen ~ "Community Voice",
    TRUE                       ~ "Emerging Vocabulary"
  )
}


#' Calculate leverage scores and classify nodes into quadrants
#'
#' Derives a leverage score for each node from degree and eigenvector
#' centrality, then classifies each node into one of four CEnR-grounded
#' structural roles using a Degree x Eigenvector quadrant analysis.
#' Quadrant thresholds are the medians of each axis across all nodes in the
#' supplied data.
#'
#' @param network_metrics_tbl A tibble as returned by
#'   [calculate_network_metrics()], containing at minimum columns `degree`
#'   and `eigen`.
#'
#' @return The input tibble augmented with columns:
#'   \describe{
#'     \item{eigen_centrality}{double. Min-max scaled eigenvector centrality,
#'       in \[0, 1\].}
#'     \item{leverage_score}{double. Min-max scaled sum of normalized degree
#'       and `eigen_centrality`, in \[0, 1\]. Used for tier assignment.}
#'     \item{tier}{ordered factor. From [calculate_tier()].}
#'     \item{leverage_quadrant}{factor. One of `"Shared Foundation"`,
#'       `"Connective Concept"`, `"Community Voice"`,
#'       `"Emerging Vocabulary"`. Quadrant thresholds are the medians of
#'       each axis.}
#'   }
#'
#' @examples
#' \dontrun{
#' g       <- create_network(edgelist)
#' metrics <- calculate_network_metrics(g)
#' calculate_leverage_score(metrics)
#' }
#'
#' @export
calculate_leverage_score <- function(network_metrics_tbl) {
  quadrant_levels <- c(
    "Shared Foundation", "Connective Concept",
    "Community Voice", "Emerging Vocabulary"
  )

  tbl <- network_metrics_tbl |>
    dplyr::mutate(
      eigen_centrality = minmax_scale(.data$eigen)
    )

  deg_med   <- stats::median(tbl$degree, na.rm = TRUE)
  eigen_med <- stats::median(tbl$eigen_centrality, na.rm = TRUE)

  tbl |>
    dplyr::mutate(
      leverage_score    = minmax_scale(
        .data$degree + .data$eigen_centrality
      ),
      tier              = calculate_tier(.data$leverage_score),
      leverage_quadrant = factor(
        classify_leverage_quadrant(
          .data$degree, .data$eigen_centrality, deg_med, eigen_med
        ),
        levels = quadrant_levels
      )
    )
}
