# Three-layer color palette for CEnTR\*MAP analytical pipelines

A 3-color palette representing the three analytical pipelines. Gradient
helpers and theme code belong in the calling application, not this
package.

## Usage

``` r
centr_layer_palette()
```

## Value

A named character vector of hex color codes with names `"anchoring"`,
`"integration"`, and `"leverage"`.

## Examples

``` r
centr_layer_palette()
#>   anchoring integration    leverage 
#>   "#4A4A4A"   "#3A6F6A"   "#C6A15B" 
```
