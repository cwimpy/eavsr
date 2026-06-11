#' Local cache directory for EAVS files
#'
#' Returns the directory used to cache downloaded EAVS files. By default this
#' is `tools::R_user_dir("eavsr", "cache")`. The location can be overridden
#' for a single session with the `EAVSR_CACHE_DIR` environment variable.
#'
#' The directory is created on first access.
#'
#' @return Path to the cache directory.
#' @export
#' @examples
#' eavs_cache_dir()
eavs_cache_dir <- function() {
  path <- Sys.getenv("EAVSR_CACHE_DIR", unset = "")
  if (!nzchar(path)) {
    path <- tools::R_user_dir("eavsr", which = "cache")
  }
  if (!dir.exists(path)) {
    dir.create(path, recursive = TRUE, showWarnings = FALSE)
  }
  path
}

#' Inspect or clear the EAVS cache
#'
#' `eavs_cache_info()` returns a tibble of files currently cached, with sizes
#' and modification times. `eavs_clear_cache()` removes cached files
#' (optionally restricted to a single cycle).
#'
#' @param cycle Optional integer cycle to restrict to.
#' @return `eavs_cache_info()` returns a tibble; `eavs_clear_cache()` returns
#'   the number of files removed, invisibly.
#' @export
eavs_cache_info <- function() {
  path <- eavs_cache_dir()
  files <- list.files(path, full.names = TRUE, recursive = TRUE)
  if (length(files) == 0L) {
    return(tibble::tibble(
      file = character(),
      size_mb = numeric(),
      modified = as.POSIXct(character())
    ))
  }
  info <- file.info(files)
  tibble::tibble(
    file = basename(files),
    size_mb = round(info$size / 1024^2, 2),
    modified = info$mtime
  )
}

#' @rdname eavs_cache_info
#' @export
eavs_clear_cache <- function(cycle = NULL) {
  path <- eavs_cache_dir()
  files <- list.files(path, full.names = TRUE, recursive = TRUE)
  if (!is.null(cycle)) {
    cycle <- .check_cycle(cycle, require_supported = FALSE)
    files <- files[grepl(paste0("^", cycle, "_"), basename(files))]
  }
  n <- length(files)
  if (n > 0L) {
    file.remove(files)
    cli::cli_alert_success("Removed {n} cached file{?s}.")
  } else {
    cli::cli_alert_info("Nothing to remove.")
  }
  invisible(n)
}

# Build a deterministic local cache path for a (cycle, kind) pair.
# kind is one of "data", "codebook"; ext is the file extension to use
# (e.g. "csv", "zip", "xlsx", "pdf").
.cache_path <- function(cycle, kind = c("data", "codebook"), ext = NULL) {
  kind <- match.arg(kind)
  if (is.null(ext)) {
    ext <- switch(kind, data = "csv", codebook = "xlsx")
  }
  file.path(eavs_cache_dir(), sprintf("%d_%s.%s", cycle, kind, ext))
}
