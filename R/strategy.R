#' Apply a merge strategy to write content to a file
#'
#' Pure write function with no CLI output. Dispatches to the appropriate
#' strategy implementation.
#'
#' @param lines Character vector of source content.
#' @param dest_path Resolved absolute destination path.
#' @param strategy One of "overwrite", "skip", "append", "union", "merge_json".
#' @return Invisible NULL.
#' @noRd
apply_strategy <- function(lines, dest_path, strategy) {
  fs::dir_create(fs::path_dir(dest_path))

  switch(strategy,
    overwrite = strategy_overwrite(lines, dest_path),
    skip = strategy_skip(lines, dest_path),
    append = strategy_append(lines, dest_path),
    union = strategy_union(lines, dest_path),
    merge_json = strategy_merge_json(lines, dest_path),
    cli::cli_abort("Unknown strategy: {.val {strategy}}")
  )

  invisible()
}

#' @noRd
strategy_overwrite <- function(lines, dest_path) {
  writeLines(lines, dest_path)
}

#' @noRd
strategy_skip <- function(lines, dest_path) {
  if (fs::file_exists(dest_path)) {
    return(invisible())
  }

  writeLines(lines, dest_path)
}

#' @noRd
strategy_append <- function(lines, dest_path) {
  if (fs::file_exists(dest_path)) {
    existing <- readLines(dest_path, warn = FALSE)
    lines <- c(existing, lines)
  }
  writeLines(lines, dest_path)
}

#' @noRd
strategy_union <- function(lines, dest_path) {
  if (fs::file_exists(dest_path)) {
    existing <- readLines(dest_path, warn = FALSE)
    new_lines <- lines[!lines %in% existing]
    lines <- c(existing, new_lines)
  }
  writeLines(lines, dest_path)
}

#' @noRd
strategy_merge_json <- function(lines, dest_path) {
  source_json <- jsonlite::fromJSON(
    paste(lines, collapse = "\n"),
    simplifyVector = FALSE
  )

  if (fs::file_exists(dest_path)) {
    dest_text <- readLines(dest_path, warn = FALSE)
    dest_json <- jsonlite::fromJSON(
      paste(dest_text, collapse = "\n"),
      simplifyVector = FALSE
    )
    merged <- merge_json_tree(source_json, dest_json)
  } else {
    merged <- source_json
  }

  json_text <- jsonlite::toJSON(merged, pretty = TRUE, auto_unbox = TRUE)
  writeLines(paste0(json_text, "\n"), dest_path, sep = "")
}

#' Deploy a file step
#'
#' @param source Absolute path to the source file or directory.
#' @param dest Relative destination path.
#' @param strategy Merge strategy.
#' @param data Template data (NULL or named list).
#' @param auto_context Auto-discovered template context.
#' @param project_root Absolute path to project root.
#' @return Invisible NULL.
#' @noRd
deploy_file <- function(source, dest, strategy, data, auto_context, project_root) {
  if (!(fs::file_exists(source) || fs::dir_exists(source))) {
    cli::cli_abort("Source path does not exist: {.path {source}}")
  }

  resolved_dest <- fs::path(project_root, dest)

  if (fs::is_dir(source)) {
    # Directory source
    if (!is.null(data)) {
      cli::cli_abort("Template rendering (data) is not supported for directory sources.")
    }
    if (fs::file_exists(resolved_dest) && !fs::is_dir(resolved_dest)) {
      cli::cli_abort("Cannot deploy directory to {.path {dest}}: destination exists as a file.")
    }

    source_files <- fs::dir_ls(source, type = "file", recurse = TRUE, follow = TRUE)
    for (src_file in source_files) {
      rel_path <- fs::path_rel(src_file, source)
      file_dest <- fs::path(dest, rel_path)
      deploy_file(
        source = src_file,
        dest = file_dest,
        strategy = strategy,
        data = NULL,
        auto_context = auto_context,
        project_root = project_root
      )
    }
  } else {
    # File source
    if (fs::dir_exists(resolved_dest)) {
      cli::cli_abort("Cannot deploy file to {.path {dest}}: destination exists as a directory.")
    }

    content <- readLines(source, warn = FALSE)

    if (!is.null(data)) {
      content <- render_template(content, data, auto_context)
    }

    # CLI output
    dest_exists <- fs::file_exists(resolved_dest)
    if (strategy == "skip" && dest_exists) {
      cli::cli_alert_info("Skipping {dest} (already exists)")
      return(invisible())
    }

    if (dest_exists) {
      cli::cli_alert_success("Writing {dest} ({strategy})")
    } else {
      cli::cli_alert_success("Writing {dest} (new)")
    }

    apply_strategy(content, resolved_dest, strategy)
  }

  invisible()
}

#' Deploy a text step
#'
#' @param content Character vector of lines to deploy.
#' @param dest Relative destination path.
#' @param strategy Merge strategy.
#' @param project_root Absolute path to project root.
#' @return Invisible NULL.
#' @noRd
deploy_text <- function(content, dest, strategy, project_root) {
  resolved_dest <- fs::path(project_root, dest)

  dest_exists <- fs::file_exists(resolved_dest)
  if (strategy == "skip" && dest_exists) {
    cli::cli_alert_info("Skipping {dest} (already exists)")
    return(invisible())
  }

  if (dest_exists) {
    cli::cli_alert_success("Writing {dest} ({strategy})")
  } else {
    cli::cli_alert_success("Writing {dest} (new)")
  }

  apply_strategy(content, resolved_dest, strategy)

  invisible()
}
