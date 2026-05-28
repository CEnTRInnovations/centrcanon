#' Calculate conceptual anchoring scores
#'
#' Combines three sub-scores — salience, dimensional definition, and cluster
#' exemplar proximity — into a normalized anchoring score for each concept
#' descriptor identified in a correspondence analysis.
#'
#' Sub-scores are equally weighted. All three are dense-ranked, summed, and
#' min-max normalized to produce `anchoring_score`.
#'
#' @param ca_result A `CA` object from [run_correspondence_analysis()].
#' @param cluster_assignments An integer vector of PAM cluster IDs, one per
#'   concept (i.e. `pam_result$clustering`).
#'
#' @return A tibble with one row per concept and columns:
#'   \describe{
#'     \item{concept}{character. Concept / descriptor name.}
#'     \item{cluster}{integer. PAM cluster ID.}
#'     \item{salience_raw}{double. CA column inertia.}
#'     \item{dimensional_raw}{double. Sum of contributions to CA dims 1 & 2.}
#'     \item{cluster_exemplar_raw}{double. Proximity-weighted cos2 score.}
#'     \item{rank_salience}{integer. Dense rank of `salience_raw`.}
#'     \item{rank_dimensional}{integer. Dense rank of `dimensional_raw`.}
#'     \item{rank_exemplar}{integer. Dense rank of `cluster_exemplar_raw`.}
#'     \item{combined_rank}{double. Mean of the three ranks.}
#'     \item{anchoring_score}{double. Normalized to \[0, 1\].}
#'     \item{percentile_rank}{double. 0–100.}
#'     \item{anchoring_category}{ordered factor.
#'       `"Peripheral Element" < "Supporting Element" <
#'       "Secondary Anchor" < "Primary Anchor"`.}
#'     \item{tier}{ordered factor. From [calculate_tier()].}
#'   }
#'
#' @examples
#' \dontrun{
#' ct  <- prepare_contingency_table(edgelist)
#' ca  <- run_correspondence_analysis(ct)
#' pam <- run_pam_clustering(ca)
#' calculate_anchoring_score(ca, pam$clustering)
#' }
#'
#' @export
calculate_anchoring_score <- function(ca_result, cluster_assignments) {
  if (is.null(ca_result$col$inertia)) {
    rlang::abort("No inertia values found in CA result.")
  }

  n_concepts    <- nrow(ca_result$col$coord)
  concept_names <- rownames(ca_result$col$coord)
  coords        <- ca_result$col$coord[, 1:2, drop = FALSE]
  cos2_total    <- rowSums(ca_result$col$cos2[, 1:2, drop = FALSE])

  # --- Salience: CA column inertia ---
  sal_raw <- ca_result$col$inertia

  # --- Dimensional definition: sum of contributions to dims 1 & 2 ---
  contrib     <- ca_result$col$contrib[, 1:2, drop = FALSE]
  dimensional_raw <- contrib[, 1] + contrib[, 2]

  # --- Cluster exemplar: proximity to cluster medoid, weighted by cos2 ---
  exemplar_raw <- numeric(n_concepts)

  for (clust in unique(cluster_assignments)) {
    idx <- which(cluster_assignments == clust)

    if (length(idx) == 1L) {
      exemplar_raw[idx] <- cos2_total[idx]
    } else {
      clust_coords <- coords[idx, , drop = FALSE]
      centroid     <- apply(clust_coords, 2, stats::median)
      centroid_mat <- matrix(
        centroid,
        nrow  = length(idx),
        ncol  = 2L,
        byrow = TRUE
      )
      distances <- sqrt(rowSums((clust_coords - centroid_mat)^2))
      max_dist  <- max(distances)
      if (max_dist > 0) {
        exemplar_raw[idx] <- (1 - distances / max_dist) * cos2_total[idx]
      } else {
        exemplar_raw[idx] <- cos2_total[idx]
      }
    }
  }

  tibble::tibble(
    concept              = concept_names,
    cluster              = as.integer(cluster_assignments),
    salience_raw         = sal_raw,
    dimensional_raw      = dimensional_raw,
    cluster_exemplar_raw = exemplar_raw
  ) |>
    dplyr::mutate(
      rank_salience    = dplyr::dense_rank(.data$salience_raw),
      rank_dimensional = dplyr::dense_rank(.data$dimensional_raw),
      rank_exemplar    = dplyr::dense_rank(.data$cluster_exemplar_raw),
      combined_rank    = (
        .data$rank_salience +
        .data$rank_dimensional +
        .data$rank_exemplar
      ) / 3,
      anchoring_score    = minmax_scale(.data$combined_rank),
      percentile_rank    = dplyr::percent_rank(.data$anchoring_score) * 100,
      anchoring_category = factor(
        dplyr::case_when(
          .data$percentile_rank >= 80 ~ "Primary Anchor",
          .data$percentile_rank >= 60 ~ "Secondary Anchor",
          .data$percentile_rank >= 40 ~ "Supporting Element",
          TRUE                        ~ "Peripheral Element"
        ),
        levels = c(
          "Peripheral Element", "Supporting Element",
          "Secondary Anchor",   "Primary Anchor"
        ),
        ordered = TRUE
      ),
      tier = calculate_tier(.data$anchoring_score)
    )
}
