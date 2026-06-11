test_that("eavs_cache_dir() honors EAVSR_CACHE_DIR", {
  tmp <- withr::local_tempdir()
  withr::local_envvar(EAVSR_CACHE_DIR = tmp)
  expect_equal(normalizePath(eavs_cache_dir()), normalizePath(tmp))
})

test_that("eavs_cache_info() returns an empty tibble when cache is empty", {
  tmp <- withr::local_tempdir()
  withr::local_envvar(EAVSR_CACHE_DIR = tmp)
  out <- eavs_cache_info()
  expect_s3_class(out, "tbl_df")
  expect_equal(nrow(out), 0L)
})

test_that("eavs_clear_cache() removes files", {
  tmp <- withr::local_tempdir()
  withr::local_envvar(EAVSR_CACHE_DIR = tmp)
  writeLines("a,b\n1,2", file.path(tmp, "2024_data.csv"))
  expect_equal(eavs_clear_cache(), 1L)
  expect_equal(nrow(eavs_cache_info()), 0L)
})
