context("test-env-reader")

env_file <- load_dot_env(file.path(
  system.file("extdata", package = "configulaR"),
  "tests", "env_file", "env"
))

test_that("test_read_env", {
  expect_is(env_file, "list")
})

test_that("test_env_comment", {
  expect_error(get_var(env_file, "CommentedKey"))
})

test_that("test_env_percent_not_escaped", {
  expect_equal(get_var(env_file, "PercentNotEscaped"), "%%")
})

test_that(" test_env_no_interpolation", {
  expect_equal(get_var(env_file, "NoInterpolation"), "%(KeyOff)s")
})

test_that("test_env_bool_true", {
  expect_true(get_var(env_file, "KeyTrue", cast = "bool"))
  expect_true(get_var(env_file, "KeyTrue", cast = "boolean"))
  expect_true(get_var(env_file, "KeyTrue", cast = "logical"))

  expect_true(get_var(env_file, "KeyOne", cast = "bool"))
  expect_true(get_var(env_file, "KeyYes", cast = "bool"))
  expect_true(get_var(env_file, "KeyOn", cast = "bool"))
  expect_true(get_var(env_file, "KeyY", cast = "bool"))
  expect_true(get_var(env_file, "Key1int", default = 1, cast = "bool"))
})

test_that("test_env_bool_false", {
  expect_false(get_var(env_file, "KeyFalse", cast = "bool"))
  expect_false(get_var(env_file, "KeyFalse", cast = "boolean"))
  expect_false(get_var(env_file, "KeyFalse", cast = "logical"))

  expect_false(get_var(env_file, "KeyZero", cast = "bool"))
  expect_false(get_var(env_file, "KeyNo", cast = "bool"))
  expect_false(get_var(env_file, "KeyOff", cast = "bool"))
  expect_false(get_var(env_file, "KeyN", cast = "bool"))
  expect_false(get_var(env_file, "KeyEmpty", cast = "bool"))
  expect_false(get_var(env_file, "Key0int", default = 0, cast = "bool"))
})

test_that("test_env_bool_int_cast", {
  expect_equal(get_var(env_file, "KeyOneTextSingleQuote", cast = "int"), 1)
  expect_equal(get_var(env_file, "KeyOneTextSingleQuote", cast = "integer"), 1)

  expect_equal(get_var(env_file, "KeyOneTextDoubleQuote", cast = "int"), 1)
})

test_that("test_env_bool_str_cast", {
  expect_equal(get_var(env_file, "KeyOneTextSingleQuote", cast = "str"), "1")
  expect_equal(get_var(env_file, "KeyOneTextSingleQuote", cast = "string"), "1")
  expect_equal(
    get_var(
      env_file,
      "KeyOneTextSingleQuote",
      cast = "character"
    ), "1"
  )

  expect_equal(get_var(env_file, "KeyOneTextDoubleQuote", cast = "str"), "1")
})

test_that("test_inconsistent_cast", {
  expect_error(
    get_var(env_file, "KeyOneTextSingleQuote", cast = "XXX"),
    "Inconsistent cast argument"
  )
})


test_that("test_env_os_environ", {
  Sys.setenv(KeyOverrideByEnv = "This")
  expect_equal(get_var(env_file, "KeyOverrideByEnv"), "This")
  Sys.unsetenv("KeyOverrideByEnv")
})

test_that("test_env_undefined_but_present_in_os_environ", {
  Sys.setenv(KeyOnlyEnviron = "keyonlyenviron")
  expect_equal(get_var(env_file, "KeyOnlyEnviron"), "keyonlyenviron")
  Sys.unsetenv("KeyOnlyEnviron")
})

test_that("test_env_undefined", {
  expect_error(
    get_var(env_file, "UndefinedKey"),
    "Declare it as envvar or define a default value"
  )
})

test_that("test_env_default_none", {
  expect_error(get_var(env_file, "UndefinedKey", default = NULL))
})


test_that("test_env_empty", {
  expect_equal(get_var(env_file, "KeyEmpty"), "")
  expect_equal(get_var(env_file, "KeyEmpty", default = NULL), "")
})

test_that("test_env_support_space", {
  expect_equal(get_var(env_file, "IgnoreSpace"), "text")
})

test_that("test_env_support_space_in_value", {
  expect_equal(get_var(env_file, "RespectSingleQuoteSpace"), " text")
  expect_equal(get_var(env_file, "RespectDoubleQuoteSpace"), " text")
})

test_that("test_env_empty_string_means_false", {
  expect_false(get_var(env_file, "KeyEmpty", cast = "bool"))
})

test_that("test_env_with_quote", {
  expect_equal(get_var(env_file, "KeyWithSingleQuoteEnd"), "text'")
  expect_equal(get_var(env_file, "KeyWithDoubleQuoteEnd"), 'text"')
  expect_equal(get_var(env_file, "KeyWithSingleQuoteMid"), "te'xt")
  expect_equal(get_var(env_file, "KeyWithSingleQuoteBegin"), "'text")
  expect_equal(get_var(env_file, "KeyWithDoubleQuoteMid"), 'te"xt')
  expect_equal(get_var(env_file, "KeyWithDoubleQuoteBegin"), '"text')
  expect_equal(get_var(env_file, "KeyIsDoubleQuote"), '"')
  expect_equal(get_var(env_file, "KeyIsSingleQuote"), "'")
})
