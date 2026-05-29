# Dense-rank normalize a numeric vector

Applies dense ranking (ties share the same rank) and then normalizes
ranks to \[0, 1\] via
[`minmax_scale()`](https://centrcanon.github.io/centrcanon/reference/minmax_scale.md).

## Usage

``` r
dense_rank_normalize(x)
```

## Arguments

- x:

  A numeric vector.

## Value

A double vector of the same length as `x`, in \[0, 1\].

## Examples

``` r
dense_rank_normalize(c(3, 1, 4, 1, 5))
#> [1] 0.3333333 0.0000000 0.6666667 0.0000000 1.0000000
```
