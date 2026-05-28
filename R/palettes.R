#' Earthtone color palette for CEnTR*MAP
#'
#' An 8-color earthtone palette for coloring PAM clusters and node roles in
#' visualizations. Gradient helpers and theme code belong in the calling
#' application, not this package.
#'
#' @return A named character vector of hex color codes.
#'
#' @examples
#' centr_earthtone_palette()
#'
#' @export
centr_earthtone_palette <- function() {
  c(
    crimson = "#990000",
    walnut  = "#6B4226",
    caramel = "#A47551",
    sage    = "#8A9A5B",
    olive   = "#556B2F",
    slate   = "#3B4D61",
    amber   = "#B86B2A",
    plum    = "#66435A"
  )
}


#' Three-layer color palette for CEnTR*MAP analytical pipelines
#'
#' A 3-color palette representing the three analytical pipelines. Gradient
#' helpers and theme code belong in the calling application, not this package.
#'
#' @return A named character vector of hex color codes with names
#'   `"anchoring"`, `"integration"`, and `"leverage"`.
#'
#' @examples
#' centr_layer_palette()
#'
#' @export
centr_layer_palette <- function() {
  c(
    anchoring   = "#4A4A4A",
    integration = "#3A6F6A",
    leverage    = "#C6A15B"
  )
}
