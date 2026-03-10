#' Create a file deployment step
#'
#' Creates a step that deploys a file or directory to the project.
#'
#' @param source Absolute path to the source file or directory. Typically
#'   produced by a source helper ([from_package()], [from_dir()]) rather than
#'   written by hand.
#' @param dest Path to the destination, relative to the project root.
#' @param strategy How to handle a pre-existing destination file. One of
#'   `"overwrite"`, `"skip"`, `"union"`, `"append"`, or `"merge_json"`.
#' @param data `NULL` (default) for static file copy, or a named list of
#'   variables to interpolate into the file via `{{var}}` syntax before
#'   deploying.
#'
#' @return A list with class `"prefab_step_file"`.
#' @export
step_file <- function(source, dest, strategy = "overwrite", data = NULL) {
  validate_strategy(strategy)

  if (!fs::is_absolute_path(source)) {
    cli::cli_abort("{.arg source} must be an absolute path, not {.path {source}}.")
  }

  if (fs::is_absolute_path(dest)) {
    cli::cli_abort("{.arg dest} must be a relative path, not {.path {dest}}.")
  }

  validate_data(data)

  structure(
    list(
      source = source,
      dest = dest,
      strategy = strategy,
      data = data,
      provenance = NULL
    ),
    class = c("prefab_step_file", "prefab_step")
  )
}

#' Create an inline text deployment step
#'
#' Creates a step that deploys inline text content to the project. Like
#' [step_file()] but takes a character vector instead of a source file path.
#'
#' @param content Character vector of lines to deploy (one element per line).
#'   `character(0)` is allowed except with `strategy = "merge_json"`.
#' @param dest Path to the destination, relative to the project root.
#' @param strategy How to handle a pre-existing destination file. One of
#'   `"overwrite"`, `"skip"`, `"union"`, `"append"`, or `"merge_json"`.
#'
#' @return A list with class `"prefab_step_text"`.
#' @export
step_text <- function(content, dest, strategy = "overwrite") {
  if (!is.character(content)) {
    cli::cli_abort("{.arg content} must be a character vector.")
  }

  validate_strategy(strategy)

  if (fs::is_absolute_path(dest)) {
    cli::cli_abort("{.arg dest} must be a relative path, not {.path {dest}}.")
  }

  if (strategy == "merge_json" && length(content) == 0L) {
    cli::cli_abort(
      "{.arg content} cannot be empty ({.code character(0)}) with {.val merge_json} strategy."
    )
  }

  structure(
    list(
      content = content,
      dest = dest,
      strategy = strategy
    ),
    class = c("prefab_step_text", "prefab_step")
  )
}

#' Create a function execution step
#'
#' Creates a step that executes an R function for its side effects.
#'
#' @param fn A function to execute.
#' @param ... Additional arguments passed to `fn` at execution time.
#' @param .label Optional label for display. When `NULL` (default), captured
#'   via `deparse(substitute(fn))`.
#'
#' @return A list with class `"prefab_step_run"`.
#' @export
step_run <- function(fn, ..., .label = NULL) {
  if (!is.function(fn)) {
    cli::cli_abort("{.arg fn} must be a function.")
  }

  if (is.null(.label)) {
    label <- deparse(substitute(fn))
  } else {
    if (!is.character(.label) || length(.label) != 1L) {
      cli::cli_abort("{.arg .label} must be a single string.")
    }
    label <- .label
  }

  structure(
    list(
      fn = fn,
      args = list(...),
      label = label
    ),
    class = c("prefab_step_run", "prefab_step")
  )
}


# -- internal helpers ----------------------------------------------------------

valid_strategies <- c("overwrite", "skip", "union", "append", "merge_json")

validate_strategy <- function(strategy) {
  if (!is.character(strategy) || length(strategy) != 1L ||
      !strategy %in% valid_strategies) {
    cli::cli_abort(
      "{.arg strategy} must be one of {.or {.val {valid_strategies}}}, not {.val {strategy}}."
    )
  }
  invisible(strategy)
}

validate_data <- function(data) {
  if (is.null(data)) {
    return(invisible(NULL))
  }
  if (!is.list(data)) {
    cli::cli_abort("{.arg data} must be {.code NULL} or a named list.")
  }
  if (length(data) == 0L) {
    return(invisible(data))
  }
  nms <- names(data)
  if (is.null(nms) || any(nms == "")) {
    cli::cli_abort("{.arg data} must be a fully named list (all elements must have names).")
  }
  invisible(data)
}
