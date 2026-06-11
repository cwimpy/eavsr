# Read an EAVS cycle as a tidy tibble

Reads a cached EAVS public-release file into R as a tibble, with EAVS
missing-value codes (negative integers) recoded to `NA`. Downloads the
file first if it is not already cached.

## Usage

``` r
read_eavs(
  cycle,
  level = c("jurisdiction", "raw"),
  clean_names = NULL,
  recode_missing = NULL
)
```

## Arguments

- cycle:

  Integer year of the EAVS cycle.

- level:

  Aggregation level: `"jurisdiction"` (default, one row per reporting
  jurisdiction as released by EAC) or `"raw"` (the file exactly as
  released, with no recoding).

- clean_names:

  Logical. If `TRUE` (the default for `level = "jurisdiction"`), apply
  [`janitor::clean_names()`](https://sfirke.github.io/janitor/reference/clean_names.html)
  to column names.

- recode_missing:

  Logical. If `TRUE` (the default), recode negative numeric values to
  `NA`. EAVS uses negative codes (`-99`, `-77`, etc.) to indicate
  non-response and missing data.

## Value

A tibble.

## Examples

``` r
if (FALSE) { # \dontrun{
  eavs <- read_eavs(2024)
} # }
```
