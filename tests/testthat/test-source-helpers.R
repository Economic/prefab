# test-source-helpers.R -- tests for from_package(), from_dir()

# -- from_package() ------------------------------------------------------------

test_that("from_package() returns a function", {
  builder <- from_package("prefab")
  expect_true(is.function(builder))
})

test_that("from_package() step-builder returns prefab_step_file with correct path", {
  builder <- from_package("prefab")
  s <- builder("claude/settings.json", ".claude/settings.json", strategy = "merge_json")
  expect_s3_class(s, "prefab_step_file")
  expect_true(fs::is_absolute_path(s$source))
  expect_true(fs::file_exists(s$source))
  expect_equal(s$dest, ".claude/settings.json")
  expect_equal(s$strategy, "merge_json")
})

test_that("from_package() attaches correct provenance", {
  builder <- from_package("prefab")
  s <- builder("claude/settings.json", ".claude/settings.json")
  expect_equal(s$provenance$helper, "from_package")
  expect_equal(s$provenance$package, "prefab")
  expect_equal(s$provenance$relative_path, "claude/settings.json")
})

test_that("from_package() errors when source file doesn't exist", {
  builder <- from_package("prefab")
  expect_error(
    builder("nonexistent_file.txt", "dest.txt"),
    "not found"
  )
})

test_that("from_package() step-builder works when source is a directory", {
  builder <- from_package("prefab")
  # claude/rules/ is a directory in the prefab package
  s <- builder("claude/rules", ".claude/rules")
  expect_s3_class(s, "prefab_step_file")
  expect_true(fs::dir_exists(s$source))
})

test_that("from_package() step-builder forwards data to step_file", {
  builder <- from_package("prefab")
  s <- builder(
    "claude/settings.json", ".claude/settings.json",
    data = list(x = 1)
  )
  expect_equal(s$data, list(x = 1))
})

# -- from_dir() ----------------------------------------------------------------

test_that("from_dir() returns a function", {
  tmp <- withr::local_tempdir()
  builder <- from_dir(tmp)
  expect_true(is.function(builder))
})

test_that("from_dir() errors when directory doesn't exist", {
  expect_error(
    from_dir("/nonexistent/path/to/dir"),
    "does not exist"
  )
})

test_that("from_dir() step-builder returns prefab_step_file with correct path", {
  tmp <- withr::local_tempdir()
  writeLines("hello", fs::path(tmp, "test.txt"))

  builder <- from_dir(tmp)
  s <- builder("test.txt", "dest.txt", strategy = "skip")
  expect_s3_class(s, "prefab_step_file")
  expect_true(fs::is_absolute_path(s$source))
  expect_true(fs::file_exists(s$source))
  expect_equal(s$dest, "dest.txt")
  expect_equal(s$strategy, "skip")
})

test_that("from_dir() attaches correct provenance with raw path", {
  tmp <- withr::local_tempdir()
  writeLines("hello", fs::path(tmp, "test.txt"))

  builder <- from_dir(tmp)
  s <- builder("test.txt", "dest.txt")
  expect_equal(s$provenance$helper, "from_dir")
  expect_equal(s$provenance$path, tmp)
  expect_equal(s$provenance$relative_path, "test.txt")
})

test_that("from_dir() step-builder errors when source doesn't exist", {
  tmp <- withr::local_tempdir()
  builder <- from_dir(tmp)
  expect_error(
    builder("nonexistent.txt", "dest.txt"),
    "not found"
  )
})

test_that("from_dir() step-builder works when source is a directory", {
  tmp <- withr::local_tempdir()
  sub <- fs::path(tmp, "subdir")
  fs::dir_create(sub)
  writeLines("content", fs::path(sub, "file.txt"))

  builder <- from_dir(tmp)
  s <- builder("subdir", "dest_dir")
  expect_s3_class(s, "prefab_step_file")
  expect_true(fs::dir_exists(s$source))
})

test_that("from_dir() step-builder forwards data to step_file", {
  tmp <- withr::local_tempdir()
  writeLines("hello", fs::path(tmp, "test.txt"))

  builder <- from_dir(tmp)
  s <- builder("test.txt", "dest.txt", data = list(a = "b"))
  expect_equal(s$data, list(a = "b"))
})
