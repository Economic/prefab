#' Load custom theme definitions
#'
#' Sources an R file containing custom theme functions into the global
#' environment, making them available for use with [use_theme()] and
#' [create_project()].
#'
#' The file is resolved in order: the explicit `file` argument, then the
#' `PREFAB_THEMES` environment variable, then `~/.prefab-themes.R`.
#'
#' @param file Path to an R file defining theme functions. If `NULL`, falls
#'   back to the `PREFAB_THEMES` environment variable, then
#'   `~/.prefab-themes.R`.
#'
#' @return The file path that was sourced (invisibly), or `NULL` invisibly if
#'   no file was found.
#' @export
#'
#' @examples
#' \dontrun{
#' # Source from default locations
#' load_themes()
#'
#' # Source from a specific file
#' load_themes("~/my-org-themes.R")
#' }
load_themes <- function(file = NULL) {
  file <- file %||%
    {
      env_val <- Sys.getenv("PREFAB_THEMES", unset = "")
      if (nzchar(env_val)) env_val else NULL
    }
  file <- file %||% path.expand("~/.prefab-themes.R")

  if (!file.exists(file)) {
    cli::cli_inform("No themes file found at {.path {file}}.")
    return(invisible(NULL))
  }

  source(file, local = globalenv())
  cli::cli_inform("Loaded themes from {.path {file}}.")
  invisible(file)
}
