# Aggregate EAVS to county level

Combines EAVS rows reported directly at the county level with sub-county
rows summed up to their parent county-equivalent geography. State-level
and multi-county rows are dropped. Optionally drops U.S. territories and
Alaska, which lack standard county-equivalent reporting.

## Usage

``` r
aggregate_to_county(
  df,
  mode_cols = "d8",
  numeric_fn = function(x) sum(x, na.rm = TRUE),
  drop_territories = TRUE,
  drop_alaska = TRUE
)
```

## Arguments

- df:

  An EAVS data frame. If it has not already been classified,
  [`classify_jurisdiction()`](https://cwimpy.github.io/eavsr/reference/classify_jurisdiction.md)
  will be called on it.

- mode_cols:

  Character vector of column names that should be summarized by modal
  value instead of sum. Defaults to `"d8"`.

- numeric_fn:

  Function applied to numeric columns during sub-county aggregation.
  Defaults to `sum(x, na.rm = TRUE)`.

- drop_territories:

  Logical. If `TRUE` (default), drop AS, GU, MP, PR, VI from the
  sub-county aggregation step. Direct-county rows for these are also
  dropped.

- drop_alaska:

  Logical. If `TRUE` (default), drop AK from sub-county aggregation. AK
  reports at the borough level, which does not roll up cleanly to county
  FIPS.

## Value

A tibble with one row per county-equivalent FIPS code, plus an added
`data_source` column (`"direct_county"` or `"aggregated_subcounty"`).

## Details

For each county that has a direct EAVS row, that row is preferred over
the aggregated sub-county sum. Sub-county aggregation uses
`sum(..., na.rm = TRUE)` for numeric columns by default; specific
columns can use a different summary via `mode_cols` (modal value, useful
for ordinal questions like EAVS D8) or `numeric_fn` (override the
default summarizer).

## Examples

``` r
if (FALSE) { # \dontrun{
  eavs <- read_eavs(2024)
  county <- aggregate_to_county(eavs)
} # }
```
