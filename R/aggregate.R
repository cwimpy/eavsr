#' Aggregate EAVS to county level
#'
#' Combines EAVS rows reported directly at the county level with sub-county
#' rows summed up to their parent county-equivalent geography. State-level
#' and multi-county rows are dropped. Optionally drops U.S. territories
#' and Alaska, which lack standard county-equivalent reporting.
#'
#' For each county that has a direct EAVS row, that row is preferred over
#' the aggregated sub-county sum. Sub-county aggregation uses `sum(..., na.rm = TRUE)`
#' for numeric columns by default; specific columns can use a different
#' summary via `mode_cols` (modal value, useful for ordinal questions like
#' EAVS D8) or `numeric_fn` (override the default summarizer).
#'
#' @param df An EAVS data frame. If it has not already been classified,
#'   `classify_jurisdiction()` will be called on it.
#' @param mode_cols Character vector of column names that should be
#'   summarized by modal value instead of sum. Defaults to `"d8"`.
#' @param numeric_fn Function applied to numeric columns during sub-county
#'   aggregation. Defaults to `sum(x, na.rm = TRUE)`.
#' @param drop_territories Logical. If `TRUE` (default), drop AS, GU, MP,
#'   PR, VI from the sub-county aggregation step. Direct-county rows for
#'   these are also dropped.
#' @param drop_alaska Logical. If `TRUE` (default), drop AK from
#'   sub-county aggregation. AK reports at the borough level, which does
#'   not roll up cleanly to county FIPS.
#'
#' @return A tibble with one row per county-equivalent FIPS code, plus an
#'   added `data_source` column (`"direct_county"` or `"aggregated_subcounty"`).
#' @export
#' @examples
#' \dontrun{
#'   eavs <- read_eavs(2024)
#'   county <- aggregate_to_county(eavs)
#' }
aggregate_to_county <- function(df,
                                mode_cols = "d8",
                                numeric_fn = function(x) sum(x, na.rm = TRUE),
                                drop_territories = TRUE,
                                drop_alaska = TRUE) {
  if (!all(c("jurisdiction_type", "county_fips") %in% names(df))) {
    df <- classify_jurisdiction(df)
  }

  drop_states <- character()
  if (drop_territories) drop_states <- c(drop_states, "AS", "GU", "MP", "PR", "VI")
  if (drop_alaska)      drop_states <- c(drop_states, "AK")

  numeric_cols <- names(df)[vapply(df, is.numeric, logical(1))]
  numeric_cols <- setdiff(numeric_cols, grep("fips", numeric_cols, ignore.case = TRUE, value = TRUE))
  sum_cols  <- setdiff(numeric_cols, mode_cols)
  mode_cols <- intersect(mode_cols, names(df))

  direct <- df[df$jurisdiction_type == "County" & !df$state_abbr %in% drop_states, , drop = FALSE]
  direct$data_source <- "direct_county"

  sub <- df[
    df$jurisdiction_type == "Sub-county" &
      !df$is_multi_county &
      !df$state_abbr %in% drop_states &
      !is.na(df$county_fips) &
      !grepl("99$", df$county_fips),
    , drop = FALSE
  ]

  if (nrow(sub) > 0L) {
    agg <- .aggregate_subcounty(
      sub,
      sum_cols   = sum_cols,
      mode_cols  = mode_cols,
      numeric_fn = numeric_fn
    )
    agg$data_source <- "aggregated_subcounty"
  } else {
    agg <- direct[0, , drop = FALSE]
  }

  out <- rbind_fill(direct, agg)
  out <- out[order(out$county_fips, out$data_source != "direct_county"), , drop = FALSE]
  out <- out[!duplicated(out$county_fips), , drop = FALSE]
  tibble::as_tibble(out)
}

# Group sub-county rows by county_fips + state_abbr and summarize.
.aggregate_subcounty <- function(sub, sum_cols, mode_cols, numeric_fn) {
  keys <- paste(sub$county_fips, sub$state_abbr, sep = "|")
  split_idx <- split(seq_len(nrow(sub)), keys)

  rows <- lapply(split_idx, function(idx) {
    row <- list(
      county_fips      = sub$county_fips[idx[1L]],
      state_abbr       = sub$state_abbr[idx[1L]],
      state_fips       = sub$state_fips[idx[1L]],
      n_subjurisdictions = length(idx),
      jurisdiction_type  = "County_Aggregated",
      is_multi_county    = FALSE
    )
    for (col in sum_cols) {
      row[[col]] <- numeric_fn(sub[[col]][idx])
    }
    for (col in mode_cols) {
      row[[col]] <- .modal_value(sub[[col]][idx])
    }
    # Carry-through non-numeric metadata from first row.
    carry <- setdiff(
      names(sub),
      c(sum_cols, mode_cols, names(row), "county_fips", "state_abbr")
    )
    for (col in carry) {
      vals <- sub[[col]][idx]
      row[[col]] <- vals[!is.na(vals)][1L] %||% NA
    }
    row
  })

  rbind_fill_list(rows)
}

.modal_value <- function(x) {
  x <- x[!is.na(x)]
  if (length(x) == 0L) return(NA_real_)
  tab <- table(x)
  as.numeric(names(tab)[which.max(tab)])
}

`%||%` <- function(a, b) if (is.null(a) || length(a) == 0L) b else a

# Row-bind two data frames with possibly different columns.
rbind_fill <- function(a, b) {
  cols <- union(names(a), names(b))
  for (col in setdiff(cols, names(a))) a[[col]] <- NA
  for (col in setdiff(cols, names(b))) b[[col]] <- NA
  rbind(a[, cols, drop = FALSE], b[, cols, drop = FALSE])
}

# Row-bind a list of named lists into a data frame. Each column's type is
# inferred from its values (via unlist), so character, numeric, and logical
# columns are all preserved without a hardcoded name list. Missing cells
# become a type-appropriate NA.
rbind_fill_list <- function(rows) {
  cols <- unique(unlist(lapply(rows, names)))
  data <- lapply(cols, function(col) {
    vals <- lapply(rows, function(r) {
      v <- r[[col]]
      if (is.null(v) || length(v) == 0L) NA else v
    })
    unlist(vals, use.names = FALSE)
  })
  names(data) <- cols
  as.data.frame(data, stringsAsFactors = FALSE)
}
