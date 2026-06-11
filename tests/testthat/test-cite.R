test_that("cite_eavs() produces text, bibtex, and list", {
  txt <- cite_eavs(2024, style = "text")
  expect_type(txt, "character")
  expect_match(txt, "Election Assistance Commission")
  expect_match(txt, "2024")

  bib <- cite_eavs(2024, style = "bibtex")
  expect_match(bib, "@techreport")
  expect_match(bib, "year\\s*=\\s*\\{2025\\}")

  lst <- cite_eavs(2024, style = "list")
  expect_type(lst, "list")
  expect_named(lst, c("author", "year", "title", "publisher", "address", "url"))
})
