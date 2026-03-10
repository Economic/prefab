#' Create a theme from steps
#'
#' Constructs a theme from step objects. `NULL` arguments are silently dropped,
#' enabling conditional steps via `if (cond) step(...)`.
#'
#' @param ... Step objects ([step_file()], [step_text()], [step_run()]).
#'
#' @return A list with class `"prefab_theme"` containing a `steps` element.
#' @export
new_theme <- function(...) {
  args <- list(...)
  # Drop NULLs

  args <- args[!vapply(args, is.null, logical(1))]

  # Validate remaining args are step objects

  for (i in seq_along(args)) {
    if (!inherits(args[[i]], c("prefab_step_file", "prefab_step_text", "prefab_step_run"))) {
      cli::cli_abort(
        "Argument {i} to {.fn new_theme} must be a step object ({.cls prefab_step_file}, {.cls prefab_step_text}, or {.cls prefab_step_run})."
      )
    }
  }

  structure(
    list(steps = args),
    class = "prefab_theme"
  )
}

#' @export
`+.prefab_theme` <- function(e1, e2) {
  # Handle step + theme (dispatched here because e2 is prefab_theme)
  if (inherits(e1, "prefab_step")) {
    cli::cli_abort(
      c(
        "Can't add a step directly to a theme with {.code +}.",
        "i" = "Wrap steps in {.fn new_theme} first: {.code new_theme(your_step) + your_theme}"
      )
    )
  }

  if (inherits(e2, "prefab_step")) {
    cli::cli_abort(
      c(
        "Can't add a step directly to a theme with {.code +}.",
        "i" = "Wrap steps in {.fn new_theme} first: {.code your_theme + new_theme(your_step)}"
      )
    )
  }

  if (!inherits(e2, "prefab_theme")) {
    cli::cli_abort("Can only add a {.cls prefab_theme} to a {.cls prefab_theme}.")
  }

  new_steps <- c(e1$steps, e2$steps)
  structure(
    list(steps = new_steps),
    class = "prefab_theme"
  )
}

#' @export
print.prefab_theme <- function(x, ...) {
  n <- length(x$steps)
  cli::cli_rule(left = "Theme ({n} step{?s})")

  for (step in x$steps) {
    if (inherits(step, "prefab_step_file")) {
      cli::cli_text("
        {.field file}
        {.path {step$dest}}
        {.emph {step$strategy}}")
    } else if (inherits(step, "prefab_step_text")) {
      cli::cli_text("
        {.field text}
        {.path {step$dest}}
        {.emph {step$strategy}}")
    } else if (inherits(step, "prefab_step_run")) {
      cli::cli_text("
        {.field run}
        {step$label}()")
    }
  }

  invisible(x)
}

#' Print R code that reproduces a theme
#'
#' Prints the R code that would reproduce the given theme via [cat()], and
#' returns the code invisibly as a single character string.
#'
#' @param theme A `prefab_theme` object.
#'
#' @return The generated R code as a single character string (invisibly).
#' @export
theme_code <- function(theme) {
  if (!inherits(theme, "prefab_theme")) {
    cli::cli_abort("{.arg theme} must be a {.cls prefab_theme}.")
  }

  steps <- theme$steps

  if (length(steps) == 0L) {
    code <- "new_theme()"
    cat(code, "\n")
    return(invisible(code))
  }

  step_codes <- vapply(steps, format_step_code, character(1))

  code <- paste0(
    "new_theme(\n",
    paste0("
  ", step_codes, collapse = ",\n"),
    "\n)"
  )

  cat(code, "\n")
  invisible(code)
}

# -- internal helpers ----------------------------------------------------------

format_step_code <- function(step) {
  if (inherits(step, "prefab_step_file")) {
    format_step_file_code(step)
  } else if (inherits(step, "prefab_step_text")) {
    format_step_text_code(step)
  } else if (inherits(step, "prefab_step_run")) {
    format_step_run_code(step)
  }
}

format_step_file_code <- function(step) {
  prov <- step$provenance

  if (!is.null(prov)) {
    # Reconstruct source helper call
    if (prov$helper == "from_package") {
      source_expr <- paste0(
        'from_package("', prov$package, '")("', prov$relative_path, '"'
      )
    } else if (prov$helper == "from_dir") {
      source_expr <- paste0(
        'from_dir("', prov$path, '")("', prov$relative_path, '"'
      )
    }

    parts <- paste0(source_expr, ', "', step$dest, '"')

    if (step$strategy != "overwrite") {
      parts <- paste0(parts, ', strategy = "', step$strategy, '"')
    }

    if (!is.null(step$data)) {
      parts <- paste0(parts, ", data = ", deparse_compact(step$data))
    }

    paste0(parts, ")")
  } else {
    # Fall back to step_file()
    parts <- paste0('step_file("', step$source, '", "', step$dest, '"')

    if (step$strategy != "overwrite") {
      parts <- paste0(parts, ', strategy = "', step$strategy, '"')
    }

    if (!is.null(step$data)) {
      parts <- paste0(parts, ", data = ", deparse_compact(step$data))
    }

    paste0(parts, ")")
  }
}

format_step_text_code <- function(step) {
  content_code <- if (length(step$content) == 0L) {
    "character(0)"
  } else {
    deparse_compact(step$content)
  }

  parts <- paste0('step_text(', content_code, ', "', step$dest, '"')

  if (step$strategy != "overwrite") {
    parts <- paste0(parts, ', strategy = "', step$strategy, '"')
  }

  paste0(parts, ")")
}

format_step_run_code <- function(step) {
  parts <- paste0("step_run(", step$label)

  if (length(step$args) > 0L) {
    arg_strs <- character(length(step$args))
    nms <- names(step$args)
    for (i in seq_along(step$args)) {
      val <- deparse_compact(step$args[[i]])
      if (!is.null(nms) && nms[i] != "") {
        arg_strs[i] <- paste0(nms[i], " = ", val)
      } else {
        arg_strs[i] <- val
      }
    }
    parts <- paste0(parts, ", ", paste(arg_strs, collapse = ", "))
  }

  paste0(parts, ")")
}

deparse_compact <- function(x) {
  paste(deparse(x), collapse = "")
}
