# Wisconsin sub-county to county FIPS lookup

Wisconsin reports EAVS at the sub-county (municipality) level. This
lookup links each WI county to its FIPS code with name variants
(St./St-/etc.) to support fuzzy matching against the messy
`jurisdiction_name` strings.

## Usage

``` r
wi_subcounty_fips
```

## Format

A tibble with `county_fips` (5-character FIPS), `county_name`, and four
uppercased name-variant columns used for matching.

## Details

Covers all 72 Wisconsin counties, built from the `rurality` package via
`data-raw/build_wi_subcounty.R`. This resolves ~97% of WI EAVS rows; the
remainder are municipalities spanning multiple counties (jurisdiction
names containing "MULTIPLE COUNTIES"), which are flagged
`is_multi_county` and receive `NA` county FIPS by design.
