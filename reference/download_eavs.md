# Download an EAVS cycle

Downloads the public-release data file (and optionally the codebook) for
a given EAVS cycle from the U.S. Election Assistance Commission and
caches the file locally. Subsequent calls return the cached path without
re-downloading unless `overwrite = TRUE`.

## Usage

``` r
download_eavs(
  cycle,
  what = c("both", "data", "codebook"),
  overwrite = FALSE,
  quiet = FALSE
)
```

## Arguments

- cycle:

  Integer year of the EAVS cycle (e.g., `2024`).

- what:

  Which file(s) to download: `"data"`, `"codebook"`, or `"both"` (the
  default).

- overwrite:

  Logical. If `TRUE`, re-download even if a cached copy exists. Defaults
  to `FALSE`.

- quiet:

  Logical. If `TRUE`, suppress progress messages.

## Value

A character vector of local file paths (named by `what`).

## Examples

``` r
if (FALSE) { # \dontrun{
  path <- download_eavs(2024, what = "data")
} # }
```
