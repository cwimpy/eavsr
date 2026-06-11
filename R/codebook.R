#' Read an EAVS codebook
#'
#' Returns the EAVS codebook for a given cycle as a tibble, with one row per
#' variable. Downloads the codebook file from the EAC if it is not already
#' cached. Requires the `readxl` package (installed automatically with
#' `janitor`'s suggested deps or via `install.packages("readxl")`).
#'
#' @param cycle Integer year of the EAVS cycle.
#'
#' @return A tibble of codebook entries.
#' @export
#' @examples
#' \dontrun{
#'   cb <- eavs_codebook(2024)
#' }
eavs_codebook <- function(cycle) {
  cycle <- .check_cycle(cycle, require_supported = TRUE)
  row <- .eavs_cycles_table[.eavs_cycles_table$cycle == cycle, ]
  if (identical(row$codebook_kind, "pdf")) {
    cli::cli_abort(c(
      "The {cycle} EAVS codebook is distributed as a PDF, not a parseable table.",
      i = "Download it manually with {.code download_eavs({cycle}, what = \"codebook\")}."
    ))
  }
  if (!requireNamespace("readxl", quietly = TRUE)) {
    cli::cli_abort(c(
      "{.pkg readxl} is required to read EAVS codebooks.",
      i = 'Install it with {.code install.packages("readxl")}.'
    ))
  }
  path <- download_eavs(cycle, what = "codebook", quiet = TRUE)[["codebook"]]
  tibble::as_tibble(readxl::read_excel(path))
}
