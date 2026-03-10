# build_auto_context() --------------------------------------------------------

test_that("build_auto_context discovers package_name from DESCRIPTION", {
  tmp <- withr::local_tempdir()
  writeLines("Package: mypkg\nTitle: Test", file.path(tmp, "DESCRIPTION"))
  ctx <- build_auto_context(tmp)
  expect_equal(ctx$package_name, "mypkg")
})

test_that("build_auto_context falls back to dir name when no DESCRIPTION", {
  tmp <- withr::local_tempdir()
  ctx <- build_auto_context(tmp)
  expect_equal(ctx$package_name, basename(tmp))
})

test_that("build_auto_context always provides project_dir, year, date", {
  tmp <- withr::local_tempdir()
  ctx <- build_auto_context(tmp)
  expect_equal(ctx$project_dir, basename(tmp))
  expect_equal(ctx$year, format(Sys.Date(), "%Y"))
  expect_equal(ctx$date, format(Sys.Date(), "%Y-%m-%d"))
})

# render_template() -----------------------------------------------------------

test_that("render_template substitutes {{var}} with values", {
  auto_ctx <- list(package_name = "mypkg", project_dir = "mydir", year = "2026", date = "2026-03-09")
  result <- render_template(
    c("# {{title}}", "by {{author}}"),
    data = list(title = "Hello", author = "Alice"),
    auto_context = auto_ctx
  )
  expect_equal(result, c("# Hello", "by Alice"))
})

test_that("render_template auto-context defaults, explicit data overrides", {
  auto_ctx <- list(package_name = "auto_pkg", project_dir = "mydir", year = "2026", date = "2026-03-09")
  result <- render_template(
    c("{{package_name}}"),
    data = list(package_name = "explicit_pkg"),
    auto_context = auto_ctx
  )
  expect_equal(result, "explicit_pkg")

  # Auto-context provides default
  result2 <- render_template(
    c("{{package_name}}"),
    data = list(),
    auto_context = auto_ctx
  )
  expect_equal(result2, "auto_pkg")
})

test_that("render_template errors on unresolved {{var}}", {
  auto_ctx <- list(package_name = "pkg", project_dir = "dir", year = "2026", date = "2026-03-09")
  expect_error(
    render_template(c("{{undefined_var}}"), data = list(), auto_context = auto_ctx)
  )
})

test_that("render_template leaves {single_braces} untouched", {
  auto_ctx <- list(package_name = "pkg", project_dir = "dir", year = "2026", date = "2026-03-09")
  result <- render_template(
    c("{not_a_template}", "normal text"),
    data = list(),
    auto_context = auto_ctx
  )
  expect_equal(result, c("{not_a_template}", "normal text"))
})
