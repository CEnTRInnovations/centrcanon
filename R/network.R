# Private helper: Moore-Penrose pseudoinverse of a real symmetric matrix.
# Uses eigendecomposition with a relative tolerance for near-zero eigenvalues.
.pinv_sym <- function(M) {
  e   <- eigen(M, symmetric = TRUE)
  tol <- max(dim(M)) * .Machine$double.eps * max(abs(e$values))
  d_inv <- ifelse(abs(e$values) > tol, 1 / e$values, 0)
  e$vectors %*% diag(d_inv, nrow = length(d_inv)) %*% t(e$vectors)
}

# Private helper: Katz centrality.
# alpha = 1 / (spectral_radius + 1), matching centiserve::katzcent().
# Returns the vector (I - alpha*A)^{-1} * 1 - 1.
.katz_centrality <- function(g) {
  n <- igraph::vcount(g)
  if (n == 0L) return(numeric(0))
  max_ev <- igraph::eigen_centrality(g)$value
  alpha  <- 1 / (max_ev + 1)
  A      <- as.matrix(igraph::as_adjacency_matrix(g))
  as.vector(solve(diag(n) - alpha * A) %*% rep(1, n)) - 1
}

# Private helper: cross-clique centrality.
# Counts the number of cliques of size >= 2 each node participates in,
# matching the centiserve::crossclique() approach.
.crossclique_centrality <- function(g) {
  n    <- igraph::vcount(g)
  clqs <- igraph::cliques(g, min = 2)
  counts <- integer(n)
  for (cl in clqs) counts[as.integer(cl)] <- counts[as.integer(cl)] + 1L
  as.double(counts)
}

# Private helper: current-flow closeness centrality.
# C_CF(v) = (n-1) / (n * L†[v,v] + tr(L†)), derived from the effective
# resistance formula R_{vt} = L†[v,v] + L†[t,t] - 2*L†[v,t] and the
# identity that row sums of L† are zero. Returns NA for single-node graphs.
.current_flow_closeness <- function(g) {
  n <- igraph::vcount(g)
  if (n <= 1L) return(rep(NA_real_, n))
  L  <- as.matrix(igraph::laplacian_matrix(g))
  Lp <- .pinv_sym(L)
  (n - 1) / (n * diag(Lp) + sum(diag(Lp)))
}

# Private helper: communicability betweenness centrality.
# Uses eigendecomposition of the symmetric adjacency matrix to compute
# expm(A), then sums the fraction of communicability paths through each node.
# Normalized by (n-1)(n-2) (ordered s != t pairs, both != i).
# Returns zeros for n <= 2 (normalization is undefined).
.communicability_betweenness <- function(g, normalized = TRUE) {
  n <- igraph::vcount(g)
  if (n <= 2L) return(rep(0, n))
  A <- as.matrix(igraph::as_adjacency_matrix(g))
  e <- eigen(A, symmetric = TRUE)
  G <- e$vectors %*%
    diag(exp(e$values), nrow = length(e$values)) %*%
    t(e$vectors)
  CB <- numeric(n)
  for (i in seq_len(n)) {
    idx       <- seq_len(n)[-i]
    G_sub     <- G[idx, idx, drop = FALSE]
    numer     <- outer(G[idx, i], G[i, idx])
    diag(numer) <- 0  # exclude s == t pairs
    CB[i]     <- sum(ifelse(G_sub > 0, numer / G_sub, 0))
  }
  if (normalized) CB <- CB / ((n - 1L) * (n - 2L))
  CB
}


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
#' All metrics are computed using `igraph` and base R; no optional packages
#' are required.
#'
#' @param graph An undirected `igraph` object, as produced by
#'   [create_network()].
#'
#' @return A tibble with one row per node and columns:
#'   \describe{
#'     \item{name}{character. Node name.}
#'     \item{degree}{double. Normalized degree centrality.}
#'     \item{betweenness}{double. Normalized betweenness centrality.}
#'     \item{crossclique}{double. Cross-clique centrality.}
#'     \item{cflow}{double. Current-flow closeness centrality.}
#'     \item{cbet}{double. Communicability betweenness centrality (normalized).}
#'     \item{eigen}{double. Eigenvector centrality.}
#'     \item{katz}{double. Katz centrality.}
#'     \item{community}{factor. Optimal-modularity community membership.}
#'   }
#'
#' @examples
#' \dontrun{
#' el <- tibble::tibble(
#'   from = c("a", "b", "a"),
#'   to   = c("b", "c", "c")
#' )
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

  n <- igraph::vcount(g)

  safe_metric <- function(expr) {
    tryCatch(
      expr,
      error = function(e) {
        rlang::warn(paste0("Network metric failed: ", conditionMessage(e)))
        rep(NA_real_, n)
      }
    )
  }

  community <- if (n > 1L) {
    obj <- tryCatch(
      igraph::cluster_optimal(g),
      error = function(e) {
        rlang::warn(paste0(
          "Community detection failed: ", conditionMessage(e)
        ))
        list(membership = seq_len(n))
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
    crossclique = safe_metric(.crossclique_centrality(g)),
    cflow       = safe_metric(.current_flow_closeness(g)),
    cbet        = safe_metric(.communicability_betweenness(g, normalized = TRUE)),
    eigen       = igraph::eigen_centrality(g)$vector,
    katz        = safe_metric(.katz_centrality(g)),
    community   = community
  )
}
