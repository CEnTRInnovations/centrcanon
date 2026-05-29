# Create an undirected network graph from an edgelist

Builds an undirected
[igraph::igraph](https://r.igraph.org/reference/aaa-igraph-package.html)
object from a two-column edgelist, removing loops and multi-edges.

## Usage

``` r
create_network(edgelist)
```

## Arguments

- edgelist:

  A data frame or tibble with columns `from` and `to`. An optional
  `weight` column is preserved as an edge attribute if present.

## Value

An undirected `igraph` object with loops and multi-edges removed.

## Details

The source data often uses capitalized column names (`From`, `To`); the
caller is responsible for renaming to lowercase `from` and `to` before
passing the edgelist here.

## Examples

``` r
el <- tibble::tibble(
  from = c("a", "b", "a"),
  to   = c("b", "c", "c")
)
create_network(el)
#> IGRAPH 77830c0 UN-- 3 3 -- 
#> + attr: name (v/c)
#> + edges from 77830c0 (vertex names):
#> [1] a--b a--c b--c
```
