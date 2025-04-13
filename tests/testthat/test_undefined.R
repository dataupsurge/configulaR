test_that("test_is_undef", {
  expect_true(is_undefined(structure("UNDEFINED_", class = "UNDEFINED_")))
  expect_false(is_undefined(NULL))
  expect_false(is_undefined(1))
  expect_false(is_undefined("a"))
})
