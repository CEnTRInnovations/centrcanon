# Calculate network centrality metrics

Computes a suite of node-level centrality measures for an undirected
graph. All metrics are computed using `igraph` and base R; no optional
packages are required.

## Usage

``` r
calculate_network_metrics(graph)
```

## Arguments

- graph:

  An undirected `igraph` object, as produced by
  [`create_network()`](https://centrcanon.github.io/centrcanon/reference/create_network.md).

## Value

A tibble with one row per node and columns:

- name:

  character. Node name.

- degree:

  double. Normalized degree centrality.

- betweenness:

  double. Normalized betweenness centrality.

- crossclique:

  double. Cross-clique centrality.

- cflow:

  double. Current-flow closeness centrality.

- cbet:

  double. Communicability betweenness centrality (normalized).

- eigen:

  double. Eigenvector centrality.

- katz:

  double. Katz centrality.

- community:

  factor. Optimal-modularity community membership.

## Examples

``` r
if (FALSE) { # \dontrun{
el <- tibble::tibble(
  from = c("a", "b", "a"),
  to   = c("b", "c", "c")
)
g  <- create_network(el)
calculate_network_metrics(g)
} # }
```
