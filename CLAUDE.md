# prefab

An R package providing opinionated project scaffolding via a composable
theme system. The major use case is standardizing project setup and
conventions for data analysis.

## Core concepts

- **Theme**: an ordered list of steps, composed via `+`
- **`step_file(source, dest, strategy = "overwrite", data = NULL)`**:
  deploy a file with a merge strategy
- **`step_text(content, dest, strategy = "overwrite")`**: deploy inline
  text content with a merge strategy
- **`step_run(fn, ..., .label = NULL)`**: execute an R function
- **Source helpers**: `from_package(package)` and `from_dir(path)`
  return step-builders
- **Merge strategies**: `"overwrite"`, `"skip"`, `"union"`, `"append"`,
  `"merge_json"`
- **Template rendering**: `data = list(...)` enables `{{var}}`
  interpolation via glue

## Public API

- `step_file(source, dest, strategy = "overwrite", data = NULL)` —
  create a file deployment step
- `step_text(content, dest, strategy = "overwrite")` — create an inline
  text deployment step
- `step_run(fn, ..., .label = NULL)` — create a function execution step
- `from_package(package)` — return a step-builder
  `function(source, dest, strategy = "overwrite", data = NULL)` that
  resolves source paths from a package (installed or loaded via
  `devtools::load_all()`)
- `from_dir(path)` — return a step-builder
  `function(source, dest, strategy = "overwrite", data = NULL)` that
  resolves source paths from a local directory
- `new_theme(...)` — construct a theme from step objects
- `theme_from_dir(path, strategy = "skip")` — create a theme from a
  directory tree, with optional `_prefab.yml` sidecar
- `use_theme(theme)` — apply a theme to the current project
- `create_project(path, theme, open = rlang::is_interactive())` — create
  a directory and apply a theme; when `open` is `TRUE`, activate the
  project (new session/window in RStudio/Positron, else
  [`setwd()`](https://rdrr.io/r/base/getwd.html) fallback), following
  the usethis `proj_activate()` pattern
- `launch_project(theme, root, date = FALSE, slug, open, label = NULL)`
  — interactive project launcher intended to be bound to an editor key
  chord via `workbench.action.executeCode.console`. `theme` is required
  (no default), so each chord names the theme it applies. Prompts for a
  name via
  [`rstudioapi::showPrompt()`](https://rstudio.github.io/rstudioapi/reference/showPrompt.html)
  (guarded by `hasFun()`), builds the path via internal
  `build_project_path()`, then calls
  [`create_project()`](https://economic.github.io/prefab/reference/create_project.md).
  `root` defaults to option `prefab.project_root` (`~`), `slug` to
  option `prefab.project_slug` (`TRUE`); `date = TRUE` nests under a
  `YYYY-MM-DD` subdirectory. `label` sets the prompt window title
  (default `"New project folder"`) to show which theme a chord applies
  (theme objects don’t retain their constructor names, so the label is
  passed by the caller)
- `theme_code(theme)` — print the R code that reproduces a theme (for
  copy-paste customization)
- `load_themes(file = NULL)` — source custom theme definitions from a
  file (`PREFAB_THEMES` env var or `~/.prefab-themes.R`)

## Pre-set themes

- `r_analysis(data_dirs = TRUE)`,
  [`r_targets()`](https://economic.github.io/prefab/reference/r_targets.md)
  — project structure scaffolding
- `claude_r_analysis(settings_json = TRUE)`,
  `claude_r_targets(settings_json = TRUE)`,
  [`claude_r_package()`](https://economic.github.io/prefab/reference/claude_r_package.md)
  — Claude Code agent config

## Project structure

    R/
      prefab-package.R        # Package-level docs
      step.R                  # step_file(), step_text(), step_run()
      source-helpers.R        # from_package(), from_dir()
      theme.R                 # new_theme(), +.prefab_theme, print.prefab_theme, theme_code()
      strategy.R              # apply_strategy(), deploy_file(), deploy_text()
      merge-json.R            # merge_json_tree()
      render.R                # render_template(), build_auto_context()
      execute.R               # execute_theme()
      use-theme.R             # use_theme()
      create-project.R        # create_project()
      launch-project.R        # launch_project(), build_project_path()
      load-themes.R           # load_themes()
      theme-from-dir.R        # theme_from_dir()
      themes-project.R        # r_analysis(), r_targets(), gitignore_lines
      themes-claude.R         # claude_r_analysis(), claude_r_targets(), claude_r_package()
    inst/
      claude/                 # Agent config files deployed by Claude themes
        settings.json         # Claude Code permission settings
        rules/                # Agent convention files (one per project type)
          r_analysis.md       # Conventions for analysis projects
          r_package.md        # Conventions for package development
          r_targets.md        # Conventions for targets workflows
        skills/               # Claude Code skills
          targets-branching/  # Skill deployed by claude_r_targets()
      r_analysis/             # Template files deployed by r_analysis()
      r_targets/              # Template files deployed by r_targets()
    tests/testthat/           # Tests

## Future work

- **Deferred themes.** `r_package()` and `epi_economics_data()` are
  designed but deferred from the initial release.
  ([`claude_r_package()`](https://economic.github.io/prefab/reference/claude_r_package.md)
  has shipped.)
- **GitHub source helper.** A source helper that downloads files from a
  GitHub repository could enable organizations to maintain a central
  config repo or pull skills from public repos without requiring an R
  package. No design work has been done; API, caching, and scope are all
  open questions to investigate if the need arises.

## Conventions

- All implementation plans go in
  `./plans/YYYY-MM-DD-very-brief-description.md`.
- This CLAUDE.md must be updated after any change to the code.
- Follow the R coding conventions in `inst/claude/rules/r_package.md`
  when developing this package.
