# Classify a single node into a leverage role.
#
# Internal helper. Quantile thresholds are passed as arguments so that tests
# can inject known values without needing a full dataset.
#
# @param eigen_z,cbet_z,katz_z Normalized centrality values for one node.
# @param q25,q75,q90 Named numeric vectors with elements `eigen`, `cbet`,
#   `katz` giving the dataset-level quantile thresholds.
#
# @return A character scalar role name.
# @noRd
classify_node_role <- function(eigen_z, cbet_z, katz_z, q25, q75, q90) {
  if (anyNA(c(eigen_z, cbet_z, katz_z))) return("Leaning")
  vals <- c(eigen_z, cbet_z, katz_z)

  above90 <- vals >= c(q90[["eigen"]], q90[["cbet"]], q90[["katz"]])
  above75 <- vals >= c(q75[["eigen"]], q75[["cbet"]], q75[["katz"]])
  below25 <- vals <= c(q25[["eigen"]], q25[["cbet"]], q25[["katz"]])

  entropy_ratio <- calculate_entropy(vals)

  # Determine the paired type when two or all three are above q75.
  # Order of precedence: eigen+katz -> Beacon, eigen+cbet -> Steward,
  # cbet+katz -> Aqueduct, else Hybrid.
  paired_type <- function(flags) {
    if (flags[[1]] && flags[[3]]) "Beacon"
    else if (flags[[1]] && flags[[2]]) "Steward"
    else if (flags[[2]] && flags[[3]]) "Aqueduct"
    else "Hybrid"
  }

  if (all(above90)) {
    "Core Keystone"
  } else if (all(above75) && entropy_ratio >= 0.9) {
    "Supporting Keystone"
  } else if (all(above75) && entropy_ratio < 0.9) {
    paired_type(above75)
  } else if (all(below25)) {
    "Non-Key"
  } else {
    n_high <- sum(above75)
    if (n_high == 1L) {
      c("Sage", "Weaver", "Messenger")[which(above75)[1L]]
    } else if (n_high >= 2L) {
      paired_type(above75)
    } else {
      "Leaning"
    }
  }
}


#' Calculate leverage scores and classify node roles
#'
#' Derives a leverage score for each node by combining eigenvector centrality,
#' communicability betweenness (`cbet`), and Katz centrality via dense ranking
#' and min-max normalization. Each node is also classified into one of eleven
#' leverage roles based on how its centrality profile compares to the rest of
#' the network.
#'
#' Quantile thresholds used in role classification are computed over all nodes
#' in the supplied data, not hardcoded.
#'
#' @param network_metrics_tbl A tibble as returned by
#'   [calculate_network_metrics()], containing at minimum columns `eigen`,
#'   `cbet`, and `katz`.
#'
#' @return The input tibble augmented with columns:
#'   \describe{
#'     \item{eigen_z}{double. Min-max scaled eigenvector centrality.}
#'     \item{katz_z}{double. Min-max scaled Katz centrality.}
#'     \item{cbet_z}{double. Min-max scaled communicability betweenness.}
#'     \item{rank_eigen}{integer. Dense rank of `eigen_z`.}
#'     \item{rank_katz}{integer. Dense rank of `katz_z`.}
#'     \item{rank_cbet}{integer. Dense rank of `cbet_z`.}
#'     \item{rank_sum}{integer. Sum of the three ranks.}
#'     \item{leverage_score}{double. Normalized to \[0, 1\].}
#'     \item{tier}{ordered factor. From [calculate_tier()].}
#'     \item{node_role}{factor. One of `"Core Keystone"`,
#'       `"Supporting Keystone"`, `"Beacon"`, `"Steward"`, `"Aqueduct"`,
#'       `"Hybrid"`, `"Sage"`, `"Weaver"`, `"Messenger"`, `"Leaning"`,
#'       `"Non-Key"`.}
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
  tbl <- network_metrics_tbl |>
    dplyr::mutate(
      eigen_z = minmax_scale(.data$eigen),
      katz_z  = minmax_scale(.data$katz),
      cbet_z  = minmax_scale(.data$cbet)
    )

  # Dataset-level quantile thresholds for role classification
  q <- function(col, p) unname(stats::quantile(col, probs = p, na.rm = TRUE))
  q25 <- c(eigen = q(tbl$eigen_z, 0.25),
           cbet  = q(tbl$cbet_z,  0.25),
           katz  = q(tbl$katz_z,  0.25))
  q75 <- c(eigen = q(tbl$eigen_z, 0.75),
           cbet  = q(tbl$cbet_z,  0.75),
           katz  = q(tbl$katz_z,  0.75))
  q90 <- c(eigen = q(tbl$eigen_z, 0.90),
           cbet  = q(tbl$cbet_z,  0.90),
           katz  = q(tbl$katz_z,  0.90))

  node_roles <- mapply(
    FUN      = classify_node_role,
    eigen_z  = tbl$eigen_z,
    cbet_z   = tbl$cbet_z,
    katz_z   = tbl$katz_z,
    MoreArgs = list(q25 = q25, q75 = q75, q90 = q90),
    USE.NAMES = FALSE
  )

  role_levels <- c(
    "Core Keystone", "Supporting Keystone",
    "Beacon", "Steward", "Aqueduct", "Hybrid",
    "Sage", "Weaver", "Messenger",
    "Leaning", "Non-Key"
  )

  tbl |>
    dplyr::mutate(
      rank_eigen     = dplyr::dense_rank(.data$eigen_z),
      rank_katz      = dplyr::dense_rank(.data$katz_z),
      rank_cbet      = dplyr::dense_rank(.data$cbet_z),
      rank_sum       = .data$rank_eigen + .data$rank_katz + .data$rank_cbet,
      leverage_score = minmax_scale(.data$rank_sum),
      tier           = calculate_tier(.data$leverage_score),
      node_role      = factor(node_roles, levels = role_levels)
    )
}
