# test-theme.R -- tests for new_theme(), +.prefab_theme, print.prefab_theme, theme_code()

# -- new_theme() ---------------------------------------------------------------

test_that("new_theme() constructs a valid theme from steps", {
  s1 <- step_file("/tmp/a.R", "a.R")
  s2 <- step_run(identity)
  t <- new_theme(s1, s2)
  expect_s3_class(t, "prefab_theme")
  expect_length(t$steps, 2)
})

test_that("new_theme() errors on non-step arguments", {
  expect_error(new_theme("not a step"), "step object")
  expect_error(new_theme(42), "step object")
})

test_that("new_theme() silently drops NULL arguments", {
  s1 <- step_file("/tmp/a.R", "a.R")
  t <- new_theme(s1, NULL)
  expect_length(t$steps, 1)
})

test_that("new_theme(step, NULL, step) produces a theme with two steps", {
  s1 <- step_file("/tmp/a.R", "a.R")
  s2 <- step_text("line", "b.txt")
  t <- new_theme(s1, NULL, s2)
  expect_length(t$steps, 2)
})

test_that("new_theme() with zero arguments returns a valid empty theme", {
  t <- new_theme()
  expect_s3_class(t, "prefab_theme")
  expect_length(t$steps, 0)
})

test_that("new_theme() accepts step_text objects", {
  s <- step_text("line", "dest.txt")
  t <- new_theme(s)
  expect_length(t$steps, 1)
  expect_s3_class(t$steps[[1]], "prefab_step_text")
})

# -- + operator ----------------------------------------------------------------

test_that("+ concatenates themes with step order preserved", {
  s1 <- step_file("/tmp/a.R", "a.R")
  s2 <- step_file("/tmp/b.R", "b.R")
  t1 <- new_theme(s1)
  t2 <- new_theme(s2)
  combined <- t1 + t2
  expect_s3_class(combined, "prefab_theme")
  expect_length(combined$steps, 2)
  expect_equal(combined$steps[[1]]$dest, "a.R")
  expect_equal(combined$steps[[2]]$dest, "b.R")
})

test_that("+ errors when second operand is not a prefab_theme", {
  t <- new_theme(step_file("/tmp/a.R", "a.R"))
  expect_error(t + 42, "prefab_theme")
})

test_that("theme + step gives helpful error suggesting new_theme()", {
  t <- new_theme(step_file("/tmp/a.R", "a.R"))
  s <- step_file("/tmp/b.R", "b.R")
  expect_error(t + s, "Can't add a step directly")
  expect_error(t + s, "new_theme")
})

test_that("step + theme gives helpful error suggesting new_theme()", {
  s <- step_file("/tmp/a.R", "a.R")
  t <- new_theme(step_file("/tmp/b.R", "b.R"))
  expect_error(s + t, "Can't add a step directly")
  expect_error(s + t, "new_theme")
})

test_that("new_theme() + some_theme equals some_theme (identity element)", {
  s <- step_file("/tmp/a.R", "a.R")
  t <- new_theme(s)
  empty <- new_theme()
  combined <- empty + t
  expect_length(combined$steps, 1)
  expect_equal(combined$steps[[1]]$dest, "a.R")
})

test_that("some_theme + new_theme() equals some_theme (right identity)", {
  s <- step_file("/tmp/a.R", "a.R")
  t <- new_theme(s)
  empty <- new_theme()
  combined <- t + empty
  expect_length(combined$steps, 1)
  expect_equal(combined$steps[[1]]$dest, "a.R")
})

# -- print.prefab_theme --------------------------------------------------------

test_that("print() produces output without error", {
  s1 <- step_file("/tmp/a.R", "a.R")
  s2 <- step_text("line", "b.txt", strategy = "union")
  s3 <- step_run(identity)
  t <- new_theme(s1, s2, s3)
  expect_no_error(capture.output(print(t), type = "message"))
})

test_that("print() returns the theme invisibly", {
  t <- new_theme(step_file("/tmp/a.R", "a.R"))
  expect_invisible(print(t))
})

# -- theme_code() --------------------------------------------------------------

test_that("theme_code() produces output without error", {
  t <- new_theme(
    step_file("/tmp/a.R", "a.R"),
    step_text(c("line1", "line2"), "b.txt", strategy = "union"),
    step_run(identity, x = 1)
  )
  expect_output(theme_code(t))
})

test_that("theme_code() returns a character(1) invisibly", {
  t <- new_theme(step_file("/tmp/a.R", "a.R"))
  result <- withr::with_output_sink(tempfile(), theme_code(t))
  expect_type(result, "character")
  expect_length(result, 1)
})

test_that("theme_code() output is parseable R code", {
  t <- new_theme(
    step_file("/tmp/a.R", "a.R"),
    step_text(c("line1"), "b.txt", strategy = "union")
  )
  code <- withr::with_output_sink(tempfile(), theme_code(t))
  expect_no_error(parse(text = code))
})

test_that("theme_code() uses provenance for portable output", {
  builder <- from_package("prefab")
  s <- builder(
    "claude/settings.json",
    ".claude/settings.json",
    strategy = "merge_json"
  )
  t <- new_theme(s)
  code <- withr::with_output_sink(tempfile(), theme_code(t))
  expect_match(code, "from_package")
  expect_match(code, "prefab")
})

test_that("theme_code() falls back to step_file() without provenance", {
  s <- step_file("/tmp/a.R", "a.R")
  t <- new_theme(s)
  code <- withr::with_output_sink(tempfile(), theme_code(t))
  expect_match(code, "step_file")
})

test_that("theme_code() with named-function step_run produces parseable code", {
  t <- new_theme(step_run(identity, x = 1))
  code <- withr::with_output_sink(tempfile(), theme_code(t))
  expect_no_error(parse(text = code))
})

test_that("theme_code() with anonymous-function step_run produces output without error", {
  t <- new_theme(step_run(function(x) x + 1, .label = "anon"))
  expect_output(theme_code(t))
})

test_that("theme_code() for empty theme", {
  t <- new_theme()
  code <- withr::with_output_sink(tempfile(), theme_code(t))
  expect_equal(code, "new_theme()")
})

test_that("theme_code() roundtrip for file steps with provenance", {
  builder <- from_package("prefab")
  s <- builder(
    "claude/settings.json",
    ".claude/settings.json",
    strategy = "merge_json"
  )
  t <- new_theme(s)
  code <- withr::with_output_sink(tempfile(), theme_code(t))
  # Evaluate the code to get a reconstructed theme
  reconstructed <- eval(parse(text = code))
  expect_s3_class(reconstructed, "prefab_theme")
  expect_length(reconstructed$steps, 1)
  expect_equal(reconstructed$steps[[1]]$source, s$source)
  expect_equal(reconstructed$steps[[1]]$dest, s$dest)
  expect_equal(reconstructed$steps[[1]]$strategy, s$strategy)
})

test_that("theme_code() roundtrip for step_text", {
  s <- step_text(c("line1", "line2"), "dest.txt", strategy = "union")
  t <- new_theme(s)
  code <- withr::with_output_sink(tempfile(), theme_code(t))
  reconstructed <- eval(parse(text = code))
  expect_s3_class(reconstructed, "prefab_theme")
  expect_equal(reconstructed$steps[[1]]$content, c("line1", "line2"))
  expect_equal(reconstructed$steps[[1]]$dest, "dest.txt")
  expect_equal(reconstructed$steps[[1]]$strategy, "union")
})

test_that("theme_code() includes non-default strategy for step_file", {
  s <- step_file("/tmp/a.R", "a.R", strategy = "skip")
  t <- new_theme(s)
  code <- withr::with_output_sink(tempfile(), theme_code(t))
  expect_match(code, "skip")
})

test_that("theme_code() omits strategy when default (overwrite)", {
  s <- step_file("/tmp/a.R", "a.R", strategy = "overwrite")
  t <- new_theme(s)
  code <- withr::with_output_sink(tempfile(), theme_code(t))
  # Should not contain 'strategy = "overwrite"' since it's the default
  expect_no_match(code, 'strategy = "overwrite"')
})

test_that("theme_code() includes data argument when present", {
  s <- step_file("/tmp/a.R", "a.R", data = list(x = 1))
  t <- new_theme(s)
  code <- withr::with_output_sink(tempfile(), theme_code(t))
  expect_match(code, "data")
})

test_that("theme_code() from_dir provenance roundtrip", {
  tmp <- withr::local_tempdir()
  writeLines("hello", fs::path(tmp, "test.txt"))
  builder <- from_dir(tmp)
  s <- builder("test.txt", "dest.txt", strategy = "skip")
  t <- new_theme(s)
  code <- withr::with_output_sink(tempfile(), theme_code(t))
  expect_match(code, "from_dir")
  # Verify it parses
  expect_no_error(parse(text = code))
})
