#' Prepare a contingency table from an edgelist
#'
#' Pivots both `from` and `to` columns of an edgelist into a single descriptor
#' column and cross-tabulates against `group`, producing a matrix suitable for
#' correspondence analysis. Both endpoints of each edge are treated as concept
#' descriptors co-occurring with their group.
#'
#' The source data often uses raw column names (e.g. `hex1`, `hex2`); the
#' caller is responsible for renaming those to `from` and `to` before passing
#' the edgelist here.
#'
#' @param edgelist A tibble with columns `group`, `from`, and `to`.
#'
#' @return A numeric matrix with groups as rows and descriptors as columns.
#'   Zero-sum rows and columns are removed.
#'
#' @examples
#' el <- tibble::tibble(
#'   group = c("A", "A", "B"),
#'   from  = c("x", "y", "x"),
#'   to    = c("y", "z", "z")
#' )
#' prepare_contingency_table(el)
#'
#' @export
prepare_contingency_table <- function(edgelist) {
  long <- edgelist |>
    tidyr::pivot_longer(
      cols      = c("from", "to"),
      names_to  = "endpoint",
      values_to = "descriptor"
    ) |>
    dplyr::select("group", "descriptor") |>
    dplyr::filter(
      !is.na(.data$descriptor),
      .data$descriptor != ""
    )

  tbl <- table(long$group, long$descriptor)
  tbl[rowSums(tbl) > 0, colSums(tbl) > 0, drop = FALSE]
}


#' Run correspondence analysis on a contingency table
#'
#' A thin wrapper around [FactoMineR::CA()] that suppresses the default plot.
#'
#' @param contingency_table A numeric matrix or `table` object with groups as
#'   rows and descriptors as columns, as produced by
#'   [prepare_contingency_table()].
#'
#' @return A `CA` object as returned by [FactoMineR::CA()].
#'
#' @examples
#' \dontrun{
#' el <- tibble::tibble(
#'   group = c("A", "A", "B"),
#'   from  = c("x", "y", "x"),
#'   to    = c("y", "z", "z")
#' )
#' ct <- prepare_contingency_table(el)
#' run_correspondence_analysis(ct)
#' }
#'
#' @export
run_correspondence_analysis <- function(contingency_table) {
  FactoMineR::CA(contingency_table, graph = FALSE)
}
