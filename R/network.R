#' Create an undirected network graph from an edgelist
#'
#' Builds an undirected [igraph::igraph] object from a two-column edgelist,
#' removing loops and multi-edges.
#'
#' The source data often uses capitalized column names (`From`, `To`); the
#' caller is responsible for renaming to lowercase `from` and `to` before
#' passing the edgelist here.
#'
#' @param edgelist A data frame or tibble with columns `from` and `to`.
#'   An optional `weight` column is preserved as an edge attribute if present.
#'
#' @return An undirected `igraph` object with loops and multi-edges removed.
#'
#' @examples
#' el <- tibble::tibble(
#'   from = c("a", "b", "a"),
#'   to   = c("b", "c", "c")
#' )
#' create_network(el)
#'
#' @export
create_network <- function(edgelist) {
  g <- igraph::graph_from_data_frame(edgelist, directed = FALSE)
  igraph::simplify(g, remove.multiple = TRUE, remove.loops = TRUE)
}


#' Calculate network centrality metrics
#'
#' Computes a suite of node-level centrality measures for an undirected graph.
#' Metrics from the `centiserve` package (`crossclique`, `cflow`, `cbet`,
#' `katz`) are optional; if the package is not installed those columns are set
#' to `NA_real_` with a warning.
#'
#' @param graph An undirected `igraph` object, as produced by
#'   [create_network()].
#'
#' @return A tibble with one row per node and columns:
#'   \describe{
#'     \item{name}{character. Node name.}
#'     \item{degree}{double. Normalized degree centrality.}
#'     \item{betweenness}{double. Normalized betweenness centrality.}
#'     \item{crossclique}{double. Cross-clique centrality (centiserve).}
#'     \item{cflow}{double. Current-flow closeness centrality (centiserve).}
#'     \item{cbet}{double. Communicability betweenness centrality (centiserve).}
#'     \item{eigen}{double. Eigenvector centrality.}
#'     \item{katz}{double. Katz centrality (centiserve).}
#'     \item{community}{factor. Optimal-modularity community membership.}
#'   }
#'
#' @examples
#' \dontrun{
#' el <- tibble::tibble(from = c("a", "b", "a"), to = c("b", "c", "c"))
#' g  <- create_network(el)
#' calculate_network_metrics(g)
#' }
#'
#' @export
calculate_network_metrics <- function(graph) {
  g <- graph

  if (is.null(igraph::V(g)$name)) {
    igraph::V(g)$name <- as.character(seq_len(igraph::vcount(g)))
  }

  safe_cs <- function(expr) {
    if (!requireNamespace("centiserve", quietly = TRUE)) {
      rlang::warn(paste0(
        "centiserve is not installed; metric set to NA. ",
        "Install from GitHub: muuankarski/centiserve"
      ))
      return(rep(NA_real_, igraph::vcount(g)))
    }
    tryCatch(
      expr,
      error = function(e) {
        rlang::warn(paste0(
          "centiserve metric failed: ", conditionMessage(e)
        ))
        rep(NA_real_, igraph::vcount(g))
      }
    )
  }

  community <- if (igraph::vcount(g) > 1L) {
    obj <- tryCatch(
      igraph::cluster_optimal(g),
      error = function(e) {
        rlang::warn(paste0(
          "Community detection failed: ", conditionMessage(e)
        ))
        list(membership = seq_len(igraph::vcount(g)))
      }
    )
    factor(obj$membership)
  } else {
    factor(1L)
  }

  tibble::tibble(
    name        = igraph::V(g)$name,
    degree      = igraph::degree(g, normalized = TRUE),
    betweenness = igraph::betweenness(g, normalized = TRUE),
    crossclique = safe_cs(centiserve::crossclique(g)),
    cflow       = safe_cs(centiserve::closeness.currentflow(g)),
    cbet        = safe_cs(centiserve::communibet(g, normalized = TRUE)),
    eigen       = igraph::eigen_centrality(g)$vector,
    katz        = safe_cs(centiserve::katzcent(g)),
    community   = community
  )
}
