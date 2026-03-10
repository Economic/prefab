# test-step.R -- tests for step_file(), step_text(), step_run()

# -- step_file() --------------------------------------------------------------

test_that("step_file() returns correct class and fields", {
  s <- step_file("/tmp/src.R", "dest.R")
  expect_s3_class(s, "prefab_step_file")
  expect_equal(s$source, "/tmp/src.R")
  expect_equal(s$dest, "dest.R")
  expect_equal(s$strategy, "overwrite")
  expect_null(s$data)
  expect_null(s$provenance)
})

test_that("step_file() accepts all valid strategies", {
  for (strat in c("overwrite", "skip", "union", "append", "merge_json")) {
    s <- step_file("/tmp/src.R", "dest.R", strategy = strat)
    expect_equal(s$strategy, strat)
  }
})

test_that("step_file() errors on invalid strategy", {
  expect_error(
    step_file("/tmp/src.R", "dest.R", strategy = "bad"),
    "strategy"
  )
})

test_that("step_file() errors on relative source path", {
  expect_error(
    step_file("relative/src.R", "dest.R"),
    "source"
  )
})

test_that("step_file() errors on absolute dest path", {
  expect_error(
    step_file("/tmp/src.R", "/absolute/dest.R"),
    "dest"
  )
})

test_that("step_file(data = NULL) stores NULL (static copy)", {
  s <- step_file("/tmp/src.R", "dest.R", data = NULL)
  expect_null(s$data)
})

test_that("step_file(data = list(x = 1)) stores the list", {
  s <- step_file("/tmp/src.R", "dest.R", data = list(x = 1))
  expect_equal(s$data, list(x = 1))
})

test_that("step_file() errors when data is not a named list", {
  expect_error(
    step_file("/tmp/src.R", "dest.R", data = "not a list"),
    "data"
  )
  expect_error(
    step_file("/tmp/src.R", "dest.R", data = 42),
    "data"
  )
})

test_that("step_file() errors when data is an unnamed list", {
  expect_error(
    step_file("/tmp/src.R", "dest.R", data = list(1, 2)),
    "data"
  )
})

test_that("step_file() errors when data is a partially-named list", {
  expect_error(
    step_file("/tmp/src.R", "dest.R", data = list(x = 1, 2)),
    "data"
  )
})

test_that("step_file() called directly has provenance = NULL", {
  s <- step_file("/tmp/src.R", "dest.R")
  expect_null(s$provenance)
})

# -- step_text() ---------------------------------------------------------------

test_that("step_text() returns correct class and fields", {
  s <- step_text(c("line1", "line2"), "dest.txt")
  expect_s3_class(s, "prefab_step_text")
  expect_equal(s$content, c("line1", "line2"))
  expect_equal(s$dest, "dest.txt")
  expect_equal(s$strategy, "overwrite")
})

test_that("step_text() accepts character(0) for non-merge_json strategies", {
  s <- step_text(character(0), "dest.txt", strategy = "overwrite")
  expect_equal(s$content, character(0))
})

test_that("step_text() errors on invalid strategy", {
  expect_error(
    step_text("line", "dest.txt", strategy = "bad"),
    "strategy"
  )
})

test_that("step_text() errors on absolute dest path", {
  expect_error(
    step_text("line", "/absolute/dest.txt"),
    "dest"
  )
})

test_that("step_text(character(0), ..., strategy = 'merge_json') errors", {
  expect_error(
    step_text(character(0), "dest.json", strategy = "merge_json"),
    "content"
  )
})

test_that("step_text() errors when content is not character", {
  expect_error(
    step_text(42, "dest.txt"),
    "content"
  )
})

# -- step_run() ----------------------------------------------------------------

test_that("step_run() returns correct class and fields", {
  s <- step_run(identity, x = 1)
  expect_s3_class(s, "prefab_step_run")
  expect_equal(s$fn, identity)
  expect_equal(s$args, list(x = 1))
})

test_that("step_run() errors when fn is not a function", {
  expect_error(
    step_run("not_a_function"),
    "fn"
  )
})

test_that("step_run() captures label via deparse(substitute(fn))", {
  s <- step_run(identity)
  expect_equal(s$label, "identity")
})

test_that("step_run() uses .label when provided", {
  s <- step_run(identity, .label = "my_label")
  expect_equal(s$label, "my_label")
})

test_that("step_run() captures args via list(...)", {
  s <- step_run(identity, a = 1, b = "x")
  expect_equal(s$args, list(a = 1, b = "x"))
})

test_that("step_run() with no extra args has empty args list", {
  s <- step_run(identity)
  expect_equal(s$args, list())
})

# -- step classes include prefab_step base class --------------------------------

test_that("step_file has prefab_step base class", {
  s <- step_file("/tmp/src.R", "dest.R")
  expect_s3_class(s, "prefab_step")
})

test_that("step_text has prefab_step base class", {
  s <- step_text("line", "dest.txt")
  expect_s3_class(s, "prefab_step")
})

test_that("step_run has prefab_step base class", {
  s <- step_run(identity)
  expect_s3_class(s, "prefab_step")
})
