#' Build auto-discovered template context
#'
#' Builds a named list of variables auto-discovered from the project state.
#' Called once at the start of theme execution.
#'
#' @param project_root Absolute path to the project root.
#' @return Named list with `package_name`, `project_dir`, `year`, `date`.
#' @noRd
build_auto_context <- function(project_root) {
  package_name <- tryCatch(
    {
      desc_path <- file.path(project_root, "DESCRIPTION")
      dcf <- read.dcf(desc_path, fields = "Package")
      pkg <- dcf[1, "Package"]
      if (is.na(pkg)) basename(project_root) else as.character(pkg)
    },
    warning = function(w) basename(project_root),
    error = function(e) basename(project_root)
  )

  list(
    package_name = package_name,
    project_dir = basename(project_root),
    year = format(Sys.Date(), "%Y"),
    date = format(Sys.Date(), "%Y-%m-%d")
  )
}

#' Render a template through glue
#'
#' Renders a character vector through `glue::glue_data()` with `{{var}}` syntax,
#' merging step-level data on top of auto-context.
#'
#' @param content Character vector (one element per line).
#' @param data Named list of explicit template variables.
#' @param auto_context Named list from `build_auto_context()`.
#' @return Rendered character vector (same length as input).
#' @noRd
render_template <- function(content, data, auto_context) {
  merged <- utils::modifyList(auto_context, data)
  vapply(content, function(line) {
    as.character(glue::glue_data(merged, line, .open = "{{", .close = "}}", .envir = emptyenv()))
  }, character(1), USE.NAMES = FALSE)
}
