# Internal gitignore lines shared by project themes
gitignore_lines <- c(".Rproj.user", ".Rhistory", ".RData", ".DS_Store")

#' R analysis project theme
#'
#' Creates a theme that scaffolds a simple R analysis project with `main.R`,
#' `README.md`, and `.gitignore`.
#'
#' @return A `prefab_theme` object.
#' @export
#'
#' @examples
#' r_analysis()
r_analysis <- function() {
  from_prefab <- from_package("prefab")
  new_theme(
    from_prefab("r_analysis/main.R", "main.R", strategy = "skip"),
    from_prefab("r_analysis/README.md", "README.md", strategy = "skip", data = list()),
    step_text(gitignore_lines, ".gitignore", strategy = "union")
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
    from_prefab("r_targets/README.md", "README.md", strategy = "skip", data = list()),
    step_text(gitignore_lines, ".gitignore", strategy = "union"),
    step_run(fs::dir_create, "R", .label = "fs::dir_create")
  )
}
