# Connecticut town-to-planning-region lookup

Maps Connecticut town names to the FIPS code of their Council of
Governments / Planning Region (the county-equivalent geography federally
recognized in CT since 2022).

## Usage

``` r
ct_planning_regions
```

## Format

A tibble with columns `town_name` (uppercase), `planning_region_code`
(5-character FIPS), and `planning_region_name`.

## Details

Covers all 169 Connecticut towns across the 9 planning regions, built
from the U.S. Census Bureau Gazetteer (2024 vintage) via
`data-raw/build_ct_planning_regions.R`.
