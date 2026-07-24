#' Create a new project and apply a theme
#'
#' Creates a new project directory and applies a theme to it.
#'
#' @param path Path for the new project directory. Resolved to an absolute path
#'   via [fs::path_abs()].
#' @param theme A `prefab_theme` object created by [new_theme()] or a pre-set
#'   theme function.
#' @param open Whether to activate the new project after creating it, following
#'   the convention of [usethis::create_project()] and
#'   [usethis::create_package()]: when `TRUE`, the project opens in a new
#'   session/window in RStudio/Positron, or in other editors the working
#'   directory of the active session is changed into the new project. Defaults
#'   to [rlang::is_interactive()], so it opens interactively but stays inert in
#'   scripts, tests, and non-interactive callers.
#'
#' @return The normalized project path (invisibly).
#' @export
#'
#' @examples
#' \dontrun{
#' create_project("~/projects/my-analysis", r_analysis())
#' create_project("my-targets-project", r_targets() + claude_r_targets())
#' }
create_project <- function(path, theme, open = rlang::is_interactive()) {
  if (!inherits(theme, "prefab_theme")) {
    cli::cli_abort("{.arg theme} must be a {.cls prefab_theme}.")
  }

  path <- fs::path_abs(path)

  if (fs::dir_exists(path) && length(fs::dir_ls(path, all = TRUE)) > 0L) {
    cli::cli_abort("Directory {.path {path}} already exists and is not empty.")
  }

  fs::dir_create(path)
  execute_theme(theme, path)

  if (open) {
    activate_project(path)
  }

  invisible(path)
}

# Activate a project directory, following the pattern used by
# usethis::proj_activate() (r-lib/usethis, R/proj.R). We deliberately mirror
# usethis here: the guard is `isAvailable() && hasFun("openProject")`, not just
# `isAvailable()`. Some front-ends (notably VS Code via the vscode-R shim) make
# `isAvailable()` return TRUE but do NOT implement `openProject`, so gating on
# `isAvailable()` alone would call an unsupported function and error out. When
# a new session/window cannot be opened, we fall back to changing the working
# directory into the project in the current session (again as usethis does).
activate_project <- function(path) {
  can_open <- rlang::is_installed("rstudioapi") &&
    rstudioapi::isAvailable() &&
    rstudioapi::hasFun("openProject")

  if (can_open) {
    cli::cli_alert_success("Opening {.path {path}} in a new session.")
    rstudioapi::openProject(path, newSession = TRUE)
  } else {
    cli::cli_alert_success("Changing working directory to {.path {path}}.")
    setwd(path)
  }

  invisible(path)
}
