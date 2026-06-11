#' Download an EAVS cycle
#'
#' Downloads the public-release data file (and optionally the codebook) for
#' a given EAVS cycle from the U.S. Election Assistance Commission and
#' caches the file locally. Subsequent calls return the cached path without
#' re-downloading unless `overwrite = TRUE`.
#'
#' @param cycle Integer year of the EAVS cycle (e.g., `2024`).
#' @param what Which file(s) to download: `"data"`, `"codebook"`, or
#'   `"both"` (the default).
#' @param overwrite Logical. If `TRUE`, re-download even if a cached copy
#'   exists. Defaults to `FALSE`.
#' @param quiet Logical. If `TRUE`, suppress progress messages.
#'
#' @return A character vector of local file paths (named by `what`).
#' @export
#' @examples
#' \dontrun{
#'   path <- download_eavs(2024, what = "data")
#' }
download_eavs <- function(cycle,
                          what = c("both", "data", "codebook"),
                          overwrite = FALSE,
                          quiet = FALSE) {
  what <- match.arg(what)
  cycle <- .check_cycle(cycle, require_supported = TRUE)

  kinds <- switch(what,
    both = c("data", "codebook"),
    data = "data",
    codebook = "codebook"
  )

  row <- .eavs_cycles_table[.eavs_cycles_table$cycle == cycle, ]
  out <- vapply(kinds, function(kind) {
    url <- switch(kind, data = row$data_url, codebook = row$codebook_url)
    if (is.na(url)) {
      cli::cli_abort("No {kind} URL recorded for EAVS {cycle}.")
    }
    ext <- switch(kind, data = row$data_kind, codebook = row$codebook_kind)
    dest <- .cache_path(cycle, kind, ext = ext)
    if (file.exists(dest) && !overwrite) {
      if (!quiet) {
        cli::cli_alert_info("Using cached {kind} for EAVS {cycle}: {.path {dest}}")
      }
      return(dest)
    }
    .fetch(url, dest, label = sprintf("EAVS %d %s", cycle, kind), quiet = quiet)
    dest
  }, character(1))

  names(out) <- kinds
  invisible(out)
}

# Single-file HTTP fetch with httr2 + progress.
.fetch <- function(url, dest, label, quiet = FALSE) {
  if (!quiet) {
    cli::cli_alert_info("Downloading {label} ...")
  }
  req <- httr2::request(url) |>
    httr2::req_user_agent("eavsr (https://github.com/cwimpy/eavsr)") |>
    httr2::req_retry(max_tries = 3)
  resp <- httr2::req_perform(req, path = dest)
  if (httr2::resp_status(resp) >= 400L) {
    cli::cli_abort("Download failed ({httr2::resp_status(resp)}): {.url {url}}")
  }
  if (!quiet) {
    cli::cli_alert_success("Saved {.path {dest}}")
  }
  invisible(dest)
}
