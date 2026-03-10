# apply_strategy() -----------------------------------------------------------

test_that("overwrite creates file when dest does not exist", {
  tmp <- withr::local_tempdir()
  dest <- file.path(tmp, "out.txt")
  apply_strategy(c("hello", "world"), dest, "overwrite")
  expect_equal(readLines(dest), c("hello", "world"))
})

test_that("skip creates file when dest does not exist", {
  tmp <- withr::local_tempdir()
  dest <- file.path(tmp, "out.txt")
  apply_strategy(c("hello"), dest, "skip")
  expect_equal(readLines(dest), "hello")
})

test_that("append creates file when dest does not exist", {
  tmp <- withr::local_tempdir()
  dest <- file.path(tmp, "out.txt")
  apply_strategy(c("hello"), dest, "append")
  expect_equal(readLines(dest), "hello")
})

test_that("union creates file when dest does not exist", {
  tmp <- withr::local_tempdir()
  dest <- file.path(tmp, "out.txt")
  apply_strategy(c("a", "b"), dest, "union")
  expect_equal(readLines(dest), c("a", "b"))
})

test_that("merge_json creates file when dest does not exist", {
  tmp <- withr::local_tempdir()
  dest <- file.path(tmp, "out.json")
  apply_strategy('{"key": "value"}', dest, "merge_json")
  result <- jsonlite::fromJSON(dest, simplifyVector = FALSE)
  expect_equal(result$key, "value")
})

test_that("overwrite replaces existing content", {
  tmp <- withr::local_tempdir()
  dest <- file.path(tmp, "out.txt")
  writeLines("old", dest)
  apply_strategy(c("new"), dest, "overwrite")
  expect_equal(readLines(dest), "new")
})

test_that("skip leaves existing content unchanged", {
  tmp <- withr::local_tempdir()
  dest <- file.path(tmp, "out.txt")
  writeLines("original", dest)
  apply_strategy(c("replacement"), dest, "skip")
  expect_equal(readLines(dest), "original")
})

test_that("append adds to end of existing content", {
  tmp <- withr::local_tempdir()
  dest <- file.path(tmp, "out.txt")
  writeLines(c("line1", "line2"), dest)
  apply_strategy(c("line3"), dest, "append")
  expect_equal(readLines(dest), c("line1", "line2", "line3"))
})

test_that("union adds only new lines", {
  tmp <- withr::local_tempdir()
  dest <- file.path(tmp, "out.txt")
  writeLines(c("a", "b"), dest)
  apply_strategy(c("b", "c"), dest, "union")
  expect_equal(readLines(dest), c("a", "b", "c"))
})

test_that("union is idempotent on re-run", {
  tmp <- withr::local_tempdir()
  dest <- file.path(tmp, "out.txt")
  apply_strategy(c("a", "b"), dest, "union")
  apply_strategy(c("a", "b"), dest, "union")
  expect_equal(readLines(dest), c("a", "b"))
})

test_that("merge_json union-merges permission arrays and is idempotent", {
  tmp <- withr::local_tempdir()
  dest <- file.path(tmp, "out.json")

  source1 <- '{"permissions": {"allow": ["Bash(ls:*)", "Bash(cat:*)"]}}'
  apply_strategy(source1, dest, "merge_json")

  source2 <- '{"permissions": {"allow": ["Bash(cat:*)", "Bash(grep:*)"]}}'
  apply_strategy(source2, dest, "merge_json")

  result <- jsonlite::fromJSON(dest, simplifyVector = FALSE)
  expect_equal(
    result$permissions$allow,
    list("Bash(ls:*)", "Bash(cat:*)", "Bash(grep:*)")
  )

  # Idempotent on re-run
  apply_strategy(source2, dest, "merge_json")
  result2 <- jsonlite::fromJSON(dest, simplifyVector = FALSE)
  expect_equal(result2$permissions$allow, result$permissions$allow)
})

test_that("apply_strategy creates parent directories", {
  tmp <- withr::local_tempdir()
  dest <- file.path(tmp, "sub", "dir", "out.txt")
  apply_strategy(c("hello"), dest, "overwrite")
  expect_equal(readLines(dest), "hello")
})

test_that("apply_strategy errors on invalid strategy", {
  tmp <- withr::local_tempdir()
  dest <- file.path(tmp, "out.txt")
  expect_error(apply_strategy(c("hello"), dest, "invalid"), "Unknown strategy")
})

# deploy_file() --------------------------------------------------------------

test_that("deploy_file errors when source does not exist", {
  tmp <- withr::local_tempdir()
  expect_error(
    deploy_file("/nonexistent/file.txt", "out.txt", "overwrite", NULL, list(), tmp),
    "does not exist"
  )
})

test_that("deploy_file errors when source is dir and data is non-NULL", {
  tmp <- withr::local_tempdir()
  src_dir <- file.path(tmp, "src")
  fs::dir_create(src_dir)
  writeLines("content", file.path(src_dir, "file.txt"))

  project <- file.path(tmp, "project")
  fs::dir_create(project)

  expect_error(
    deploy_file(src_dir, "dest", "overwrite", list(x = 1), list(), project),
    "not supported for directory"
  )
})

test_that("deploy_file errors when source is dir and dest exists as file", {
  tmp <- withr::local_tempdir()
  src_dir <- file.path(tmp, "src")
  fs::dir_create(src_dir)
  writeLines("content", file.path(src_dir, "file.txt"))

  project <- file.path(tmp, "project")
  fs::dir_create(project)
  writeLines("existing", file.path(project, "dest"))

  expect_error(
    deploy_file(src_dir, "dest", "overwrite", NULL, list(), project),
    "exists as a file"
  )
})

test_that("deploy_file errors when source is file and dest exists as dir", {
  tmp <- withr::local_tempdir()
  src_file <- file.path(tmp, "source.txt")
  writeLines("content", src_file)

  project <- file.path(tmp, "project")
  fs::dir_create(file.path(project, "dest"))

  expect_error(
    deploy_file(src_file, "dest", "overwrite", NULL, list(), project),
    "exists as a directory"
  )
})

test_that("deploy_file with data = list() renders auto-context variables", {
  tmp <- withr::local_tempdir()

  # Create a project with DESCRIPTION
  project <- file.path(tmp, "myproject")
  fs::dir_create(project)
  writeLines("Package: mypkg", file.path(project, "DESCRIPTION"))

  # Create a source template
  src_file <- file.path(tmp, "template.txt")
  writeLines("# {{package_name}}", src_file)

  auto_ctx <- build_auto_context(project)

  deploy_file(src_file, "out.txt", "overwrite", list(), auto_ctx, project)
  result <- readLines(file.path(project, "out.txt"))
  expect_equal(result, "# mypkg")
})

test_that("deploy_file with data = NULL copies verbatim", {
  tmp <- withr::local_tempdir()
  project <- file.path(tmp, "project")
  fs::dir_create(project)

  src_file <- file.path(tmp, "source.txt")
  writeLines("{{not_rendered}}", src_file)

  deploy_file(src_file, "out.txt", "overwrite", NULL, list(), project)
  result <- readLines(file.path(project, "out.txt"))
  expect_equal(result, "{{not_rendered}}")
})

# deploy_text() ---------------------------------------------------------------

test_that("deploy_text deploys inline content", {
  tmp <- withr::local_tempdir()
  project <- file.path(tmp, "project")
  fs::dir_create(project)

  deploy_text(c("line1", "line2"), "out.txt", "overwrite", project)
  result <- readLines(file.path(project, "out.txt"))
  expect_equal(result, c("line1", "line2"))
})

test_that("deploy_text with union adds only new lines", {
  tmp <- withr::local_tempdir()
  project <- file.path(tmp, "project")
  fs::dir_create(project)

  deploy_text(c("a", "b"), "out.txt", "union", project)
  deploy_text(c("b", "c"), "out.txt", "union", project)
  result <- readLines(file.path(project, "out.txt"))
  expect_equal(result, c("a", "b", "c"))
})

# Directory deployment --------------------------------------------------------

test_that("directory source deploys all files recursively", {
  tmp <- withr::local_tempdir()

  # Create source directory structure
  src_dir <- file.path(tmp, "src")
  fs::dir_create(file.path(src_dir, "sub"))
  writeLines("root file", file.path(src_dir, "root.txt"))
  writeLines("nested file", file.path(src_dir, "sub", "nested.txt"))

  project <- file.path(tmp, "project")
  fs::dir_create(project)

  deploy_file(src_dir, "dest", "overwrite", NULL, list(), project)

  expect_equal(readLines(file.path(project, "dest", "root.txt")), "root file")
  expect_equal(readLines(file.path(project, "dest", "sub", "nested.txt")), "nested file")
})

test_that("directory deployment leaves pre-existing files untouched", {
  tmp <- withr::local_tempdir()

  # Create source directory with one file
  src_dir <- file.path(tmp, "src")
  fs::dir_create(src_dir)
  writeLines("new file", file.path(src_dir, "new.txt"))

  # Create project with a pre-existing file in dest
  project <- file.path(tmp, "project")
  fs::dir_create(file.path(project, "dest"))
  writeLines("existing", file.path(project, "dest", "existing.txt"))

  deploy_file(src_dir, "dest", "overwrite", NULL, list(), project)

  # Pre-existing file should be untouched

  expect_equal(readLines(file.path(project, "dest", "existing.txt")), "existing")
  # New file should be deployed
  expect_equal(readLines(file.path(project, "dest", "new.txt")), "new file")
})
