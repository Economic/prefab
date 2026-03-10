#' Execute a theme against a project directory
#'
#' Internal function that iterates over theme steps and dispatches each one.
#'
#' @param theme A `prefab_theme` object.
#' @param project_root Absolute path to the project root directory.
#' @return Invisible `NULL`.
#' @noRd
execute_theme <- function(theme, project_root) {
  auto_context <- build_auto_context(project_root)
  steps <- theme$steps
  n <- length(steps)

  for (i in seq_along(steps)) {
    step <- steps[[i]]

    tryCatch(
      {
        if (inherits(step, "prefab_step_file")) {
          deploy_file(
            step$source, step$dest, step$strategy,
            step$data, auto_context, project_root
          )
        } else if (inherits(step, "prefab_step_text")) {
          deploy_text(step$content, step$dest, step$strategy, project_root)
        } else if (inherits(step, "prefab_step_run")) {
          cli::cli_alert_success("Running {step$label}()")
          withr::with_dir(project_root, do.call(step$fn, step$args))
        }
      },
      error = function(e) {
        dest_or_label <- if (inherits(step, "prefab_step_run")) {
          step$label
        } else {
          step$dest
        }
        cli::cli_alert_danger("Step {i}/{n} failed: {dest_or_label}")
        skipped <- n - i
        if (skipped > 0L) {
          cli::cli_alert_info("Skipping {skipped} remaining step{?s}.")
        }
        cli::cli_abort(
          "Theme execution failed at step {i}/{n}.",
          parent = e
        )
      }
    )
  }

  invisible()
}
