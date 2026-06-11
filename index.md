# eavsr

`eavsr` is a tidy R interface to the U.S. Election Assistance
Commission’s **Election Administration and Voting Survey (EAVS)**. It
downloads and caches public-release EAVS files, harmonizes variable
names across survey cycles, exposes the codebook as a tibble, and
provides citation helpers.

EAVS is the largest public dataset on local election administration in
the United States, covering thousands of reporting jurisdictions (6,461
in 2024) across registration, voting technology, polling places,
staffing, mail/absentee voting, ballot rejections, and turnout. `eavsr`
is designed to make multi-cycle analyses straightforward without
rewriting variable-selection logic each time.

> **Not affiliated with or endorsed by the U.S. Election Assistance
> Commission.**

## Installation

``` r

# install.packages("pak")
pak::pak("cwimpy/eavsr")
```

## Quick start

``` r

library(eavsr)

# What cycles does the package know about?
eavs_cycles()

# Download and read the 2024 cycle (cached on first download).
eavs <- read_eavs(2024)

# Inspect the codebook as a tibble.
cb <- eavs_codebook(2024)

# See the harmonized variable crosswalk across cycles.
eavs_crosswalk()

# Classify each jurisdiction (jurisdiction_type, state_fips, county_fips).
# Handles CT planning regions, WI sub-county lookups, and multi-county rows.
eavs <- classify_jurisdiction(eavs)

# Roll up to county-equivalent geography (calls classify_jurisdiction() if needed).
county <- aggregate_to_county(eavs)

# Get a citation (also "bibtex" or "list").
cite_eavs(2024)
```

For a guided walkthrough, see
[`vignette("eavsr")`](https://cwimpy.github.io/eavsr/articles/eavsr.md).

## Caching

Downloaded files are cached at `tools::R_user_dir("eavsr", "cache")`.
Override the location with the `EAVSR_CACHE_DIR` environment variable.
Inspect or clear the cache with
[`eavs_cache_info()`](https://cwimpy.github.io/eavsr/reference/eavs_cache_info.md)
and
[`eavs_clear_cache()`](https://cwimpy.github.io/eavsr/reference/eavs_cache_info.md).

## Data source and citation

EAVS public-release files are works of the U.S. federal government and
are in the public domain (17 U.S.C. § 105). The EAC requests citation of
the EAVS Report and Codebook when these data are used.
`cite_eavs(cycle)` returns the recommended citation in text or BibTeX
form.

## Companion packages

- [`rurality`](https://github.com/cwimpy/rurality) — county-level
  rurality classifications (RUCC, RUCA, IRR, OMB) that pair naturally
  with EAVS for rural–urban analyses.
- [`rurality-stata`](https://github.com/cwimpy/rurality-stata) — same
  classifications for Stata users.

## Roadmap

Current (v0.1):

- Download, cache, and read the 2016–2024 cycles with verified EAC URLs.
- Codebook access, citation helpers, and a starter cross-cycle
  crosswalk.
- County-equivalent aggregation, including CT planning regions, WI
  sub-county name lookups, and multi-county jurisdictions.

Planned:

- Earlier cycles (2004–2014) added once their public-release URLs are
  verified.
- Expanded, community-reviewed variable crosswalk.
- Multi-cycle harmonized Parquet bundle distributed via GitHub Releases
  with `piggyback`.

## License

MIT © Cameron Wimpy. See `LICENSE.md`.
