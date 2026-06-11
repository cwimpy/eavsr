# Cross-cycle EAVS variable crosswalk

A hand-curated mapping between raw EAVS variable codes and stable
harmonized names, with topical section labels. Maintained in
`data-raw/crosswalk.csv`; see `data-raw/build_crosswalk.R` for the
regeneration script.

## Usage

``` r
crosswalk
```

## Format

A tibble with columns:

- cycle:

  Integer EAVS cycle (e.g., 2024).

- variable:

  Raw EAVS variable code as released by EAC.

- harmonized:

  Stable cross-cycle variable name used by eavsr.

- section:

  Topical section (registration, technology, mail_voting,
  polling_places, staffing, rejections, participation).

- description:

  Short human-readable description.
