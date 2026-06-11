# Changelog

## eavsr 0.1.0

- Initial release.

### Initial scaffolding

- Package structure created with `DESCRIPTION`, `LICENSE`, `LICENSE.md`,
  `NAMESPACE`, and roxygen-based documentation.
- Core functions:
  [`eavs_cycles()`](https://cwimpy.github.io/eavsr/reference/eavs_cycles.md),
  [`download_eavs()`](https://cwimpy.github.io/eavsr/reference/download_eavs.md),
  [`read_eavs()`](https://cwimpy.github.io/eavsr/reference/read_eavs.md),
  [`eavs_codebook()`](https://cwimpy.github.io/eavsr/reference/eavs_codebook.md),
  [`eavs_crosswalk()`](https://cwimpy.github.io/eavsr/reference/eavs_crosswalk.md),
  [`cite_eavs()`](https://cwimpy.github.io/eavsr/reference/cite_eavs.md).
- Cache management:
  [`eavs_cache_dir()`](https://cwimpy.github.io/eavsr/reference/eavs_cache_dir.md),
  [`eavs_cache_info()`](https://cwimpy.github.io/eavsr/reference/eavs_cache_info.md),
  [`eavs_clear_cache()`](https://cwimpy.github.io/eavsr/reference/eavs_cache_info.md).
- 2024 cycle supported with verified EAC URLs; earlier cycles
  (2004–2022) registered as “planned” pending URL verification.
- Hand-curated cross-cycle variable crosswalk in
  `data-raw/crosswalk.csv`.
- `testthat` suite covering cycle validation, cache behavior, citations,
  and missing-value recoding.
- GitHub Actions workflows for `R CMD check` and `pkgdown`.

### Aggregation helpers

- [`classify_jurisdiction()`](https://cwimpy.github.io/eavsr/reference/classify_jurisdiction.md)
  adds `jurisdiction_type`, `is_multi_county`, `state_fips`, and
  `county_fips` columns. Handles 2/5/10/11-character raw FIPS widths,
  Connecticut planning regions, and Wisconsin sub-county name lookups.
- [`aggregate_to_county()`](https://cwimpy.github.io/eavsr/reference/aggregate_to_county.md)
  combines direct-county rows with summed sub-county rows, with
  configurable mode-aggregated columns (default `d8`), customizable
  numeric summarizer, and territory/Alaska drops.
- Two shipped lookup datasets: `ct_planning_regions` (partial — see
  [`?ct_planning_regions`](https://cwimpy.github.io/eavsr/reference/ct_planning_regions.md))
  and `wi_subcounty_fips` (built from the `rurality` package).
