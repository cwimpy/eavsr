# Citation for an EAVS cycle

Returns a properly formatted citation for an EAVS cycle's report and
codebook. The EAC requests that researchers cite the underlying EAVS
release; this helper builds the recommended citation string.

## Usage

``` r
cite_eavs(cycle, style = c("text", "bibtex", "list"))
```

## Arguments

- cycle:

  Integer year of the EAVS cycle.

- style:

  One of `"text"` (a single citation string, the default), `"bibtex"`,
  or `"list"` (a structured list with fields).

## Value

A character string (or list, for `style = "list"`).

## Examples

``` r
cite_eavs(2024)
#> [1] "U.S. Election Assistance Commission (2025). 2024 Election Administration and Voting Survey Comprehensive Report. U.S. Election Assistance Commission, Washington, DC. https://www.eac.gov/research-and-data/studies-and-reports"
cite_eavs(2024, style = "bibtex")
#> [1] "@techreport{eac_eavs_2024,\n  author    = {{U.S. Election Assistance Commission}},\n  title     = {{2024 Election Administration and Voting Survey Comprehensive Report}},\n  institution = {{U.S. Election Assistance Commission}},\n  address   = {Washington, DC},\n  year      = {2025},\n  url       = {https://www.eac.gov/research-and-data/studies-and-reports}\n}"
```
