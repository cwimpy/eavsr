# Read an EAVS codebook

Returns the EAVS codebook for a given cycle as a tibble, with one row
per variable. Downloads the codebook file from the EAC if it is not
already cached. Requires the `readxl` package (installed automatically
with `janitor`'s suggested deps or via `install.packages("readxl")`).

## Usage

``` r
eavs_codebook(cycle)
```

## Arguments

- cycle:

  Integer year of the EAVS cycle.

## Value

A tibble of codebook entries.

## Examples

``` r
if (FALSE) { # \dontrun{
  cb <- eavs_codebook(2024)
} # }
```
