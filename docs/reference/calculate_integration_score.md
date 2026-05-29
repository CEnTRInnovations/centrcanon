# Calculate integration scores from network metrics

Derives an integration score for each node by combining betweenness
centrality, current-flow closeness, and cross-clique centrality via
dense ranking and min-max normalization.

## Usage

``` r
calculate_integration_score(network_metrics_tbl)
```

## Arguments

- network_metrics_tbl:

  A tibble as returned by
  [`calculate_network_metrics()`](https://centrcanon.github.io/centrcanon/reference/calculate_network_metrics.md),
  containing at minimum columns `betweenness`, `cflow`, and
  `crossclique`.

## Value

The input tibble augmented with columns:

- betweenness_scaled:

  double. Min-max scaled betweenness.

- cflow_scaled:

  double. Min-max scaled current-flow closeness.

- crossclique_scaled:

  double. Min-max scaled cross-clique.

- rank_betweenness:

  integer. Dense rank of `betweenness_scaled`.

- rank_cflow:

  integer. Dense rank of `cflow_scaled`.

- rank_crossclique:

  integer. Dense rank of `crossclique_scaled`.

- rank_sum:

  integer. Sum of the three ranks.

- integration_score:

  double. Normalized to \[0, 1\].

- tier:

  ordered factor. From
  [`calculate_tier()`](https://centrcanon.github.io/centrcanon/reference/calculate_tier.md).

## Examples

``` r
if (FALSE) { # \dontrun{
g       <- create_network(edgelist)
metrics <- calculate_network_metrics(g)
calculate_integration_score(metrics)
} # }
```
