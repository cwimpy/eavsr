#' Cross-cycle variable crosswalk
#'
#' Returns the package's hand-curated crosswalk that maps EAVS variable
#' codes (e.g. `A1a`, `D2a`, `F1b`) to a stable harmonized name across
#' survey cycles, with a topical section label.
#'
#' This is the intellectual core of `eavsr`: EAVS variable names drift
#' across cycles, and analyses spanning multiple cycles need a stable
#' rename. The shipped crosswalk is a starting point — open an issue or
#' PR if you spot a misalignment.
#'
#' @return A tibble with one row per (cycle, variable) pair.
#' @export
#' @examples
#' eavs_crosswalk()
eavs_crosswalk <- function() {
  crosswalk
}
