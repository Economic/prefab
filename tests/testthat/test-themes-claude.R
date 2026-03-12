# test-themes-claude.R -- tests for claude_r_analysis(), claude_r_targets(),
# and claude_r_package()

test_that("claude_r_analysis() returns valid prefab_theme", {
  theme <- claude_r_analysis()
  expect_s3_class(theme, "prefab_theme")
  expect_true(length(theme$steps) > 0L)
})

test_that("claude_r_targets() returns valid prefab_theme", {
  theme <- claude_r_targets()
  expect_s3_class(theme, "prefab_theme")
  expect_true(length(theme$steps) > 0L)
})

test_that("claude_r_package() returns valid prefab_theme", {
  theme <- claude_r_package()
  expect_s3_class(theme, "prefab_theme")
  expect_true(length(theme$steps) > 0L)
})

test_that("claude source files exist in inst/", {
  expect_true(fs::file_exists(fs::path_package(
    "prefab",
    "claude",
    "settings.json"
  )))
  expect_true(fs::file_exists(fs::path_package(
    "prefab",
    "claude",
    "rules",
    "r_analysis.md"
  )))
  expect_true(fs::file_exists(fs::path_package(
    "prefab",
    "claude",
    "rules",
    "r_targets.md"
  )))
  expect_true(fs::file_exists(fs::path_package(
    "prefab",
    "claude",
    "rules",
    "r_package.md"
  )))
})

test_that("use_theme(claude_r_analysis()) deploys settings.json and rules", {
  tmp <- withr::local_tempdir()
  file.create(file.path(tmp, ".here"))
  withr::local_dir(tmp)

  use_theme(claude_r_analysis())

  expect_true(fs::file_exists(file.path(tmp, ".claude", "settings.json")))
  expect_true(fs::file_exists(file.path(
    tmp,
    ".claude",
    "rules",
    "r_analysis.md"
  )))
  expect_true(fs::file_exists(file.path(tmp, ".gitignore")))
})

test_that("use_theme(claude_r_targets()) deploys settings.json and rules", {
  tmp <- withr::local_tempdir()
  file.create(file.path(tmp, ".here"))
  withr::local_dir(tmp)

  use_theme(claude_r_targets())

  expect_true(fs::file_exists(file.path(tmp, ".claude", "settings.json")))
  expect_true(fs::file_exists(file.path(
    tmp,
    ".claude",
    "rules",
    "r_targets.md"
  )))
  expect_true(fs::file_exists(file.path(tmp, ".gitignore")))
})

test_that("re-running claude_r_analysis() is idempotent (merge_json merges correctly)", {
  tmp <- withr::local_tempdir()
  file.create(file.path(tmp, ".here"))
  withr::local_dir(tmp)

  use_theme(claude_r_analysis())
  first_settings <- readLines(file.path(tmp, ".claude", "settings.json"))

  use_theme(claude_r_analysis())
  second_settings <- readLines(file.path(tmp, ".claude", "settings.json"))

  expect_equal(first_settings, second_settings)
})

test_that("use_theme(claude_r_package()) deploys settings.json, rules, and .Rbuildignore", {
  tmp <- withr::local_tempdir()
  file.create(file.path(tmp, ".here"))
  withr::local_dir(tmp)

  use_theme(claude_r_package())

  expect_true(fs::file_exists(file.path(tmp, ".claude", "settings.json")))
  expect_true(fs::file_exists(file.path(
    tmp,
    ".claude",
    "rules",
    "r_package.md"
  )))
  expect_true(fs::file_exists(file.path(tmp, ".gitignore")))
  expect_true(fs::file_exists(file.path(tmp, ".Rbuildignore")))
})

test_that("claude_r_package() .Rbuildignore contains expected patterns", {
  tmp <- withr::local_tempdir()
  file.create(file.path(tmp, ".here"))
  withr::local_dir(tmp)

  use_theme(claude_r_package())

  lines <- readLines(file.path(tmp, ".Rbuildignore"))
  expect_true("^\\.claude$" %in% lines)
  expect_true("^CLAUDE\\.md$" %in% lines)
})

test_that("re-running claude_r_package() is idempotent", {
  tmp <- withr::local_tempdir()
  file.create(file.path(tmp, ".here"))
  withr::local_dir(tmp)

  use_theme(claude_r_package())
  first_settings <- readLines(file.path(tmp, ".claude", "settings.json"))
  first_rbuildignore <- readLines(file.path(tmp, ".Rbuildignore"))

  use_theme(claude_r_package())
  second_settings <- readLines(file.path(tmp, ".claude", "settings.json"))
  second_rbuildignore <- readLines(file.path(tmp, ".Rbuildignore"))

  expect_equal(first_settings, second_settings)
  expect_equal(first_rbuildignore, second_rbuildignore)
})

test_that("composition works: r_analysis() + claude_r_analysis()", {
  tmp <- withr::local_tempdir()
  file.create(file.path(tmp, ".here"))
  withr::local_dir(tmp)

  theme <- r_analysis() + claude_r_analysis()
  use_theme(theme)

  expect_true(fs::file_exists(file.path(tmp, "main.R")))
  expect_true(fs::file_exists(file.path(tmp, ".claude", "settings.json")))
  expect_true(fs::file_exists(file.path(
    tmp,
    ".claude",
    "rules",
    "r_analysis.md"
  )))
})
