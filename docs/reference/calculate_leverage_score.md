# Calculate leverage scores and classify node roles

Derives a leverage score for each node by combining eigenvector
centrality, communicability betweenness (`cbet`), and Katz centrality
via dense ranking and min-max normalization. Each node is also
classified into one of eleven leverage roles based on how its centrality
profile compares to the rest of the network.

## Usage

``` r
calculate_leverage_score(network_metrics_tbl)
```

## Arguments

- network_metrics_tbl:

  A tibble as returned by
  [`calculate_network_metrics()`](https://centrcanon.github.io/centrcanon/reference/calculate_network_metrics.md),
  containing at minimum columns `eigen`, `cbet`, and `katz`.

## Value

The input tibble augmented with columns:

- eigen_z:

  double. Min-max scaled eigenvector centrality.

- katz_z:

  double. Min-max scaled Katz centrality.

- cbet_z:

  double. Min-max scaled communicability betweenness.

- rank_eigen:

  integer. Dense rank of `eigen_z`.

- rank_katz:

  integer. Dense rank of `katz_z`.

- rank_cbet:

  integer. Dense rank of `cbet_z`.

- rank_sum:

  integer. Sum of the three ranks.

- leverage_score:

  double. Normalized to \[0, 1\].

- tier:

  ordered factor. From
  [`calculate_tier()`](https://centrcanon.github.io/centrcanon/reference/calculate_tier.md).

- node_role:

  factor. One of `"Core Keystone"`, `"Supporting Keystone"`, `"Beacon"`,
  `"Steward"`, `"Aqueduct"`, `"Hybrid"`, `"Sage"`, `"Weaver"`,
  `"Messenger"`, `"Leaning"`, `"Non-Key"`.

## Details

Quantile thresholds used in role classification are computed over all
nodes in the supplied data, not hardcoded.

## Examples

``` r
if (FALSE) { # \dontrun{
g       <- create_network(edgelist)
metrics <- calculate_network_metrics(g)
calculate_leverage_score(metrics)
} # }
```
