test_that("eavs_cycles() returns the expected structure", {
  out <- eavs_cycles()
  expect_s3_class(out, "tbl_df")
  expect_named(out, c("cycle", "data_url", "data_kind", "codebook_url",
                      "codebook_kind", "status"))
  expect_true(2024 %in% out$cycle)
  expect_true(all(c(2016, 2018, 2020, 2022, 2024) %in%
                    out$cycle[out$status == "supported"]))
})

test_that(".check_cycle validates supported vs planned", {
  expect_error(eavsr:::.check_cycle("hello"), "must be a single integer")
  expect_error(eavsr:::.check_cycle(1999), "Unknown EAVS cycle")
  expect_error(eavsr:::.check_cycle(2008), "planned")
  expect_equal(eavsr:::.check_cycle(2024), 2024L)
})
