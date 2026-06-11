test_that("aggregate_to_county prefers direct-county rows over sub-county sums", {
  df <- tibble::tibble(
    fips_code         = c("05031",     "0503112345", "0503100001"),
    jurisdiction_name = c("CRAIGHEAD COUNTY", "JONESBORO", "BAY VILLAGE"),
    state_abbr        = c("AR", "AR", "AR"),
    a1a               = c(50000, 30000, 5000),
    d8                = c(2, 3, 3)
  )
  out <- aggregate_to_county(df)
  expect_equal(nrow(out), 1L)
  expect_equal(out$county_fips, "05031")
  expect_equal(out$data_source, "direct_county")
  expect_equal(out$a1a, 50000)
})

test_that("sub-county rows aggregate by sum when no direct county row exists", {
  df <- tibble::tibble(
    fips_code         = c("0503112345", "0503100001"),
    jurisdiction_name = c("JONESBORO", "BAY VILLAGE"),
    state_abbr        = c("AR", "AR"),
    a1a               = c(30000, 5000),
    d8                = c(3, 3)
  )
  out <- aggregate_to_county(df)
  expect_equal(out$county_fips, "05031")
  expect_equal(out$data_source, "aggregated_subcounty")
  expect_equal(out$a1a, 35000)
  expect_equal(out$d8, 3)
})

test_that("d8 uses modal aggregation, not sum", {
  df <- tibble::tibble(
    fips_code         = c("0503112345", "0503100001", "0503100002"),
    jurisdiction_name = c("A", "B", "C"),
    state_abbr        = c("AR", "AR", "AR"),
    a1a               = c(100, 200, 300),
    d8                = c(2, 3, 3)
  )
  out <- aggregate_to_county(df)
  expect_equal(out$d8, 3)
  expect_equal(out$a1a, 600)
})

test_that("territory rows are dropped by default", {
  df <- tibble::tibble(
    fips_code         = c("78010", "78020"),
    jurisdiction_name = c("ST CROIX", "ST THOMAS"),
    state_abbr        = c("VI", "VI"),
    a1a               = c(1000, 2000),
    d8                = c(1, 1)
  )
  out <- aggregate_to_county(df)
  expect_equal(nrow(out), 0L)
})
