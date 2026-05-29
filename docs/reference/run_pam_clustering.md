# Run PAM clustering on CA column coordinates

Clusters concept descriptors using Partition Around Medoids (PAM)
applied to the first two dimensions of a correspondence analysis result.

## Usage

``` r
run_pam_clustering(ca_result, k = 6L)
```

## Arguments

- ca_result:

  A `CA` object from
  [`run_correspondence_analysis()`](https://centrcanon.github.io/centrcanon/reference/run_correspondence_analysis.md).

- k:

  Integer. Number of clusters. Defaults to `6L`.

## Value

A `pam` object from
[`cluster::pam()`](https://rdrr.io/pkg/cluster/man/pam.html).

## Details

Note: cluster IDs in the returned object are integers. Human-readable
cluster labels are the caller's responsibility and should not be
hardcoded in downstream package functions.

## Examples

``` r
if (FALSE) { # \dontrun{
ct  <- prepare_contingency_table(edgelist)
ca  <- run_correspondence_analysis(ct)
run_pam_clustering(ca, k = 6L)
} # }
```
