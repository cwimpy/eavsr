#' EAVS survey cycles available in `eavsr`
#'
#' Returns a tibble of EAVS survey cycles known to the package, along with
#' the URLs used to download each cycle's public-release data and codebook.
#'
#' The EAC reorganizes its site periodically, so URLs in this table may be
#' patched in point releases. Open an issue if you find a broken link.
#'
#' @return A tibble with columns `cycle` (integer year), `data_url`,
#'   `data_kind` (`"csv"` or `"zip"`), `codebook_url`, `codebook_kind`
#'   (`"xlsx"` or `"pdf"`), and `status` (`"supported"` or `"planned"`).
#' @export
#' @examples
#' eavs_cycles()
eavs_cycles <- function() {
  .eavs_cycles_table
}

# Internal lookup table — patch URLs here when EAC reorganizes its site.
# All URLs verified via HEAD request on 2026-05-16. Re-verify before
# tagging a release. The `data_kind` column tells the downloader whether
# the data URL points to a raw `.csv` or a `.zip` containing a CSV.
.eavs_cycles_table <- tibble::tibble(
  cycle = c(2004L, 2008L, 2012L, 2014L, 2016L, 2018L, 2020L, 2022L, 2024L),
  data_url = c(
    NA_character_,
    NA_character_,
    NA_character_,
    NA_character_,
    "https://www.eac.gov/sites/default/files/2023-12/EAVS_2016_for_Public_Release_nolabel_V1.1_CSV.zip",
    "https://www.eac.gov/sites/default/files/2019-10/EAVS_2018_for_Public_Release_nolabel%20v1.1.csv",
    "https://www.eac.gov/sites/default/files/2023-12/2020_EAVS_for_Public_Release_nolabel_V1.2_CSV.zip",
    "https://www.eac.gov/sites/default/files/2023-06/2022_EAVS_for_Public_Release_nolabel_V1_CSV.zip",
    "https://www.eac.gov/sites/default/files/2025-06/2024_EAVS_for_Public_Release_nolabel_V1_csv.zip"
  ),
  data_kind = c(
    NA_character_, NA_character_, NA_character_, NA_character_,
    "zip", "csv", "zip", "zip", "zip"
  ),
  codebook_url = c(
    NA_character_,
    NA_character_,
    NA_character_,
    NA_character_,
    "https://www.eac.gov/sites/default/files/eac_assets/1/6/EAVS_Codebook_2016.pdf",
    "https://www.eac.gov/sites/default/files/eac_assets/1/6/2018_EAVS_Codebook.xlsx",
    "https://www.eac.gov/sites/default/files/2021-08/2020_EAVS_Codebook.xlsx",
    "https://www.eac.gov/sites/default/files/2023-06/2022_EAVS_Codebook.xlsx",
    "https://www.eac.gov/sites/default/files/2025-06/2024_EAVS_Codebook.xlsx"
  ),
  codebook_kind = c(
    NA_character_, NA_character_, NA_character_, NA_character_,
    "pdf", "xlsx", "xlsx", "xlsx", "xlsx"
  ),
  status = c(
    "planned", "planned", "planned", "planned",
    "supported", "supported", "supported", "supported", "supported"
  )
)

# Validate a cycle argument against the table.
.check_cycle <- function(cycle, require_supported = TRUE) {
  if (!is.numeric(cycle) || length(cycle) != 1L) {
    cli::cli_abort("{.arg cycle} must be a single integer year.")
  }
  cycle <- as.integer(cycle)
  if (!cycle %in% .eavs_cycles_table$cycle) {
    cli::cli_abort(c(
      "Unknown EAVS cycle {.val {cycle}}.",
      i = "See {.fn eavs_cycles} for available cycles."
    ))
  }
  if (require_supported) {
    status <- .eavs_cycles_table$status[.eavs_cycles_table$cycle == cycle]
    if (status != "supported") {
      cli::cli_abort(c(
        "EAVS {cycle} is marked as {.val {status}}.",
        i = "Only `supported` cycles have verified download URLs."
      ))
    }
  }
  cycle
}
