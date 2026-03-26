# Internal gitignore lines shared by project themes
gitignore_lines <- c(".Rproj.user", ".Rhistory", ".RData", ".DS_Store")

#' R analysis project theme
#'
#' Creates a theme that scaffolds a simple R analysis project with `main.R`,
#' `README.md`, and `.gitignore`.
#'
#' @param data_dirs Logical. If `TRUE` (default), creates directories
#'   `./data_raw` and `./data_processed`.
#' @return A `prefab_theme` object.
#' @export
#'
#' @examples
#' r_analysis()
r_analysis <- function(data_dirs = TRUE) {
  from_prefab <- from_package("prefab")
  step_data_raw <- if (data_dirs) {
    step_run(
      fs::dir_create,
      "data_raw",
      .label = "fs::dir_create('data_raw')"
    )
  }
  step_data_processed <- if (data_dirs) {
    step_run(
      fs::dir_create,
      "data_processed",
      .label = "fs::dir_create('data_processed')"
    )
  }
  step_main <- from_prefab(
    "r_analysis/main.R",
    "main.R",
    strategy = "skip",
    data = "auto"
  )
  step_readme <- from_prefab(
    "r_analysis/README.md",
    "README.md",
    strategy = "skip",
    data = "auto"
  )
  step_gitignore <- step_text(gitignore_lines, ".gitignore", strategy = "union")

  new_theme(
    step_data_raw,
    step_data_processed,
    step_main,
    step_readme,
    step_gitignore
  )
}

#' R targets project theme
#'
#' Creates a theme that scaffolds an R targets project with `_targets.R`,
#' `packages.R`, `README.md`, and `.gitignore`.
#'
#' @return A `prefab_theme` object.
#' @export
#'
#' @examples
#' r_targets()
r_targets <- function() {
  from_prefab <- from_package("prefab")
  new_theme(
    from_prefab("r_targets/_targets.R", "_targets.R", strategy = "skip"),
    from_prefab("r_targets/packages.R", "packages.R", strategy = "skip"),
    from_prefab(
      "r_targets/README.md",
      "README.md",
      strategy = "skip",
      data = "auto"
    ),
    step_text(gitignore_lines, ".gitignore", strategy = "union"),
    step_run(fs::dir_create, "R", .label = "fs::dir_create('R')")
  )
}
