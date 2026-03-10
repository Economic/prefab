#' Apply a theme to the current project
#'
#' Discovers the project root and executes the theme against it.
#'
#' @param theme A `prefab_theme` object created by [new_theme()] or a pre-set
#'   theme function.
#'
#' @return The project root path (invisibly).
#' @export
#'
#' @examples
#' \dontrun{
#' use_theme(r_analysis())
#' use_theme(r_analysis() + claude_r_analysis())
#' }
use_theme <- function(theme) {
  if (!inherits(theme, "prefab_theme")) {
    cli::cli_abort("{.arg theme} must be a {.cls prefab_theme}.")
  }

  project_root <- tryCatch(
    rprojroot::find_root(
      rprojroot::has_file(".here") |
        rprojroot::is_rstudio_project |
        rprojroot::is_r_package |
        rprojroot::is_git_root |
        rprojroot::is_vscode_project |
        rprojroot::is_quarto_project |
        rprojroot::is_renv_project |
        rprojroot::is_remake_project |
        rprojroot::is_projectile_project
    ),
    error = function(e) {
      cli::cli_warn("Could not find project root; using working directory.")
      getwd()
    }
  )

  execute_theme(theme, project_root)

  invisible(project_root)
}
