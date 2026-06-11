# Build the Connecticut town-to-planning-region lookup.
#
# Connecticut replaced its 8 historical counties with 9 Councils of
# Governments / Planning Regions as the federally recognized county-
# equivalent geography (OMB Bulletin 2022). EAVS jurisdictions in CT are
# towns, so we need town -> planning-region-FIPS to aggregate to the new
# county-equivalent level.
#
# Source: U.S. Census Bureau Gazetteer, 2024 vintage (public domain), which
# encodes the new planning-region county codes (09110-09190):
#   https://www2.census.gov/geo/docs/maps-data/data/gazetteer/2024_Gazetteer/
#     2024_gaz_cousubs_09.txt   town -> GEOID (chars 1-5 = planning region code)
#     2024_gaz_counties_09.txt  planning region code -> official name
#
# Covers all 169 CT towns. Re-run (with internet) to refresh from Census.

library(readr)
library(usethis)

base <- paste0(
  "https://www2.census.gov/geo/docs/maps-data/data/gazetteer/",
  "2024_Gazetteer/"
)
ctypes <- readr::cols(.default = readr::col_character())

cousubs <- readr::read_tsv(paste0(base, "2024_gaz_cousubs_09.txt"),
                           col_types = ctypes, trim_ws = TRUE)
counties <- readr::read_tsv(paste0(base, "2024_gaz_counties_09.txt"),
                            col_types = ctypes, trim_ws = TRUE)

# Region code -> short name (drop the " Planning Region" suffix to match the
# existing naming convention, e.g. "Capitol", "Greater Bridgeport").
region_name <- stats::setNames(
  sub(" Planning Region$", "", counties$NAME),
  counties$GEOID
)

# Keep the 169 towns (drop "County subdivisions not defined" water areas).
towns <- cousubs[grepl(" town$", cousubs$NAME), ]
code  <- substr(towns$GEOID, 1L, 5L)

ct_planning_regions <- tibble::tibble(
  town_name            = toupper(sub(" town$", "", towns$NAME)),
  planning_region_code = code,
  planning_region_name = unname(region_name[code])
)
ct_planning_regions <- ct_planning_regions[
  order(ct_planning_regions$planning_region_code, ct_planning_regions$town_name),
]

readr::write_csv(ct_planning_regions, "data-raw/ct_planning_regions.csv")
usethis::use_data(ct_planning_regions, overwrite = TRUE)
message("Built ct_planning_regions: ", nrow(ct_planning_regions),
        " towns across ", length(unique(ct_planning_regions$planning_region_code)),
        " regions.")
