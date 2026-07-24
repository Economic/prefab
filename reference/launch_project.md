# Launch a new project from an editor keyboard shortcut

Interactive project launcher: prompts for a project name via
[`rstudioapi::showPrompt()`](https://rstudio.github.io/rstudioapi/reference/showPrompt.html),
builds a path from `root` (and an optional dated subdirectory), and
creates the project with
[`create_project()`](https://economic.github.io/prefab/reference/create_project.md).
It is designed to be bound to a key chord so that a single keystroke
scaffolds and opens a fresh project. The prompt shows the destination
directory (including the dated subdirectory when `date = TRUE`), and
re-prompts with a hint if the entered name is invalid rather than
aborting.

## Usage

``` r
launch_project(
  theme,
  root = getOption("prefab.project_root", "~"),
  date = FALSE,
  slug = getOption("prefab.project_slug", TRUE),
  open = rlang::is_interactive(),
  label = NULL
)
```

## Arguments

- theme:

  A `prefab_theme` object created by
  [`new_theme()`](https://economic.github.io/prefab/reference/new_theme.md)
  or a pre-set theme function. Required; there is no default, so each
  key chord names the theme it applies.

- root:

  Directory under which the project is created. Defaults to the
  `prefab.project_root` option, or the home directory (`"~"`) if unset.

- date:

  Whether to nest the project under a `YYYY-MM-DD` subdirectory of
  `root` (useful for dated, one-off projects). Defaults to `FALSE`.

- slug:

  Whether to slugify the entered name into a filesystem-safe directory
  name (lower-case, non-alphanumeric runs collapsed to `_`). Defaults to
  the `prefab.project_slug` option, or `TRUE` if unset. When `FALSE`,
  the name is used verbatim and validated, erroring on characters that
  are unsafe in a path component.

- open:

  Whether to activate the new project after creating it. Passed to
  [`create_project()`](https://economic.github.io/prefab/reference/create_project.md),
  following the convention of
  [`usethis::create_project()`](https://usethis.r-lib.org/reference/create_package.html):
  when `TRUE`, the project opens in a new session/window in
  RStudio/Positron, or in other editors the working directory of the
  active session is changed into the new project. Defaults to
  [`rlang::is_interactive()`](https://rlang.r-lib.org/reference/is_interactive.html).

- label:

  Optional prompt-window title, used to show which theme a key chord
  will apply (e.g. `"r_targets + claude_r_targets"`). Because a
  `prefab_theme` object does not retain the names used to build it, pass
  a human-readable label here. Defaults to `"New project folder"`.

## Value

The normalized project path (invisibly), or `NULL` if the prompt is
cancelled or left empty.

## Details

Bind it in Positron by running it via
`workbench.action.executeCode.console`, for example in
`keybindings.json`:

    {
      "key": "Ctrl+P N",
      "command": "workbench.action.executeCode.console",
      "args": {
        "langId": "r",
        "code": "prefab::launch_project(prefab::r_analysis(), label = 'r_analysis')",
        "focus": false
      }
    }

Use one chord per theme (mirroring how the built-in themes are composed)
to get a menu of launchers, e.g. a second binding with
`prefab::launch_project(prefab::r_targets() + prefab::claude_r_targets())`.

For programmatic (non-interactive) project creation from a known path,
use
[`create_project()`](https://economic.github.io/prefab/reference/create_project.md)
directly.
