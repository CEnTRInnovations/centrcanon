# Run correspondence analysis on a contingency table

A thin wrapper around
[`FactoMineR::CA()`](https://rdrr.io/pkg/FactoMineR/man/CA.html) that
suppresses the default plot.

## Usage

``` r
run_correspondence_analysis(contingency_table)
```

## Arguments

- contingency_table:

  A numeric matrix or `table` object with groups as rows and descriptors
  as columns, as produced by
  [`prepare_contingency_table()`](https://centrcanon.github.io/centrcanon/reference/prepare_contingency_table.md).

## Value

A `CA` object as returned by
[`FactoMineR::CA()`](https://rdrr.io/pkg/FactoMineR/man/CA.html).

## Examples

``` r
if (FALSE) { # \dontrun{
el <- tibble::tibble(
  group = c("A", "A", "B"),
  from  = c("x", "y", "x"),
  to    = c("y", "z", "z")
)
ct <- prepare_contingency_table(el)
run_correspondence_analysis(ct)
} # }
```
