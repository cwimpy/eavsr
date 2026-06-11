make_df <- function(...) {
  rows <- list(...)
  do.call(rbind, lapply(rows, function(r) as.data.frame(r, stringsAsFactors = FALSE)))
}

test_that("classify_jurisdiction errors on missing columns", {
  expect_error(
    classify_jurisdiction(data.frame(foo = 1)),
    "required column"
  )
})

test_that("classify_jurisdiction handles state, county, sub-county FIPS widths", {
  # EAVS FIPS forms: 2-digit = state; 5-digit = county; 10-digit ending
  # in 00000 = county (padded form); 10-digit not ending in 00000 = a
  # real sub-county (township/MCD).
  df <- make_df(
    list(fips_code = "05",         jurisdiction_name = "ARKANSAS",         state_abbr = "AR"),
    list(fips_code = "05031",      jurisdiction_name = "CRAIGHEAD COUNTY", state_abbr = "AR"),
    list(fips_code = "0503100000", jurisdiction_name = "CRAIGHEAD COUNTY", state_abbr = "AR"),
    list(fips_code = "0503112345", jurisdiction_name = "JONESBORO",        state_abbr = "AR")
  )
  out <- classify_jurisdiction(df)
  expect_equal(out$jurisdiction_type, c("State", "County", "County", "Sub-county"))
  expect_equal(out$county_fips, c(NA, "05031", "05031", "05031"))
  expect_equal(out$state_fips, c("05", "05", "05", "05"))
})

test_that("multi-county jurisdictions get NA county_fips", {
  df <- make_df(
    list(fips_code = "12345", jurisdiction_name = "MULTIPLE COUNTIES JURISDICTION", state_abbr = "MA")
  )
  out <- classify_jurisdiction(df)
  expect_true(out$is_multi_county)
  expect_equal(out$jurisdiction_type, "Multi-county")
  expect_true(is.na(out$county_fips))
})

test_that("CT towns map to planning region FIPS across all regions", {
  df <- make_df(
    list(fips_code = "0900000001", jurisdiction_name = "HARTFORD TOWN",    state_abbr = "CT"),
    list(fips_code = "0900000002", jurisdiction_name = "BRIDGEPORT TOWN",  state_abbr = "CT"),
    list(fips_code = "0900000003", jurisdiction_name = "MIDDLETOWN TOWN",  state_abbr = "CT"),
    list(fips_code = "0900000004", jurisdiction_name = "NEW HAVEN TOWN",   state_abbr = "CT"),
    list(fips_code = "0900000005", jurisdiction_name = "DANBURY TOWN",     state_abbr = "CT")
  )
  out <- classify_jurisdiction(df)
  expect_equal(out$county_fips, c("09110", "09120", "09130", "09170", "09190"))
})

test_that("WI municipalities map to county FIPS via the name lookup", {
  # WI EAVS codes are an internal sequence, not FIPS; the county comes from
  # the jurisdiction name and state FIPS is set explicitly to 55.
  df <- make_df(
    list(fips_code = "00175", jurisdiction_name = "TOWN OF ABRAMS - OCONTO COUNTY", state_abbr = "WI"),
    list(fips_code = "00275", jurisdiction_name = "CITY OF ADAMS - ADAMS COUNTY",   state_abbr = "WI")
  )
  out <- classify_jurisdiction(df)
  expect_equal(out$jurisdiction_type, c("Sub-county", "Sub-county"))
  expect_equal(out$county_fips, c("55083", "55001"))
  expect_equal(out$state_fips, c("55", "55"))
})
