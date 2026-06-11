#' Cross-cycle EAVS variable crosswalk
#'
#' A hand-curated mapping between raw EAVS variable codes and stable
#' harmonized names, with topical section labels. Maintained in
#' `data-raw/crosswalk.csv`; see `data-raw/build_crosswalk.R` for the
#' regeneration script.
#'
#' @format A tibble with columns:
#' \describe{
#'   \item{cycle}{Integer EAVS cycle (e.g., 2024).}
#'   \item{variable}{Raw EAVS variable code as released by EAC.}
#'   \item{harmonized}{Stable cross-cycle variable name used by eavsr.}
#'   \item{section}{Topical section
#'     (registration, technology, mail_voting, polling_places,
#'     staffing, rejections, participation).}
#'   \item{description}{Short human-readable description.}
#' }
"crosswalk"

#' Connecticut town-to-planning-region lookup
#'
#' Maps Connecticut town names to the FIPS code of their Council of
#' Governments / Planning Region (the county-equivalent geography
#' federally recognized in CT since 2022).
#'
#' Covers all 169 Connecticut towns across the 9 planning regions, built
#' from the U.S. Census Bureau Gazetteer (2024 vintage) via
#' `data-raw/build_ct_planning_regions.R`.
#'
#' @format A tibble with columns `town_name` (uppercase),
#'   `planning_region_code` (5-character FIPS), and `planning_region_name`.
"ct_planning_regions"

#' Wisconsin sub-county to county FIPS lookup
#'
#' Wisconsin reports EAVS at the sub-county (municipality) level. This
#' lookup links each WI county to its FIPS code with name variants
#' (St./St-/etc.) to support fuzzy matching against the messy
#' `jurisdiction_name` strings.
#'
#' Covers all 72 Wisconsin counties, built from the `rurality` package via
#' `data-raw/build_wi_subcounty.R`. This resolves ~97% of WI EAVS rows; the
#' remainder are municipalities spanning multiple counties (jurisdiction
#' names containing "MULTIPLE COUNTIES"), which are flagged `is_multi_county`
#' and receive `NA` county FIPS by design.
#'
#' @format A tibble with `county_fips` (5-character FIPS), `county_name`, and
#'   four uppercased name-variant columns used for matching.
"wi_subcounty_fips"
