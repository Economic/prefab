# test-create-project.R -- tests for create_project()

test_that("creates directory and applies theme", {
  tmp <- withr::local_tempdir()
  project_path <- file.path(tmp, "newproject")

  theme <- new_theme(step_text(c("hello"), "out.txt"))
  create_project(project_path, theme)

  expect_true(fs::dir_exists(project_path))
  expect_equal(readLines(file.path(project_path, "out.txt")), "hello")
})

test_that("errors on non-theme input", {
  tmp <- withr::local_tempdir()
  path <- file.path(tmp, "project")
  expect_error(create_project(path, "not a theme"), "prefab_theme")
  expect_error(create_project(path, 42), "prefab_theme")
})

test_that("errors when path exists and contains files", {
  tmp <- withr::local_tempdir()
  project_path <- file.path(tmp, "existing")
  fs::dir_create(project_path)
  writeLines("content", file.path(project_path, "file.txt"))

  theme <- new_theme()
  expect_error(create_project(project_path, theme), "not empty")
})

test_that("errors when path exists with hidden files", {
  tmp <- withr::local_tempdir()
  project_path <- file.path(tmp, "existing")
  fs::dir_create(project_path)
  writeLines("content", file.path(project_path, ".hidden"))

  theme <- new_theme()
  expect_error(create_project(project_path, theme), "not empty")
})

test_that("works when path is existing empty directory", {
  tmp <- withr::local_tempdir()
  project_path <- file.path(tmp, "emptydir")
  fs::dir_create(project_path)

  theme <- new_theme(step_text(c("hello"), "out.txt"))
  expect_no_error(create_project(project_path, theme))
  expect_equal(readLines(file.path(project_path, "out.txt")), "hello")
})

test_that("theme executes against new dir, not cwd", {
  tmp <- withr::local_tempdir()
  withr::local_dir(tmp)
  project_path <- file.path(tmp, "target")

  theme <- new_theme(step_text(c("marker"), "marker.txt"))
  create_project(project_path, theme)

  expect_true(fs::file_exists(file.path(project_path, "marker.txt")))
  expect_false(fs::file_exists(file.path(tmp, "marker.txt")))
})

test_that("returns normalized path invisibly", {
  tmp <- withr::local_tempdir()
  project_path <- file.path(tmp, "project")

  theme <- new_theme()
  result <- create_project(project_path, theme)

  expect_invisible(create_project(file.path(tmp, "project2"), theme))
  expect_equal(result, fs::path_abs(project_path))
})
