# Minimal synthetic fixtures for centrcanon tests.
# No external files required — all data is constructed in-line.

#' A small edgelist with three groups and five concept nodes
make_edgelist <- function() {
  tibble::tibble(
    group = c("A", "A", "A", "B", "B", "C"),
    from  = c("alpha", "beta",  "alpha", "gamma", "alpha", "beta"),
    to    = c("beta",  "gamma", "gamma", "delta", "delta", "delta")
  )
}

#' A small connected 5-node igraph (no centiserve required)
make_graph <- function() {
  el <- tibble::tibble(
    from = c("a", "b", "c", "d", "a", "c"),
    to   = c("b", "c", "d", "e", "c", "e")
  )
  create_network(el)
}

#' A CA + PAM result pair built from make_edgelist()
make_ca_pam <- function(k = 2L) {
  el  <- make_edgelist()
  ct  <- prepare_contingency_table(el)
  ca  <- run_correspondence_analysis(ct)
  pam <- run_pam_clustering(ca, k = k)
  list(ca = ca, pam = pam)
}

#' Two isolated edges {a-b} and {c-d} — no path between the two components
make_disconnected_graph <- function() {
  create_network(tibble::tibble(
    from = c("a", "c"),
    to   = c("b", "d")
  ))
}
