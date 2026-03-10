# test-use-theme.R -- tests for use_theme()

test_that("applies theme to temp project dir", {
  tmp <- withr::local_tempdir()
  file.create(file.path(tmp, ".here"))
  withr::local_dir(tmp)

  theme <- new_theme(step_text(c("hello"), "out.txt"))
  result <- use_theme(theme)

  expect_equal(readLines(file.path(tmp, "out.txt")), "hello")
})

test_that("errors on non-theme input", {
  expect_error(use_theme("not a theme"), "prefab_theme")
  expect_error(use_theme(42), "prefab_theme")
  expect_error(use_theme(list()), "prefab_theme")
})

test_that("discovers project root from subdirectory", {
  tmp <- withr::local_tempdir()
  file.create(file.path(tmp, ".here"))
  sub <- file.path(tmp, "sub", "dir")
  fs::dir_create(sub)
  withr::local_dir(sub)

  theme <- new_theme(step_text(c("found it"), "marker.txt"))
  result <- use_theme(theme)

  expect_true(fs::file_exists(file.path(tmp, "marker.txt")))
  expect_false(fs::file_exists(file.path(sub, "marker.txt")))
})

test_that("returns project root invisibly", {
  tmp <- withr::local_tempdir()
  file.create(file.path(tmp, ".here"))
  withr::local_dir(tmp)

  theme <- new_theme()
  result <- use_theme(theme)

  expect_invisible(use_theme(theme))
  expect_equal(normalizePath(result), normalizePath(tmp))
})
