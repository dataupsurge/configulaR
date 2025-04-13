context("test-to_logical")

test_that("test_TRUE", {
  out <- to_logical(c("y", "yes", "t", "true", "1"))
  expect_equal(unique(out), TRUE)
})

test_that("test_FALSE", {
  out <- to_logical(c("n", "no", "f", "false", "0"))
  expect_equal(unique(out), FALSE)
})
