#' Citation for an EAVS cycle
#'
#' Returns a properly formatted citation for an EAVS cycle's report and
#' codebook. The EAC requests that researchers cite the underlying EAVS
#' release; this helper builds the recommended citation string.
#'
#' @param cycle Integer year of the EAVS cycle.
#' @param style One of `"text"` (a single citation string, the default),
#'   `"bibtex"`, or `"list"` (a structured list with fields).
#'
#' @return A character string (or list, for `style = "list"`).
#' @export
#' @examples
#' cite_eavs(2024)
#' cite_eavs(2024, style = "bibtex")
cite_eavs <- function(cycle, style = c("text", "bibtex", "list")) {
  style <- match.arg(style)
  cycle <- .check_cycle(cycle, require_supported = FALSE)

  fields <- list(
    author = "U.S. Election Assistance Commission",
    year   = cycle + 1L,
    title  = sprintf("%d Election Administration and Voting Survey Comprehensive Report", cycle),
    publisher = "U.S. Election Assistance Commission",
    address = "Washington, DC",
    url = "https://www.eac.gov/research-and-data/studies-and-reports"
  )

  switch(style,
    text = sprintf(
      "%s (%d). %s. %s, %s. %s",
      fields$author, fields$year, fields$title,
      fields$publisher, fields$address, fields$url
    ),
    bibtex = sprintf(
      "@techreport{eac_eavs_%d,\n  author    = {{%s}},\n  title     = {{%s}},\n  institution = {{%s}},\n  address   = {%s},\n  year      = {%d},\n  url       = {%s}\n}",
      cycle, fields$author, fields$title,
      fields$publisher, fields$address, fields$year, fields$url
    ),
    list = fields
  )
}
