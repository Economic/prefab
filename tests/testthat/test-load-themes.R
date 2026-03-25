test_that("load_themes() sources file into global environment", {
  tmp <- withr::local_tempfile(fileext = ".R")
  writeLines('my_test_theme <- function() new_theme()', tmp)

  # Clean up after test
  withr::defer(rm("my_test_theme", envir = globalenv()))

  expect_message(load_themes(tmp), "Loaded themes from")
  expect_true(exists("my_test_theme", envir = globalenv()))
})

test_that("load_themes() returns file path invisibly on success", {
  tmp <- withr::local_tempfile(fileext = ".R")
  writeLines('# empty', tmp)

  result <- withCallingHandlers(
    load_themes(tmp),
    message = function(m) invokeRestart("muffleMessage")
  )
  expect_equal(result, tmp)
})

test_that("load_themes() informs when file not found", {
  expect_message(
    load_themes("/nonexistent/path/themes.R"),
    "No themes file found"
  )
})

test_that("load_themes() returns NULL invisibly when file not found", {
  result <- withCallingHandlers(
    load_themes("/nonexistent/path/themes.R"),
    message = function(m) invokeRestart("muffleMessage")
  )
  expect_null(result)
})

test_that("load_themes() reads PREFAB_THEMES env var", {
  tmp <- withr::local_tempfile(fileext = ".R")
  writeLines('# empty', tmp)
  withr::local_envvar(PREFAB_THEMES = tmp)

  expect_message(load_themes(), "Loaded themes from")
})

test_that("load_themes() falls back to ~/.prefab-themes.R", {
  withr::local_envvar(PREFAB_THEMES = NA)

  # ~/.prefab-themes.R almost certainly doesn't exist in test env

  expect_message(load_themes(), "No themes file found")
})

test_that("load_themes() explicit file overrides env var", {
  tmp <- withr::local_tempfile(fileext = ".R")
  writeLines('# explicit file', tmp)
  withr::local_envvar(PREFAB_THEMES = "/nonexistent/env/var/path.R")

  expect_message(load_themes(tmp), "Loaded themes from")
})
