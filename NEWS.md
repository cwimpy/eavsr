# eavsr 0.1.0

* Initial release.

## Initial scaffolding

- Package structure created with `DESCRIPTION`, `LICENSE`, `LICENSE.md`,
  `NAMESPACE`, and roxygen-based documentation.
- Core functions: `eavs_cycles()`, `download_eavs()`, `read_eavs()`,
  `eavs_codebook()`, `eavs_crosswalk()`, `cite_eavs()`.
- Cache management: `eavs_cache_dir()`, `eavs_cache_info()`,
  `eavs_clear_cache()`.
- 2024 cycle supported with verified EAC URLs; earlier cycles (2004–2022)
  registered as "planned" pending URL verification.
- Hand-curated cross-cycle variable crosswalk in `data-raw/crosswalk.csv`.
- `testthat` suite covering cycle validation, cache behavior, citations,
  and missing-value recoding.
- GitHub Actions workflows for `R CMD check` and `pkgdown`.

## Aggregation helpers

- `classify_jurisdiction()` adds `jurisdiction_type`, `is_multi_county`,
  `state_fips`, and `county_fips` columns. Handles 2/5/10/11-character
  raw FIPS widths, Connecticut planning regions, and Wisconsin
  sub-county name lookups.
- `aggregate_to_county()` combines direct-county rows with summed
  sub-county rows, with configurable mode-aggregated columns (default
  `d8`), customizable numeric summarizer, and territory/Alaska drops.
- Two shipped lookup datasets: `ct_planning_regions` (partial — see
  `?ct_planning_regions`) and `wi_subcounty_fips` (built from the
  `rurality` package).
