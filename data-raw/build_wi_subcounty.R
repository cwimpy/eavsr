# Build the Wisconsin county FIPS lookup used to roll WI sub-county EAVS
# rows up to the county level.
#
# WI reports EAVS at the municipality (sub-county) level. Each row's
# jurisdiction_name contains a county reference like "TOWN OF X, ABC
# COUNTY". We extract the county name and join to county FIPS.
#
# The lookup is built from the rurality package's county-level data,
# which already carries county_fips + county_name for all 50 states.
# Requires `rurality` to be installed.

library(usethis)

# If `rurality` is available, build the full WI lookup from its data;
# otherwise ship a zero-row stub with the expected schema so the package
# still installs cleanly. Users who need WI sub-county aggregation should
# install `rurality` (pak::pak("cwimpy/rurality")) and re-run this script.

empty <- function() {
  tibble::tibble(
    county_fips = character(),
    county_name = character(),
    name_upper  = character(),
    name_alt1   = character(),
    name_alt2   = character(),
    name_alt3   = character()
  )
}

if (requireNamespace("rurality", quietly = TRUE)) {
  library(dplyr)
  library(stringr)
  # `county_rurality` is lazy-loaded data; reach it with `::` (an
  # `exists(..., asNamespace())` check would miss it). Use the full 5-digit
  # `fips` (e.g. "55001") as county_fips, not rurality's 3-digit `county_fips`.
  counties <- rurality::county_rurality
  wi_subcounty_fips <- counties |>
    dplyr::filter(state_abbr == "WI") |>
    dplyr::transmute(
      county_fips = fips,
      county_name = county_name,
      name_upper  = stringr::str_to_upper(stringr::str_remove(county_name, " County$")),
      name_alt1   = stringr::str_replace(name_upper, "ST\\.", "ST"),
      name_alt2   = stringr::str_replace(name_upper, "ST ", ""),
      name_alt3   = stringr::str_remove(name_upper, "^ST\\. ")
    )
  message("Built wi_subcounty_fips from `rurality` (", nrow(wi_subcounty_fips), " rows).")
} else {
  wi_subcounty_fips <- empty()
  message(
    "rurality package or its county data not found; shipping empty ",
    "wi_subcounty_fips stub. Install rurality and re-run to populate."
  )
}

usethis::use_data(wi_subcounty_fips, overwrite = TRUE)
