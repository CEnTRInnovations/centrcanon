# Classify scores into performance tiers

Cuts a numeric score vector into four ordered tiers using the 40th,
60th, and 80th percentiles as break points.

## Usage

``` r
calculate_tier(scores)
```

## Arguments

- scores:

  A numeric vector of scores.

## Value

An ordered factor with levels `"Low" < "Medium" < "High" < "Very High"`.

## Details

Quantile type 1 (inverse empirical CDF) is used so that break points are
always actual observed values rather than interpolated midpoints. This
ensures a score exactly at the 40th percentile falls into "Medium", not
"Low".

## Examples

``` r
calculate_tier(c(0.1, 0.3, 0.5, 0.7, 0.9))
#> [1] Low       Medium    High      Very High Very High
#> Levels: Low < Medium < High < Very High
```
