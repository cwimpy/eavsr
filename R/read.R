#' Read an EAVS cycle as a tidy tibble
#'
#' Reads a cached EAVS public-release file into R as a tibble, with EAVS
#' missing-value codes (negative integers) recoded to `NA`. Downloads the
#' file first if it is not already cached.
#'
#' @param cycle Integer year of the EAVS cycle.
#' @param level Aggregation level: `"jurisdiction"` (default, one row per
#'   reporting jurisdiction as released by EAC) or `"raw"` (the file
#'   exactly as released, with no recoding).
#' @param clean_names Logical. If `TRUE` (the default for `level =
#'   "jurisdiction"`), apply `janitor::clean_names()` to column names.
#' @param recode_missing Logical. If `TRUE` (the default), recode negative
#'   numeric values to `NA`. EAVS uses negative codes (`-99`, `-77`, etc.)
#'   to indicate non-response and missing data.
#'
#' @return A tibble.
#' @export
#' @examples
#' \dontrun{
#'   eavs <- read_eavs(2024)
#' }
read_eavs <- function(cycle,
                      level = c("jurisdiction", "raw"),
                      clean_names = NULL,
                      recode_missing = NULL) {
  level <- match.arg(level)
  cycle <- .check_cycle(cycle, require_supported = TRUE)

  if (is.null(clean_names)) clean_names <- level == "jurisdiction"
  if (is.null(recode_missing)) recode_missing <- level == "jurisdiction"

  path <- download_eavs(cycle, what = "data", quiet = TRUE)[["data"]]
  csv_path <- .ensure_csv(path)
  df <- readr::read_csv(csv_path, show_col_types = FALSE, progress = FALSE)

  if (clean_names) {
    if (!requireNamespace("janitor", quietly = TRUE)) {
      cli::cli_abort(c(
        "{.pkg janitor} is required for {.code clean_names = TRUE}.",
        i = 'Install it with {.code install.packages("janitor")}.'
      ))
    }
    df <- janitor::clean_names(df)
  }

  if (recode_missing) {
    df <- .recode_missing(df)
  }

  tibble::as_tibble(df)
}

# If `path` is a .zip, extract the first .csv inside to the same cache dir
# and return that path. Otherwise return `path` unchanged.
.ensure_csv <- function(path) {
  if (!grepl("\\.zip$", path, ignore.case = TRUE)) return(path)
  inner <- utils::unzip(path, list = TRUE)$Name
  csv_name <- inner[grepl("\\.csv$", inner, ignore.case = TRUE)][1L]
  if (is.na(csv_name)) {
    cli::cli_abort("No CSV found inside {.path {path}}.")
  }
  out_dir <- dirname(path)
  out_path <- file.path(out_dir, basename(csv_name))
  if (!file.exists(out_path)) {
    utils::unzip(path, files = csv_name, exdir = out_dir, junkpaths = TRUE)
    out_path <- file.path(out_dir, basename(csv_name))
  }
  out_path
}

# EAVS encodes missing data as negative integers. Recode numeric columns
# only; preserve FIPS-like fields, which can legitimately start with 0.
.recode_missing <- function(df) {
  fips_cols <- grep("fips", names(df), ignore.case = TRUE, value = TRUE)
  numeric_cols <- setdiff(names(df)[vapply(df, is.numeric, logical(1))], fips_cols)
  for (col in numeric_cols) {
    x <- df[[col]]
    x[x < 0] <- NA_real_
    df[[col]] <- x
  }
  df
}
