# Min-max scale a numeric vector

Normalizes a numeric vector to the \[0, 1\] range using min-max scaling.
Returns `0.5` for constant input (all values identical).

## Usage

``` r
minmax_scale(x)
```

## Arguments

- x:

  A numeric vector.

## Value

A double vector of the same length as `x`, scaled to \[0, 1\].

## Examples

``` r
minmax_scale(c(1, 2, 3, 4, 5))
#> [1] 0.00 0.25 0.50 0.75 1.00
minmax_scale(c(5, 5, 5))  # returns rep(0.5, 3)
#> [1] 0.5 0.5 0.5
```
