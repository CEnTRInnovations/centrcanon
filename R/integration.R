#' Calculate integration scores from network metrics
#'
#' Derives an integration score for each node by combining betweenness
#' centrality, current-flow closeness, and cross-clique centrality via dense
#' ranking and min-max normalization.
#'
#' @param network_metrics_tbl A tibble as returned by
#'   [calculate_network_metrics()], containing at minimum columns
#'   `betweenness`, `cflow`, and `crossclique`.
#'
#' @return The input tibble augmented with columns:
#'   \describe{
#'     \item{betweenness_scaled}{double. Min-max scaled betweenness.}
#'     \item{cflow_scaled}{double. Min-max scaled current-flow closeness.}
#'     \item{crossclique_scaled}{double. Min-max scaled cross-clique.}
#'     \item{rank_betweenness}{integer. Dense rank of `betweenness_scaled`.}
#'     \item{rank_cflow}{integer. Dense rank of `cflow_scaled`.}
#'     \item{rank_crossclique}{integer. Dense rank of `crossclique_scaled`.}
#'     \item{rank_sum}{integer. Sum of the three ranks.}
#'     \item{integration_score}{double. Normalized to \[0, 1\].}
#'     \item{tier}{ordered factor. From [calculate_tier()].}
#'   }
#'
#' @examples
#' \dontrun{
#' g       <- create_network(edgelist)
#' metrics <- calculate_network_metrics(g)
#' calculate_integration_score(metrics)
#' }
#'
#' @export
calculate_integration_score <- function(network_metrics_tbl) {
  network_metrics_tbl |>
    dplyr::mutate(
      betweenness_scaled = minmax_scale(.data$betweenness),
      cflow_scaled       = minmax_scale(.data$cflow),
      crossclique_scaled = minmax_scale(.data$crossclique),
      rank_betweenness   = dplyr::dense_rank(.data$betweenness_scaled),
      rank_cflow         = dplyr::dense_rank(.data$cflow_scaled),
      rank_crossclique   = dplyr::dense_rank(.data$crossclique_scaled),
      rank_sum           = (
        .data$rank_betweenness +
        .data$rank_cflow +
        .data$rank_crossclique
      ),
      integration_score  = minmax_scale(.data$rank_sum),
      tier               = calculate_tier(.data$integration_score)
    )
}
