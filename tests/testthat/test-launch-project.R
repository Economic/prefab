# test-launch-project.R -- tests for launch_project() and build_project_path()

# --- build_project_path() (internal path logic) ---------------------------

test_that("builds path under root with no date subdirectory by default", {
  path <- build_project_path(
    "proj",
    root = "/tmp/root",
    date = FALSE,
    slug = TRUE
  )
  expect_equal(path, fs::path("/tmp/root", "proj"))
})

test_that("date = TRUE nests under a YYYY-MM-DD subdirectory", {
  path <- build_project_path(
    "proj",
    root = "/tmp/root",
    date = TRUE,
    slug = TRUE
  )
  expect_equal(path, fs::path("/tmp/root", format(Sys.Date()), "proj"))
})

test_that("slugifies names by default", {
  path <- build_project_path(
    "Wage Analysis 2026!",
    root = "/tmp/r",
    date = FALSE,
    slug = TRUE
  )
  expect_equal(fs::path_file(path), "wage_analysis_2026")
})

test_that("slug = FALSE uses the name verbatim when valid", {
  path <- build_project_path(
    "my-project.v2",
    root = "/tmp/r",
    date = FALSE,
    slug = FALSE
  )
  expect_equal(fs::path_file(path), "my-project.v2")
})

test_that("slug = FALSE errors on unsafe characters", {
  expect_error(
    build_project_path("bad name", root = "/tmp/r", date = FALSE, slug = FALSE),
    "unsafe"
  )
})

test_that("errors on empty or non-string name", {
  expect_error(
    build_project_path("", root = "/tmp/r", date = FALSE, slug = TRUE),
    "non-empty"
  )
  expect_error(
    build_project_path(42, root = "/tmp/r", date = FALSE, slug = TRUE),
    "non-empty"
  )
})

test_that("errors when name slugifies to empty", {
  expect_error(
    build_project_path("!!!", root = "/tmp/r", date = FALSE, slug = TRUE),
    "empty string"
  )
})

# --- launch_project() (interactive front-end) ------------------------------

test_that("errors when showPrompt is unavailable", {
  # In a non-interactive test run rstudioapi is not available, so the guard
  # fires and directs the user to create_project() instead.
  expect_error(
    launch_project(theme = new_theme(), open = FALSE),
    "not available"
  )
})

test_that("errors when no theme is supplied", {
  skip_if_not_installed("rstudioapi")
  tmp <- withr::local_tempdir()

  # Get past the showPrompt guard so the missing theme is what fails.
  testthat::local_mocked_bindings(
    hasFun = function(...) TRUE,
    showPrompt = function(title, message, ...) "proj",
    .package = "rstudioapi"
  )

  expect_error(launch_project(root = tmp, open = FALSE), "theme")
})

test_that("prompts for a name, scaffolds, and returns the path", {
  skip_if_not_installed("rstudioapi")
  tmp <- withr::local_tempdir()

  testthat::local_mocked_bindings(
    hasFun = function(...) TRUE,
    showPrompt = function(title, message, ...) "wage_analysis",
    .package = "rstudioapi"
  )

  path <- launch_project(
    theme = new_theme(step_text(c("hello"), "out.txt")),
    root = tmp,
    open = FALSE
  )

  expected <- fs::path(tmp, "wage_analysis")
  expect_equal(path, fs::path_abs(expected))
  expect_equal(readLines(fs::path(expected, "out.txt")), "hello")
})

test_that("returns NULL and creates nothing when the prompt is cancelled", {
  skip_if_not_installed("rstudioapi")
  tmp <- withr::local_tempdir()

  testthat::local_mocked_bindings(
    hasFun = function(...) TRUE,
    showPrompt = function(title, message, ...) NULL,
    .package = "rstudioapi"
  )

  result <- launch_project(theme = new_theme(), root = tmp, open = FALSE)

  expect_null(result)
  expect_length(fs::dir_ls(tmp), 0L)
})

test_that("uses label as the prompt title", {
  skip_if_not_installed("rstudioapi")
  tmp <- withr::local_tempdir()
  seen_title <- NULL

  testthat::local_mocked_bindings(
    hasFun = function(...) TRUE,
    showPrompt = function(title, message, ...) {
      seen_title <<- title
      "proj"
    },
    .package = "rstudioapi"
  )

  launch_project(
    theme = new_theme(),
    root = tmp,
    open = FALSE,
    label = "r_targets + claude_r_targets"
  )

  expect_equal(seen_title, "r_targets + claude_r_targets")
})

test_that("defaults the title when no label is given", {
  skip_if_not_installed("rstudioapi")
  tmp <- withr::local_tempdir()
  seen_title <- NULL

  testthat::local_mocked_bindings(
    hasFun = function(...) TRUE,
    showPrompt = function(title, message, ...) {
      seen_title <<- title
      "proj"
    },
    .package = "rstudioapi"
  )

  launch_project(theme = new_theme(), root = tmp, open = FALSE)

  expect_equal(seen_title, "New project folder")
})

test_that("root defaults come from the prefab.project_root option", {
  skip_if_not_installed("rstudioapi")
  tmp <- withr::local_tempdir()
  withr::local_options(prefab.project_root = tmp)

  testthat::local_mocked_bindings(
    hasFun = function(...) TRUE,
    showPrompt = function(title, message, ...) "proj",
    .package = "rstudioapi"
  )

  path <- launch_project(theme = new_theme(), open = FALSE)

  expect_equal(path, fs::path_abs(fs::path(tmp, "proj")))
})

test_that("shows the destination directory in the prompt message", {
  skip_if_not_installed("rstudioapi")
  tmp <- withr::local_tempdir()
  seen_message <- NULL

  testthat::local_mocked_bindings(
    hasFun = function(...) TRUE,
    showPrompt = function(title, message, ...) {
      seen_message <<- message
      "proj"
    },
    .package = "rstudioapi"
  )

  launch_project(theme = new_theme(), root = tmp, open = FALSE)

  # Normalize tmp with fs::path() to match how the message is built (via
  # fs::path_join, which always emits forward slashes): on macOS TMPDIR ends
  # in "/", so tmp can contain a "//"; on Windows tmp uses "\" separators.
  expect_match(seen_message, as.character(fs::path(tmp)), fixed = TRUE)
})

test_that("includes the date subdirectory in the message when date = TRUE", {
  skip_if_not_installed("rstudioapi")
  tmp <- withr::local_tempdir()
  seen_message <- NULL

  testthat::local_mocked_bindings(
    hasFun = function(...) TRUE,
    showPrompt = function(title, message, ...) {
      seen_message <<- message
      "proj"
    },
    .package = "rstudioapi"
  )

  launch_project(theme = new_theme(), root = tmp, date = TRUE, open = FALSE)

  expect_match(seen_message, format(Sys.Date()), fixed = TRUE)
})

test_that("re-prompts with a hint on an invalid name, then proceeds", {
  skip_if_not_installed("rstudioapi")
  tmp <- withr::local_tempdir()
  withr::local_options(prefab.project_slug = FALSE)

  replies <- c("bad name", "good_name")
  attempt <- 0L
  messages <- character()

  testthat::local_mocked_bindings(
    hasFun = function(...) TRUE,
    showPrompt = function(title, message, ...) {
      attempt <<- attempt + 1L
      messages <<- c(messages, message)
      replies[[attempt]]
    },
    .package = "rstudioapi"
  )

  path <- launch_project(theme = new_theme(), root = tmp, open = FALSE)

  expect_equal(attempt, 2L)
  expect_equal(fs::path_file(path), "good_name")
  # The second prompt carries the validation hint prepended to the base message.
  expect_match(messages[[2]], "Use only letters", fixed = TRUE)
})

test_that("build_project_path signals a classed condition for invalid names", {
  cnd <- rlang::catch_cnd(
    build_project_path("bad name", root = "/tmp/r", date = FALSE, slug = FALSE)
  )
  expect_s3_class(cnd, "prefab_invalid_name")
  expect_true(nzchar(cnd$prompt_hint))
})
