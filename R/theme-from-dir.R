#' Create a theme from a directory of template files
#'
#' Converts a directory tree into a theme where each file becomes a
#' [step_file()]. An optional `_prefab.yml` sidecar file in the directory
#' can override the strategy and template data per file.
#'
#' @param path Path to a directory of template files. Resolved to an absolute
#'   path via [fs::path_abs()]. Must exist.
#' @param strategy Default merge strategy for all files. Can be overridden
#'   per file via a `_prefab.yml` sidecar. One of `"overwrite"`, `"skip"`,
#'   `"union"`, `"append"`, or `"merge_json"`.
#'
#' @return A `prefab_theme` object.
#' @export
#'
#' @examples
#' \dontrun{
#' # Create a theme from a directory of config files
#' use_theme(theme_from_dir("~/my-template"))
#'
#' # Compose with other themes
#' use_theme(r_analysis() + theme_from_dir("~/my-extras"))
#' }
theme_from_dir <- function(path, strategy = "skip") {
  validate_strategy(strategy)
  abs_path <- fs::path_abs(path)

  if (!fs::dir_exists(abs_path)) {
    cli::cli_abort("Directory {.path {path}} does not exist.")
  }

  all_files <- fs::dir_ls(
    abs_path,
    type = "file",
    recurse = TRUE,
    all = TRUE
  )

  # Exclude sidecar
  sidecar_path <- fs::path(abs_path, "_prefab.yml")
  all_files <- all_files[all_files != sidecar_path]

  if (length(all_files) == 0L && !fs::file_exists(sidecar_path)) {
    return(do.call(new_theme, list()))
  }

  # Parse sidecar if present
  sidecar <- NULL
  if (fs::file_exists(sidecar_path)) {
    sidecar <- parse_sidecar(sidecar_path)
  }

  # Find empty directories (no files anywhere beneath them)
  all_dirs <- fs::dir_ls(abs_path, type = "directory", recurse = TRUE)
  empty_dirs <- vapply(
    all_dirs,
    function(d) {
      length(fs::dir_ls(d, type = "file", recurse = TRUE, all = TRUE)) == 0L
    },
    logical(1)
  )
  empty_dirs <- all_dirs[empty_dirs]

  dir_steps <- lapply(empty_dirs, function(d) {
    rel <- as.character(fs::path_rel(d, abs_path))
    step_run(
      fs::dir_create,
      rel,
      .label = paste0("fs::dir_create('", rel, "')")
    )
  })

  steps <- lapply(all_files, function(src) {
    rel <- as.character(fs::path_rel(src, abs_path))
    file_config <- resolve_sidecar(rel, sidecar, strategy)

    step <- step_file(
      source = as.character(src),
      dest = rel,
      strategy = file_config$strategy,
      data = file_config$data
    )
    step$provenance <- list(
      helper = "theme_from_dir",
      path = as.character(path),
      relative_path = rel
    )
    step
  })

  do.call(new_theme, c(dir_steps, steps))
}


# -- sidecar parsing ----------------------------------------------------------

#' Parse a _prefab.yml sidecar file
#' @param path Absolute path to the sidecar file.
#' @return Parsed list with `files` and `defaults` elements (both possibly NULL).
#' @noRd
parse_sidecar <- function(path) {
  rlang::check_installed("yaml", reason = "to read _prefab.yml sidecar files")
  raw <- yaml::read_yaml(path)

  list(
    files = raw$files %||% list(),
    defaults = raw$defaults %||% list()
  )
}

#' Resolve sidecar config for a single file
#' @param rel_path Relative path of the file within the template directory.
#' @param sidecar Parsed sidecar (or NULL).
#' @param default_strategy Default strategy from theme_from_dir().
#' @return List with `strategy` and `data` elements.
#' @noRd
resolve_sidecar <- function(rel_path, sidecar, default_strategy) {
  result <- list(strategy = default_strategy, data = NULL)

  if (is.null(sidecar)) {
    return(result)
  }

  # Check exact match in files:
  file_config <- sidecar$files[[rel_path]]
  if (!is.null(file_config)) {
    return(apply_sidecar_config(file_config, result))
  }

  # Check glob defaults
  for (pattern in names(sidecar$defaults)) {
    if (glob_match(rel_path, pattern)) {
      return(apply_sidecar_config(sidecar$defaults[[pattern]], result))
    }
  }

  result
}

#' Apply sidecar config overrides
#' @noRd
apply_sidecar_config <- function(config, defaults) {
  result <- defaults
  if (!is.null(config$strategy)) {
    validate_strategy(config$strategy)
    result$strategy <- config$strategy
  }
  if (!is.null(config$data)) {
    if (identical(config$data, "auto")) {
      result$data <- "auto"
    } else if (is.list(config$data)) {
      result$data <- config$data
    } else {
      cli::cli_abort(
        '{.field data} in {.path _prefab.yml} must be {.val auto} or a named map.'
      )
    }
  }
  result
}

#' Simple glob matching
#' @param path File path to test.
#' @param pattern Glob pattern (e.g., "*.md", "R/*.R").
#' @return Logical.
#' @noRd
glob_match <- function(path, pattern) {
  # Convert glob to regex
  regex <- glob_to_regex(pattern)
  grepl(regex, path)
}

#' Convert a glob pattern to a regex
#' @noRd
glob_to_regex <- function(pattern) {
  # Escape regex special chars except * and ?
  regex <- gsub("([.+^${}()|\\[\\]\\\\])", "\\\\\\1", pattern)
  # ** matches any path
  regex <- gsub("\\*\\*", ".__GLOBSTAR__", regex)
  # * matches anything except /
  regex <- gsub("\\*", "[^/]*", regex)
  # ** restored to match any path
  regex <- gsub("\\.__GLOBSTAR__", ".*", regex)
  # ? matches single non-/ char
  regex <- gsub("\\?", "[^/]", regex)
  paste0("^", regex, "$")
}
