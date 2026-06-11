# eavsr manual testing checklist (pre-CRAN)

Work through this top to bottom in a **fresh R session**. Each step says
what to run and what you should see. If any step surprises you, stop and
note it — surprises here are cheaper than surprises in a CRAN review or
a user's first session.

## 0. Clean install

- [ ] Start a fresh R session (Session > Restart R, or open a new terminal R).
- [ ] Install from GitHub as a user would:

  ```r
  pak::pak("cwimpy/eavsr")
  library(eavsr)
  ```

  **Expect:** installs without errors; no startup messages or warnings.

## 1. Metadata functions (no network needed)

- [ ] `eavs_cycles()`
  **Expect:** a tibble of cycles with 2016–2024 marked supported/verified
  and earlier cycles marked planned.
- [ ] `eavs_crosswalk()`
  **Expect:** the harmonized variable crosswalk as a tibble; skim a few
  rows for sanity.
- [ ] `cite_eavs(2024)`, `cite_eavs(2024, "bibtex")`
  **Expect:** a sensible citation in both formats; BibTeX parses (no
  stray braces, year is 2024).

## 2. Download and cache behavior (network)

- [ ] `eavs_cache_info()`
  **Expect:** empty tibble (or only files you expect from earlier use;
  run `eavs_clear_cache()` first for a true cold start).
- [ ] `download_eavs(2024)`
  **Expect:** progress messages, then file paths. Check the files are
  nontrivial size in `eavs_cache_info()` (the 2024 data file should be
  tens of MB, not KB — a tiny file means a junk download).
- [ ] Run `download_eavs(2024)` **again**.
  **Expect:** instant return with "Using cached ..." messages — no
  re-download.
- [ ] `download_eavs(2024, overwrite = TRUE)`
  **Expect:** re-downloads and replaces the cached copy.

## 3. Read and inspect

- [ ] `eavs <- read_eavs(2024)`
  **Expect:** a tibble with roughly 6,461 rows (2024 jurisdiction count)
  and harmonized column names.
- [ ] Spot-check home turf:

  ```r
  dplyr::filter(eavs, grepl("CRAIGHEAD", toupper(Jurisdiction_Name)))
  ```

  **Expect:** one Craighead County, AR row; eyeball registration and
  turnout values against what you know to be plausible.
- [ ] `cb <- eavs_codebook(2024)`
  **Expect:** codebook as a tibble; look up one variable you know and
  confirm the description matches the EAC documentation.

## 4. Classification edge cases (the part most worth your eyes)

- [ ] `eavs <- classify_jurisdiction(eavs)`
  **Expect:** new columns (jurisdiction_type, state_fips, county_fips),
  no warnings you can't explain.
- [ ] **Wisconsin** (5-digit non-FIPS codes, county from name parse):

  ```r
  wi <- dplyr::filter(eavs, State_Abbr == "WI")
  mean(is.na(wi$county_fips))
  ```

  **Expect:** zero or near-zero NA share; if any NA, look at those rows —
  are they multi-county cities the lookup should have caught?
- [ ] **Connecticut** (2022+ planning regions):

  ```r
  dplyr::count(dplyr::filter(eavs, State_Abbr == "CT"), county_fips)
  ```

  **Expect:** planning-region codes (09110–09190), not the retired
  09001–09015 county codes.
- [ ] **New England MCDs:** pick a NH or VT town and confirm county_fips
  matches digits 1–5 of its 10-digit FIPSCode.

## 5. Aggregation sanity

- [ ] `county <- aggregate_to_county(eavs)`
  **Expect:** roughly 3,100–3,200 rows (county equivalents); message or
  documented behavior for Alaska (dropped) and territories.
- [ ] Conservation check — pick one count variable and one state and
  confirm nothing is lost in the roll-up:

  ```r
  # replace `total_registered` with a real harmonized count column
  sum(dplyr::filter(eavs, State_Abbr == "AR")$total_registered, na.rm = TRUE) ==
    sum(dplyr::filter(county, state_fips == "05")$total_registered, na.rm = TRUE)
  ```

  **Expect:** TRUE (or an explainable difference, e.g., dropped rows).
- [ ] Scan for impossible values: negative counts, Inf, NaN in the
  aggregated table.

## 6. Other supported cycles (quick pass)

- [ ] `read_eavs(2022)`, `read_eavs(2020)`, `read_eavs(2016)` — each
  returns a tibble with plausible row counts (~6,400) and the same
  harmonized names where the crosswalk covers them.
- [ ] `eavs_clear_cache(2016)` removes only the 2016 files
  (`eavs_cache_info()` to confirm).

## 7. Failure modes (worth doing once)

- [ ] `read_eavs(2030)` and `read_eavs(2005)`
  **Expect:** immediate, informative errors — not a download attempt.
- [ ] **Graceful network failure:** turn off Wi-Fi, then
  `download_eavs(2020)` (an uncached cycle).
  **Expect:** a clear "Download failed ... EAC server may be unavailable"
  message after retries — and, critically, `eavs_cache_info()` shows
  **no partial file** for 2020. Turn Wi-Fi back on; the download works.
- [ ] **Cache override:**

  ```r
  withr::with_envvar(c(EAVSR_CACHE_DIR = tempdir()), eavs_cache_dir())
  ```

  **Expect:** returns the temp path, not the default cache.

## 8. Docs and site

- [ ] Visit <https://cwimpy.github.io/eavsr/> — logo renders, reference
  index lists all 11 exported functions, no broken links.
- [ ] Read the rendered vignette ("Get started") on the site as a
  stranger would — does the quick start actually run as written?
- [ ] README on GitHub: badges green, logo top-right, install
  instructions correct.

## 9. Final pre-submission gate

- [ ] Both win-builder emails (devel + release) report
  **0 errors, 0 warnings** plus only the "New submission" note.
- [ ] `rcmdcheck::rcmdcheck(args = "--as-cran")` locally: 0 errors,
  0 warnings.
- [ ] Working tree clean, pushed, CI green on the final commit.
- [ ] `devtools::submit_cran()` → click the confirmation link in the
  CRAN email.
- [ ] After acceptance: tag `v0.1.0` on GitHub, create the release,
  link Zenodo, add the DOI badge.
