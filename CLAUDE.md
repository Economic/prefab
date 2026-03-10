# prefab

An R package providing opinionated project scaffolding via a composable
theme system. A major use case is standardizing project setup and
conventions for data analysis at the Economic Policy Institute (EPI),
but the configurations are useful for any data analysis project.

## Status

Development (0.0.0.9000). Core theme system is fully implemented. All
exported functions are working with 232 passing tests and clean R CMD
check.

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
- `use_theme(theme)` — apply a theme to the current project
- `create_project(path, theme)` — create a directory and apply a theme
- `theme_code(theme)` — print the R code that reproduces a theme (for
  copy-paste customization)

## Pre-set themes

- [`r_analysis()`](https://economic.github.io/prefab/reference/r_analysis.md),
  [`r_targets()`](https://economic.github.io/prefab/reference/r_targets.md)
  — project structure scaffolding
- [`claude_r_analysis()`](https://economic.github.io/prefab/reference/claude_r_analysis.md),
  [`claude_r_targets()`](https://economic.github.io/prefab/reference/claude_r_targets.md)
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
      themes-project.R        # r_analysis(), r_targets(), gitignore_lines
      themes-claude.R         # claude_r_analysis(), claude_r_targets()
    inst/
      claude/                 # Agent config files deployed by Claude themes
        settings.json         # Claude Code permission settings
        rules/                # Agent convention files (one per project type)
          r_analysis.md       # Conventions for analysis projects
          r_package.md        # Conventions for package development (deferred theme)
          r_targets.md        # Conventions for targets workflows
        skills/               # Claude Code skills (deferred themes)
      r_analysis/             # Template files deployed by r_analysis()
      r_targets/              # Template files deployed by r_targets()
    plans/                    # Design and implementation plans
    tests/testthat/           # Tests (232 tests across 11 test files)

## Planning documents

1.  `plans/2026-03-04-architecture.md` — full design reference
2.  `plans/2026-03-04-implementation.md` — phased implementation tasks
3.  `plans/2026-03-06-included-themes.md` — what themes ship and what
    they deploy

## Future work

- **Deferred themes.** `claude_r_package()`, `r_package()`, and
  `epi_economics_data()` are designed but deferred from the initial
  release. See `plans/2026-03-06-included-themes.md` for details.
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
