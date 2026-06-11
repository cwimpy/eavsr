#' eavsr: Tidy Access to the Election Administration and Voting Survey
#'
#' Downloads, caches, and harmonizes public-release files from the U.S.
#' Election Assistance Commission's Election Administration and Voting
#' Survey (EAVS). Provides tidy access to multiple survey cycles, exposes
#' the codebook as a tibble, and supports joins to county-level rurality
#' classifications via the `rurality` package.
#'
#' @keywords internal
"_PACKAGE"

## usethis namespace: start
## usethis namespace: end
NULL

# Lazy-data object referenced by eavs_crosswalk() via lexical scoping.
utils::globalVariables("crosswalk")
