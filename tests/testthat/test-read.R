test_that(".recode_missing turns negatives into NA but preserves FIPS", {
  df <- data.frame(
    fips_code = c("01001", "01003"),
    a1a = c(100, -99),
    f1b = c(-77, 50)
  )
  out <- eavsr:::.recode_missing(df)
  expect_equal(out$fips_code, df$fips_code)
  expect_true(is.na(out$a1a[2]))
  expect_true(is.na(out$f1b[1]))
  expect_equal(out$a1a[1], 100)
  expect_equal(out$f1b[2], 50)
})
