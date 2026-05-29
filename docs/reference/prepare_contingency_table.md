# Prepare a contingency table from an edgelist

Pivots both `from` and `to` columns of an edgelist into a single
descriptor column and cross-tabulates against `group`, producing a
matrix suitable for correspondence analysis. Both endpoints of each edge
are treated as concept descriptors co-occurring with their group.

## Usage

``` r
prepare_contingency_table(edgelist)
```

## Arguments

- edgelist:

  A tibble with columns `group`, `from`, and `to`.

## Value

A numeric matrix with groups as rows and descriptors as columns.
Zero-sum rows and columns are removed.

## Details

The source data often uses raw column names (e.g. `hex1`, `hex2`); the
caller is responsible for renaming those to `from` and `to` before
passing the edgelist here.

## Examples

``` r
el <- tibble::tibble(
  group = c("A", "A", "B"),
  from  = c("x", "y", "x"),
  to    = c("y", "z", "z")
)
prepare_contingency_table(el)
#>    
#>     x y z
#>   A 1 2 1
#>   B 1 0 1
```
