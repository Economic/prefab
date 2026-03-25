# -- Phase 0: data = "auto" ----------------------------------------------------

test_that("step_file() accepts data = 'auto'", {
  tmp <- withr::local_tempfile(fileext = ".txt")
  writeLines("hello", tmp)
  step <- step_file(tmp, "out.txt", data = "auto")
  expect_equal(step$data, "auto")
})

test_that("data = 'auto' produces same rendering as data = list()", {
  tmp_dir <- withr::local_tempdir()
  src <- file.path(tmp_dir, "template.txt")
  writeLines("Project: {{project_dir}}", src)

  dest_auto <- file.path(tmp_dir, "out_auto.txt")
  dest_list <- file.path(tmp_dir, "out_list.txt")

  auto_context <- build_auto_context(tmp_dir)

  deploy_file(src, "out_auto.txt", "overwrite", "auto", auto_context, tmp_dir)
  deploy_file(src, "out_list.txt", "overwrite", list(), auto_context, tmp_dir)

  expect_equal(readLines(dest_auto), readLines(dest_list))
})

test_that("validate_data() rejects non-'auto' strings", {
  expect_error(validate_data("foo"), "auto")
})

# -- Phase 1: core theme_from_dir() -------------------------------------------

test_that("theme_from_dir() creates steps from directory files", {
  tmp_dir <- withr::local_tempdir()
  writeLines("hello", file.path(tmp_dir, "a.txt"))
  writeLines("world", file.path(tmp_dir, "b.txt"))

  theme <- theme_from_dir(tmp_dir)
  expect_s3_class(theme, "prefab_theme")
  expect_length(theme$steps, 2)
  expect_equal(theme$steps[[1]]$dest, "a.txt")
  expect_equal(theme$steps[[2]]$dest, "b.txt")
})

test_that("theme_from_dir() preserves nested directory structure in dest", {
  tmp_dir <- withr::local_tempdir()
  fs::dir_create(file.path(tmp_dir, "R"))
  writeLines("code", file.path(tmp_dir, "R", "setup.R"))

  theme <- theme_from_dir(tmp_dir)
  expect_equal(theme$steps[[1]]$dest, "R/setup.R")
})

test_that("theme_from_dir() includes dotfiles", {
  tmp_dir <- withr::local_tempdir()
  writeLines("*.Rproj.user", file.path(tmp_dir, ".gitignore"))

  theme <- theme_from_dir(tmp_dir)
  expect_length(theme$steps, 1)
  expect_equal(theme$steps[[1]]$dest, ".gitignore")
})

test_that("theme_from_dir() returns empty theme for empty directory", {
  tmp_dir <- withr::local_tempdir()

  theme <- theme_from_dir(tmp_dir)
  expect_s3_class(theme, "prefab_theme")
  expect_length(theme$steps, 0)
})

test_that("theme_from_dir() errors for non-existent path", {
  expect_error(theme_from_dir("/nonexistent/dir"), "does not exist")
})

test_that("theme_from_dir() uses specified default strategy", {
  tmp_dir <- withr::local_tempdir()
  writeLines("hello", file.path(tmp_dir, "a.txt"))

  theme <- theme_from_dir(tmp_dir, strategy = "skip")
  expect_equal(theme$steps[[1]]$strategy, "skip")
})

test_that("theme_from_dir() attaches provenance", {
  tmp_dir <- withr::local_tempdir()
  writeLines("hello", file.path(tmp_dir, "a.txt"))

  theme <- theme_from_dir(tmp_dir)
  prov <- theme$steps[[1]]$provenance
  expect_equal(prov$helper, "theme_from_dir")
  expect_equal(prov$relative_path, "a.txt")
})

test_that("theme_from_dir() excludes _prefab.yml", {
  tmp_dir <- withr::local_tempdir()
  writeLines("hello", file.path(tmp_dir, "a.txt"))
  writeLines("files:", file.path(tmp_dir, "_prefab.yml"))

  theme <- theme_from_dir(tmp_dir)
  dests <- vapply(theme$steps, `[[`, character(1), "dest")
  expect_false("_prefab.yml" %in% dests)
})

test_that("theme_from_dir() default data is NULL", {
  tmp_dir <- withr::local_tempdir()
  writeLines("hello", file.path(tmp_dir, "a.txt"))

  theme <- theme_from_dir(tmp_dir)
  expect_null(theme$steps[[1]]$data)
})

# -- Phase 2: sidecar support -------------------------------------------------

test_that("sidecar overrides strategy per file", {
  skip_if_not_installed("yaml")
  tmp_dir <- withr::local_tempdir()
  writeLines("hello", file.path(tmp_dir, "a.txt"))
  writeLines("world", file.path(tmp_dir, "b.txt"))
  writeLines(
    c("files:", "  a.txt:", "    strategy: skip"),
    file.path(tmp_dir, "_prefab.yml")
  )

  theme <- theme_from_dir(tmp_dir)
  steps <- theme$steps
  a_step <- steps[[which(vapply(steps, `[[`, character(1), "dest") == "a.txt")]]
  b_step <- steps[[which(vapply(steps, `[[`, character(1), "dest") == "b.txt")]]
  expect_equal(a_step$strategy, "skip")
  expect_equal(b_step$strategy, "overwrite")
})

test_that("sidecar glob defaults apply", {
  skip_if_not_installed("yaml")
  tmp_dir <- withr::local_tempdir()
  writeLines("# Title", file.path(tmp_dir, "README.md"))
  writeLines("code", file.path(tmp_dir, "main.R"))
  writeLines(
    c("defaults:", "  '*.md':", "    strategy: skip"),
    file.path(tmp_dir, "_prefab.yml")
  )

  theme <- theme_from_dir(tmp_dir)
  steps <- theme$steps
  md_step <- steps[[which(
    vapply(steps, `[[`, character(1), "dest") == "README.md"
  )]]
  r_step <- steps[[which(
    vapply(steps, `[[`, character(1), "dest") == "main.R"
  )]]
  expect_equal(md_step$strategy, "skip")
  expect_equal(r_step$strategy, "overwrite")
})

test_that("sidecar exact match takes precedence over glob", {
  skip_if_not_installed("yaml")
  tmp_dir <- withr::local_tempdir()
  writeLines("# Title", file.path(tmp_dir, "README.md"))
  writeLines(
    c(
      "files:",
      "  README.md:",
      "    strategy: union",
      "defaults:",
      "  '*.md':",
      "    strategy: skip"
    ),
    file.path(tmp_dir, "_prefab.yml")
  )

  theme <- theme_from_dir(tmp_dir)
  expect_equal(theme$steps[[1]]$strategy, "union")
})

test_that("sidecar data: auto enables templating", {
  skip_if_not_installed("yaml")
  tmp_dir <- withr::local_tempdir()
  writeLines("# {{project_dir}}", file.path(tmp_dir, "README.md"))
  writeLines(
    c("files:", "  README.md:", "    data: auto"),
    file.path(tmp_dir, "_prefab.yml")
  )

  theme <- theme_from_dir(tmp_dir)
  expect_equal(theme$steps[[1]]$data, "auto")
})

test_that("sidecar data map sets template variables", {
  skip_if_not_installed("yaml")
  tmp_dir <- withr::local_tempdir()
  writeLines("hello", file.path(tmp_dir, "a.txt"))
  writeLines(
    c("files:", "  a.txt:", "    data:", "      name: test"),
    file.path(tmp_dir, "_prefab.yml")
  )

  theme <- theme_from_dir(tmp_dir)
  expect_equal(theme$steps[[1]]$data, list(name = "test"))
})

test_that("parse_sidecar parses valid sidecar", {
  skip_if_not_installed("yaml")
  tmp <- withr::local_tempfile(fileext = ".yml")
  writeLines(c("files:", "  a.txt:", "    strategy: skip"), tmp)

  result <- parse_sidecar(tmp)
  expect_equal(result$files$a.txt$strategy, "skip")
  expect_equal(result$defaults, list())
})

# -- glob matching -------------------------------------------------------------

test_that("glob_match handles basic patterns", {
  expect_true(glob_match("README.md", "*.md"))
  expect_false(glob_match("README.md", "*.R"))
  expect_true(glob_match("R/setup.R", "R/*.R"))
  expect_false(glob_match("R/setup.R", "*.R"))
})

test_that("glob_match handles ** globstar", {
  expect_true(glob_match("R/setup.R", "**/*.R"))
  expect_true(glob_match("a/b/c.txt", "**/*.txt"))
})
