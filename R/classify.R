#' Classify EAVS jurisdictions and derive county FIPS
#'
#' EAVS reporting units vary across states: some states report at the
#' county level, others at the sub-county (township/municipality) level,
#' and a few report multi-county or state-wide rows. This helper adds the
#' columns needed to roll any EAVS file up to a consistent county-level
#' geography.
#'
#' Columns added to `df`:
#' \describe{
#'   \item{`is_multi_county`}{Logical; jurisdiction covers multiple counties.}
#'   \item{`jurisdiction_type`}{One of `"State"`, `"Multi-county"`,
#'     `"County"`, `"Sub-county"`.}
#'   \item{`state_fips`}{Two-character state FIPS extracted from `fips_code`.}
#'   \item{`county_fips`}{Five-character county-equivalent FIPS, with
#'     Connecticut planning regions and Wisconsin sub-county lookups
#'     applied where possible. `NA` for state and multi-county rows.}
#' }
#'
#' Input expectations: the data frame should already have lower-cased
#' column names (as returned by `read_eavs(level = "jurisdiction")` or
#' `janitor::clean_names()`), including `fips_code`, `jurisdiction_name`,
#' and `state_abbr`.
#'
#' @param df An EAVS data frame.
#' @param ct_lookup Optional override for the Connecticut town-to-region
#'   table. Defaults to the package's `ct_planning_regions` data.
#' @param wi_lookup Optional override for the Wisconsin sub-county lookup.
#'   Defaults to the package's `wi_subcounty_fips` data; if that data is
#'   unavailable, WI sub-county rows will receive `NA` county FIPS.
#'
#' @return The input data frame with the four columns above added.
#' @export
#' @examples
#' \dontrun{
#'   eavs <- read_eavs(2024)
#'   eavs <- classify_jurisdiction(eavs)
#' }
classify_jurisdiction <- function(df,
                                  ct_lookup = NULL,
                                  wi_lookup = NULL) {
  required <- c("fips_code", "jurisdiction_name", "state_abbr")
  missing  <- setdiff(required, names(df))
  if (length(missing)) {
    cli::cli_abort(c(
      "Input is missing required column{?s}: {.field {missing}}.",
      i = "Pass a data frame from {.fn read_eavs} or apply {.fn janitor::clean_names} first."
    ))
  }

  if (is.null(ct_lookup)) {
    ct_lookup <- .get_lookup("ct_planning_regions")
  }
  if (is.null(wi_lookup)) {
    wi_lookup <- .get_lookup("wi_subcounty_fips", required = FALSE)
  }

  fips <- as.character(df$fips_code)
  width <- nchar(fips)

  df$is_multi_county <- grepl("MULTIPLE COUNTIES", df$jurisdiction_name, fixed = TRUE)

  df$jurisdiction_type <- dplyr_case_when(
    width == 2L,                                "State",
    df$is_multi_county,                         "Multi-county",
    width == 5L & df$state_abbr == "WI",        "Sub-county",
    width == 5L,                                "County",
    grepl("00000$", fips),                      "County",
    default = "Sub-county"
  )

  df$state_fips <- substr(fips, 1L, 2L)
  df$state_fips[!nzchar(df$state_fips)] <- NA_character_
  # Wisconsin EAVS codes are an internal sequence, not Census FIPS, so the
  # 2-character prefix is meaningless; set WI's state FIPS explicitly.
  df$state_fips[df$state_abbr == "WI"] <- "55"

  df$county_fips <- .derive_county_fips(
    fips             = fips,
    width            = width,
    state_abbr       = df$state_abbr,
    jurisdiction     = df$jurisdiction_name,
    is_multi_county  = df$is_multi_county,
    ct_lookup        = ct_lookup,
    wi_lookup        = wi_lookup
  )

  df
}

# Internal: derive a 5-char county-equivalent FIPS from variable-width
# raw FIPS codes plus state-specific name lookups.
.derive_county_fips <- function(fips, width, state_abbr,
                                jurisdiction, is_multi_county,
                                ct_lookup, wi_lookup) {
  out <- rep(NA_character_, length(fips))

  # Connecticut: extract town name, look up planning region.
  ct_idx <- which(state_abbr == "CT" & !is_multi_county)
  if (length(ct_idx)) {
    town <- toupper(sub(" TOWN$", "", trimws(sub("^([A-Z ]+).*", "\\1", jurisdiction[ct_idx]))))
    out[ct_idx] <- ct_lookup$planning_region_code[match(town, ct_lookup$town_name)]
  }

  # Wisconsin: extract county name from jurisdiction string, look up FIPS.
  wi_idx <- which(state_abbr == "WI" & !is_multi_county)
  if (length(wi_idx) && !is.null(wi_lookup)) {
    cname <- .extract_wi_county_name(jurisdiction[wi_idx])
    out[wi_idx] <- .match_wi_name(cname, wi_lookup)
  }

  # General FIPS-width rules for everywhere else.
  generic_idx <- which(is.na(out) & !is_multi_county & !state_abbr %in% c("CT", "WI"))
  if (length(generic_idx)) {
    out[generic_idx] <- vapply(generic_idx, function(i) {
      f <- fips[i]
      w <- width[i]
      if (is.na(f) || w == 2L) return(NA_character_)
      if (w == 5L) return(f)
      if (w == 10L) return(paste0(substr(f, 1L, 2L), substr(f, 3L, 5L)))
      if (w == 11L) return(substr(f, 1L, 5L))
      substr(f, 1L, 5L)
    }, character(1))
  }

  out
}

.extract_wi_county_name <- function(name) {
  out <- rep(NA_character_, length(name))
  st_croix <- grepl("ST\\. CROIX COUNTY", name)
  out[st_croix] <- "ST. CROIX"

  st_other <- grepl("ST\\. [A-Z]+ COUNTY", name) & !st_croix
  out[st_other] <- regmatches(
    name[st_other],
    regexpr("ST\\. [A-Z]+", name[st_other])
  )

  general <- is.na(out) & grepl("([A-Z]+ )*COUNTY", name)
  if (any(general)) {
    raw <- regmatches(name[general], regexpr("([A-Z]+ )*COUNTY", name[general]))
    out[general] <- sub(" COUNTY$", "", raw)
  }
  out
}

.match_wi_name <- function(cname, wi_lookup) {
  hit <- wi_lookup$county_fips[match(cname, wi_lookup$name_upper)]
  hit <- ifelse(is.na(hit), wi_lookup$county_fips[match(cname, wi_lookup$name_alt1)], hit)
  hit <- ifelse(is.na(hit), wi_lookup$county_fips[match(cname, wi_lookup$name_alt2)], hit)
  hit <- ifelse(is.na(hit), wi_lookup$county_fips[match(cname, wi_lookup$name_alt3)], hit)
  hit
}

# Minimal vectorized case_when without taking a hard dplyr dependency.
dplyr_case_when <- function(..., default = NA) {
  args <- list(...)
  if (length(args) %% 2L != 0L) {
    cli::cli_abort("Conditions and values must be paired.")
  }
  conds  <- args[seq(1L, length(args), by = 2L)]
  values <- args[seq(2L, length(args), by = 2L)]
  n <- length(conds[[1L]])
  out <- rep(default, n)
  assigned <- rep(FALSE, n)
  for (i in seq_along(conds)) {
    hit <- conds[[i]] & !assigned
    out[hit] <- values[[i]]
    assigned <- assigned | hit
  }
  out
}

# Look up an internal lazy-data object by name; return NULL if missing
# and the lookup is optional.
.get_lookup <- function(name, required = TRUE) {
  # Load the package's own lazy-data object into a private environment.
  # `utils::data()` is the portable way to reach a dataset programmatically;
  # `exists(inherits = FALSE)` on the namespace misses lazy-loaded data.
  env <- new.env(parent = emptyenv())
  suppressWarnings(
    utils::data(list = name, package = "eavsr", envir = env)
  )
  if (!exists(name, envir = env, inherits = FALSE)) {
    if (required) {
      cli::cli_abort(c(
        "Lookup data {.field {name}} is not available.",
        i = "Run {.code source('data-raw/build_{name}.R')} to build it."
      ))
    }
    return(NULL)
  }
  get(name, envir = env, inherits = FALSE)
}
