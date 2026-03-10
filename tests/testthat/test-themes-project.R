# test-themes-project.R -- tests for r_analysis() and r_targets()

test_that("r_analysis() returns valid prefab_theme", {
  theme <- r_analysis()
  expect_s3_class(theme, "prefab_theme")
  expect_true(length(theme$steps) > 0L)
})

test_that("r_targets() returns valid prefab_theme", {
  theme <- r_targets()
  expect_s3_class(theme, "prefab_theme")
  expect_true(length(theme$steps) > 0L)
})

test_that("r_analysis() source files exist in inst/", {
  expect_true(fs::file_exists(fs::path_package(
    "prefab",
    "r_analysis",
    "main.R"
  )))
  expect_true(fs::file_exists(fs::path_package(
    "prefab",
    "r_analysis",
    "README.md"
  )))
})

test_that("r_targets() source files exist in inst/", {
  expect_true(fs::file_exists(fs::path_package(
    "prefab",
    "r_targets",
    "_targets.R"
  )))
  expect_true(fs::file_exists(fs::path_package(
    "prefab",
    "r_targets",
    "packages.R"
  )))
  expect_true(fs::file_exists(fs::path_package(
    "prefab",
    "r_targets",
    "README.md"
  )))
})

test_that("use_theme(r_analysis()) deploys main.R and README.md", {
  tmp <- withr::local_tempdir()
  file.create(file.path(tmp, ".here"))
  withr::local_dir(tmp)

  use_theme(r_analysis())

  expect_true(fs::file_exists(file.path(tmp, "main.R")))
  expect_true(fs::file_exists(file.path(tmp, "README.md")))
  expect_true(fs::file_exists(file.path(tmp, ".gitignore")))
})

test_that("use_theme(r_targets()) deploys _targets.R and packages.R", {
  tmp <- withr::local_tempdir()
  file.create(file.path(tmp, ".here"))
  withr::local_dir(tmp)

  use_theme(r_targets())

  expect_true(fs::file_exists(file.path(tmp, "_targets.R")))
  expect_true(fs::file_exists(file.path(tmp, "packages.R")))
  expect_true(fs::file_exists(file.path(tmp, "README.md")))
  expect_true(fs::file_exists(file.path(tmp, ".gitignore")))
  expect_true(fs::dir_exists(file.path(tmp, "R")))
})

test_that("re-running r_analysis() is idempotent (skip doesn't clobber)", {
  tmp <- withr::local_tempdir()
  file.create(file.path(tmp, ".here"))
  withr::local_dir(tmp)

  use_theme(r_analysis())
  writeLines("custom content", file.path(tmp, "main.R"))
  use_theme(r_analysis())

  expect_equal(readLines(file.path(tmp, "main.R")), "custom content")
})

test_that("composition works: r_analysis() + claude_r_analysis()", {
  tmp <- withr::local_tempdir()
  file.create(file.path(tmp, ".here"))
  withr::local_dir(tmp)

  theme <- r_analysis() + claude_r_analysis()
  expect_s3_class(theme, "prefab_theme")
  use_theme(theme)

  expect_true(fs::file_exists(file.path(tmp, "main.R")))
  expect_true(fs::file_exists(file.path(tmp, ".claude", "settings.json")))
})

test_that("README.md contains project_dir rendered from auto-context", {
  tmp <- withr::local_tempdir()
  file.create(file.path(tmp, ".here"))
  withr::local_dir(tmp)

  use_theme(r_analysis())

  readme <- readLines(file.path(tmp, "README.md"))
  expect_true(any(grepl(basename(tmp), readme)))
})
