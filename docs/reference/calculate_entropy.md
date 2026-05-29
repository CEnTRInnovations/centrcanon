# Normalized Shannon entropy

Computes Shannon entropy of a numeric vector, normalized by `log(n)`
where `n` is the length of `values`. Returns a scalar in \[0, 1\].
Returns `0` for single-element vectors (entropy is undefined; treated as
minimum).

## Usage

``` r
calculate_entropy(values)
```

## Arguments

- values:

  A numeric vector of non-negative values.

## Value

A double scalar in \[0, 1\].

## Examples

``` r
calculate_entropy(c(1, 1, 1))    # maximum entropy -> 1
#> [1] 1
calculate_entropy(c(10, 0, 0))   # minimum entropy -> 0
#> [1] 1.55006e-15
```
