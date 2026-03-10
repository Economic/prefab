#' Create a new project and apply a theme
#'
#' Creates a new project directory and applies a theme to it. If RStudio is
#' available, opens the new project in a new session.
#'
#' @param path Path for the new project directory. Resolved to an absolute path
#'   via [fs::path_abs()].
#' @param theme A `prefab_theme` object created by [new_theme()] or a pre-set
#'   theme function.
#'
#' @return The normalized project path (invisibly).
#' @export
#'
#' @examples
#' \dontrun{
#' create_project("~/projects/my-analysis", r_analysis())
#' create_project("my-targets-project", r_targets() + claude_r_targets())
#' }
create_project <- function(path, theme) {
  if (!inherits(theme, "prefab_theme")) {
    cli::cli_abort("{.arg theme} must be a {.cls prefab_theme}.")
  }

  path <- fs::path_abs(path)

  if (fs::dir_exists(path) && length(fs::dir_ls(path, all = TRUE)) > 0L) {
    cli::cli_abort("Directory {.path {path}} already exists and is not empty.")
  }

  fs::dir_create(path)
  execute_theme(theme, path)

  if (rlang::is_installed("rstudioapi") && rstudioapi::isAvailable()) {
    rstudioapi::openProject(path, newSession = TRUE)
  }

  invisible(path)
}
