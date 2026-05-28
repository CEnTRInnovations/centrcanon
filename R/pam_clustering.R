#' Run PAM clustering on CA column coordinates
#'
#' Clusters concept descriptors using Partition Around Medoids (PAM) applied
#' to the first two dimensions of a correspondence analysis result.
#'
#' Note: cluster IDs in the returned object are integers. Human-readable
#' cluster labels are the caller's responsibility and should not be hardcoded
#' in downstream package functions.
#'
#' @param ca_result A `CA` object from [run_correspondence_analysis()].
#' @param k Integer. Number of clusters. Defaults to `6L`.
#'
#' @return A `pam` object from [cluster::pam()].
#'
#' @examples
#' \dontrun{
#' ct  <- prepare_contingency_table(edgelist)
#' ca  <- run_correspondence_analysis(ct)
#' run_pam_clustering(ca, k = 6L)
#' }
#'
#' @export
run_pam_clustering <- function(ca_result, k = 6L) {
  coords <- ca_result$col$coord[, 1:2, drop = FALSE]
  cluster::pam(coords, k = as.integer(k))
}
