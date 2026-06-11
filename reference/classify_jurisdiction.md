# Classify EAVS jurisdictions and derive county FIPS

EAVS reporting units vary across states: some states report at the
county level, others at the sub-county (township/municipality) level,
and a few report multi-county or state-wide rows. This helper adds the
columns needed to roll any EAVS file up to a consistent county-level
geography.

## Usage

``` r
classify_jurisdiction(df, ct_lookup = NULL, wi_lookup = NULL)
```

## Arguments

- df:

  An EAVS data frame.

- ct_lookup:

  Optional override for the Connecticut town-to-region table. Defaults
  to the package's `ct_planning_regions` data.

- wi_lookup:

  Optional override for the Wisconsin sub-county lookup. Defaults to the
  package's `wi_subcounty_fips` data; if that data is unavailable, WI
  sub-county rows will receive `NA` county FIPS.

## Value

The input data frame with the four columns above added.

## Details

Columns added to `df`:

- `is_multi_county`:

  Logical; jurisdiction covers multiple counties.

- `jurisdiction_type`:

  One of `"State"`, `"Multi-county"`, `"County"`, `"Sub-county"`.

- `state_fips`:

  Two-character state FIPS extracted from `fips_code`.

- `county_fips`:

  Five-character county-equivalent FIPS, with Connecticut planning
  regions and Wisconsin sub-county lookups applied where possible. `NA`
  for state and multi-county rows.

Input expectations: the data frame should already have lower-cased
column names (as returned by `read_eavs(level = "jurisdiction")` or
[`janitor::clean_names()`](https://sfirke.github.io/janitor/reference/clean_names.html)),
including `fips_code`, `jurisdiction_name`, and `state_abbr`.

## Examples

``` r
if (FALSE) { # \dontrun{
  eavs <- read_eavs(2024)
  eavs <- classify_jurisdiction(eavs)
} # }
```
