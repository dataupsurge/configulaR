context("test-init-config")

# Create test dir in temp to avoid hidden files in package
test_temp_dir <- file.path(tempdir(), random_string(5))
dir.create(test_temp_dir)
on.exit(unlink(test_temp_dir, recursive = TRUE))

file.copy(file.path(
  system.file("extdata", package = "configulaR"),
  "tests"
), test_temp_dir, recursive = TRUE)
file.rename(
  file.path(test_temp_dir, "tests", "env"),
  file.path(test_temp_dir, "tests", ".env")
)
file.rename(
  file.path(test_temp_dir, "tests", "env_file", "env"),
  file.path(test_temp_dir, "tests", ".env")
)

test_that("test_init_env", {
  env_from_get_config <- get_config(path = file.path(
    test_temp_dir,
    "tests",
    "env_file"
  ))
  expect_is(env_from_get_config, "list")

  env_from_fpath <- load_dot_env(file.path(
    system.file("extdata", package = "configulaR"),
    "tests", "env_file", "env"
  ))
  expect_is(env_from_fpath, "list")

  expect_equal(env_from_get_config, env_from_fpath)
})

test_that("test_get_config_here", {
  withr::local_dir(test_temp_dir)
  ini_from_here <- get_config()
  expect_is(ini_from_here, "list")
})
