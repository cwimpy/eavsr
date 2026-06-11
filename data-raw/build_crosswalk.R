# Build the cross-cycle variable crosswalk used by eavs_crosswalk().
#
# The crosswalk maps raw EAVS variable codes (e.g. "A1a", "D2a", "F1b") to
# stable harmonized names so analyses can span multiple survey cycles
# without rewriting selection logic each time. This script reads the
# hand-curated CSV at data-raw/crosswalk.csv and saves it as the package's
# `crosswalk` data object.
#
# To extend coverage to a new cycle:
#   1. Open data-raw/crosswalk.csv and add rows for the new cycle.
#   2. Re-run this script: source("data-raw/build_crosswalk.R")
#   3. Re-document and re-install the package.

library(readr)
library(usethis)

crosswalk <- readr::read_csv(
  "data-raw/crosswalk.csv",
  show_col_types = FALSE
)

usethis::use_data(crosswalk, overwrite = TRUE)
