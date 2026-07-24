#' Launch a new project from an editor keyboard shortcut
#'
#' Interactive project launcher: prompts for a project name via
#' [rstudioapi::showPrompt()], builds a path from `root` (and an optional dated
#' subdirectory), and creates the project with [create_project()]. It is
#' designed to be bound to a key chord so that a single keystroke scaffolds and
#' opens a fresh project. The prompt shows the destination directory (including
#' the dated subdirectory when `date = TRUE`), and re-prompts with a hint if the
#' entered name is invalid rather than aborting.
#'
#' Bind it in Positron by running it via `workbench.action.executeCode.console`,
#' for example in `keybindings.json`:
#'
#' ```json
#' {
#'   "key": "Ctrl+P N",
#'   "command": "workbench.action.executeCode.console",
#'   "args": {
#'     "langId": "r",
#'     "code": "prefab::launch_project(prefab::r_analysis(), label = 'r_analysis')",
#'     "focus": false
#'   }
#' }
#' ```
#'
#' Use one chord per theme (mirroring how the built-in themes are composed) to
#' get a menu of launchers, e.g. a second binding with
#' `prefab::launch_project(prefab::r_targets() + prefab::claude_r_targets())`.
#'
#' For programmatic (non-interactive) project creation from a known path, use
#' [create_project()] directly.
#'
#' @param theme A `prefab_theme` object created by [new_theme()] or a pre-set
#'   theme function. Required; there is no default, so each key chord names the
#'   theme it applies.
#' @param root Directory under which the project is created. Defaults to the
#'   `prefab.project_root` option, or the home directory (`"~"`) if unset.
#' @param date Whether to nest the project under a `YYYY-MM-DD` subdirectory of
#'   `root` (useful for dated, one-off projects). Defaults to `FALSE`.
#' @param slug Whether to slugify the entered name into a filesystem-safe
#'   directory name (lower-case, non-alphanumeric runs collapsed to `_`).
#'   Defaults to the `prefab.project_slug` option, or `TRUE` if unset. When
#'   `FALSE`, the name is used verbatim and validated, erroring on characters
#'   that are unsafe in a path component.
#' @param open Whether to activate the new project after creating it. Passed to
#'   [create_project()], following the convention of [usethis::create_project()]:
#'   when `TRUE`, the project opens in a new session/window in RStudio/Positron,
#'   or in other editors the working directory of the active session is changed
#'   into the new project. Defaults to [rlang::is_interactive()].
#' @param label Optional prompt-window title, used to show which theme a key
#'   chord will apply (e.g. `"r_targets + claude_r_targets"`). Because a
#'   `prefab_theme` object does not retain the names used to build it, pass a
#'   human-readable label here. Defaults to `"New project folder"`.
#'
#' @return The normalized project path (invisibly), or `NULL` if the prompt is
#'   cancelled or left empty.
#' @export
launch_project <- function(
  theme,
  root = getOption("prefab.project_root", "~"),
  date = FALSE,
  slug = getOption("prefab.project_slug", TRUE),
  open = rlang::is_interactive(),
  label = NULL
) {
  # showPrompt() is provided by the editor's rstudioapi shim (RStudio, and
  # Positron >= 2025.10.0). Guard with hasFun() so older editors fail with a
  # useful message instead of a cryptic "function not found".
  if (!rlang::is_installed("rstudioapi") || !rstudioapi::hasFun("showPrompt")) {
    cli::cli_abort(c(
      "An interactive name prompt is not available in this editor.",
      "i" = "Call {.fn create_project} directly with a path instead."
    ))
  }

  title <- label %||% "New project folder"

  # Show the destination directory (including the dated subdirectory when
  # date = TRUE) so it is clear where the project will be created.
  dest <- fs::path_join(c(root, if (isTRUE(date)) format(Sys.Date())))
  base_message <- paste0("New project name (in ", dest, "/):")

  # Re-prompt loop: an invalid name (empty after slugifying, or unsafe
  # characters when slug = FALSE) shows a hint and asks again rather than
  # aborting, so a typo does not throw away the whole launch. Cancelling or
  # entering an empty name exits.
  message <- base_message
  repeat {
    name <- rstudioapi::showPrompt(title, message)

    if (is.null(name) || !nzchar(name)) {
      cli::cli_alert_info("Cancelled; no project created.")
      return(invisible(NULL))
    }

    path <- rlang::try_fetch(
      build_project_path(name, root = root, date = date, slug = slug),
      prefab_invalid_name = function(cnd) {
        message <<- paste0(cnd$prompt_hint, "\n", base_message)
        NULL
      }
    )

    if (!is.null(path)) {
      break
    }
  }

  create_project(path, theme, open = open)
}

# Build the project path from an entered name: optionally slugify or validate
# the name, prepend a dated subdirectory when requested, and join under root.
build_project_path <- function(name, root, date, slug) {
  if (!rlang::is_string(name) || !nzchar(name)) {
    cli::cli_abort("{.arg name} must be a non-empty string.")
  }

  dir_name <- if (isTRUE(slug)) slugify(name) else validate_name(name)

  parts <- c(
    fs::path_expand(root),
    if (isTRUE(date)) format(Sys.Date()),
    dir_name
  )
  fs::path_join(parts)
}

# Convert an arbitrary name into a filesystem-safe directory component:
# lower-case, non-alphanumeric runs collapsed to a single underscore, and
# leading/trailing underscores trimmed.
slugify <- function(name) {
  slug <- tolower(name)
  slug <- gsub("[^a-z0-9]+", "_", slug)
  slug <- gsub("^_+|_+$", "", slug)

  if (!nzchar(slug)) {
    cli::cli_abort(
      "{.arg name} {.val {name}} slugifies to an empty string.",
      class = "prefab_invalid_name",
      prompt_hint = "Name must contain some letters or numbers."
    )
  }

  slug
}

# Validate a name used verbatim as a directory component (slug = FALSE),
# erroring on characters that are unsafe or awkward in a path component.
validate_name <- function(name) {
  if (!grepl("^[A-Za-z0-9._-]+$", name)) {
    cli::cli_abort(
      c(
        "{.arg name} {.val {name}} contains characters unsafe for a directory name.",
        "i" = "Use only letters, numbers, {.val -}, {.val _}, {.val .}, or set {.code slug = TRUE}."
      ),
      class = "prefab_invalid_name",
      prompt_hint = "Use only letters, numbers, '-', '_', '.'"
    )
  }

  name
}
