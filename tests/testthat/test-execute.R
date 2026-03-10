# test-execute.R -- tests for execute_theme()

test_that("executing theme with file steps deploys files to temp dir", {
  tmp <- withr::local_tempdir()
  src <- file.path(tmp, "src.R")
  writeLines("hello", src)

  theme <- new_theme(step_file(src, "out.R"))
  execute_theme(theme, tmp)

  expect_equal(readLines(file.path(tmp, "out.R")), "hello")
})

test_that("executing theme with run step calls function with captured args", {
  tmp <- withr::local_tempdir()
  called_with <- NULL

  my_fn <- function(x) {
    called_with <<- x
  }

  theme <- new_theme(step_run(my_fn, x = 42, .label = "my_fn"))
  execute_theme(theme, tmp)

  expect_equal(called_with, 42)
})

test_that("empty theme completes silently", {
  tmp <- withr::local_tempdir()
  theme <- new_theme()
  expect_no_error(execute_theme(theme, tmp))
})

test_that("theme with data = list() renders auto-context", {
  tmp <- withr::local_tempdir()

  src <- file.path(tmp, "template.txt")
  writeLines("# {{project_dir}}", src)

  project <- file.path(tmp, "myproject")
  fs::dir_create(project)

  theme <- new_theme(step_file(src, "out.txt", data = list()))
  execute_theme(theme, project)

  result <- readLines(file.path(project, "out.txt"))
  expect_equal(result, "# myproject")
})

test_that("steps execute in order", {
  tmp <- withr::local_tempdir()
  order <- integer(0)

  fn1 <- function() order <<- c(order, 1L)
  fn2 <- function() order <<- c(order, 2L)
  fn3 <- function() order <<- c(order, 3L)

  theme <- new_theme(
    step_run(fn1, .label = "fn1"),
    step_run(fn2, .label = "fn2"),
    step_run(fn3, .label = "fn3")
  )
  execute_theme(theme, tmp)

  expect_equal(order, 1:3)
})

test_that("aborts on failing step with informative error", {
  tmp <- withr::local_tempdir()

  good_fn <- function() "ok"
  bad_fn <- function() stop("intentional error")

  theme <- new_theme(
    step_run(good_fn, .label = "good"),
    step_run(bad_fn, .label = "bad_fn"),
    step_run(good_fn, .label = "never_reached")
  )

  expect_error(
    execute_theme(theme, tmp),
    "step 2/3"
  )
})

test_that("CLI output shows (new) for new files", {
  tmp <- withr::local_tempdir()
  src <- file.path(tmp, "src.R")
  writeLines("content", src)

  theme <- new_theme(step_file(src, "out.R"))
  expect_message(
    execute_theme(theme, tmp),
    "new"
  )
})

test_that("CLI output shows (overwrite) for existing files", {
  tmp <- withr::local_tempdir()
  src <- file.path(tmp, "src.R")
  writeLines("content", src)
  writeLines("old", file.path(tmp, "out.R"))

  theme <- new_theme(step_file(src, "out.R"))
  expect_message(
    execute_theme(theme, tmp),
    "overwrite"
  )
})

test_that("step_text step deploys expected content", {
  tmp <- withr::local_tempdir()

  theme <- new_theme(step_text(c("line1", "line2"), "out.txt"))
  execute_theme(theme, tmp)

  expect_equal(readLines(file.path(tmp, "out.txt")), c("line1", "line2"))
})
