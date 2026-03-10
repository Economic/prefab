#' Create a step-builder from an installed package
#'
#' Returns a step-builder function that resolves source paths relative to a
#' package's `inst/` directory. Works with both installed packages and during
#' development with [devtools::load_all()].
#'
#' @param package Package name (string).
#'
#' @return A function with signature
#'   `function(source, dest, strategy = "overwrite", data = NULL)` that returns
#'   a [step_file()] object.
#' @export
from_package <- function(package) {
  if (!is.character(package) || length(package) != 1L) {
    cli::cli_abort("{.arg package} must be a single string.")
  }

  function(source, dest, strategy = "overwrite", data = NULL) {
    resolved <- tryCatch(
      fs::path_package(package, source),
      error = function(e) {
        cli::cli_abort(
          "Source {.path {source}} not found in package {.pkg {package}}.",
          parent = e
        )
      }
    )

    if (!fs::file_exists(resolved) && !fs::dir_exists(resolved)) {
      cli::cli_abort(
        "Source {.path {source}} not found in package {.pkg {package}} (resolved to {.path {resolved}})."
      )
    }

    step <- step_file(resolved, dest, strategy = strategy, data = data)
    step$provenance <- list(
      helper = "from_package",
      package = package,
      relative_path = source
    )
    step
  }
}

#' Create a step-builder from a local directory
#'
#' Returns a step-builder function that resolves source paths relative to a
#' local directory. The directory path is resolved to an absolute path at
#' creation time.
#'
#' @param path Path to the directory. Resolved to absolute via [fs::path_abs()]
#'   at creation time. Must exist.
#'
#' @return A function with signature
#'   `function(source, dest, strategy = "overwrite", data = NULL)` that returns
#'   a [step_file()] object.
#' @export
from_dir <- function(path) {
  raw_path <- path
  abs_path <- fs::path_abs(path)

  if (!fs::dir_exists(abs_path)) {
    cli::cli_abort("Directory {.path {path}} does not exist.")
  }

  function(source, dest, strategy = "overwrite", data = NULL) {
    resolved <- fs::path(abs_path, source)

    if (!fs::file_exists(resolved) && !fs::dir_exists(resolved)) {
      cli::cli_abort(
        "Source {.path {source}} not found in directory {.path {raw_path}} (resolved to {.path {resolved}})."
      )
    }

    step <- step_file(resolved, dest, strategy = strategy, data = data)
    step$provenance <- list(
      helper = "from_dir",
      path = raw_path,
      relative_path = source
    )
    step
  }
}
