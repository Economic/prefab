# Building custom themes with prefab

prefab scaffolds projects by applying **themes** – ordered lists of
steps that deploy files, inject text, or run functions. This vignette
covers using the built-in themes, composing them, and writing your own.

## Using built-in themes

Apply a theme to an existing project with
[`use_theme()`](https://economic.github.io/prefab/reference/use_theme.md),
or start a new project with
[`create_project()`](https://economic.github.io/prefab/reference/create_project.md):

``` r
library(prefab)

use_theme(r_analysis())
create_project("~/projects/my-targets-project", r_targets())
```

[`use_theme()`](https://economic.github.io/prefab/reference/use_theme.md)
discovers the project root automatically (via `.here`, `.Rproj`, `.git`,
etc.).
[`create_project()`](https://economic.github.io/prefab/reference/create_project.md)
creates the directory first, then applies the theme.

## Composing themes with `+`

Themes compose with `+`, concatenating their step lists:

``` r
# Project structure + Claude Code agent config
use_theme(r_analysis() + claude_r_analysis())

create_project("~/projects/new-analysis", r_targets() + claude_r_targets())
```

Order matters: later steps can override earlier ones when the merge
strategy allows it (e.g., two themes deploying the same file with
`"overwrite"`).

## Inline themes

For quick customization, wrap
[`step_text()`](https://economic.github.io/prefab/reference/step_text.md)
or
[`step_run()`](https://economic.github.io/prefab/reference/step_run.md)
in
[`new_theme()`](https://economic.github.io/prefab/reference/new_theme.md):

``` r
extras <- new_theme(
  step_text(c("*.csv", "data/"), ".gitignore", strategy = "union"),
  step_run(fs::dir_create, "data", .label = "fs::dir_create")
)
use_theme(r_analysis() + extras)
```

`NULL` arguments are silently dropped, enabling conditional steps:

``` r
my_theme <- function(use_renv = FALSE) {
  new_theme(
    step_text(c("*.csv"), ".gitignore", strategy = "union"),
    if (use_renv) step_run(renv::init, .label = "renv::init")
  )
}
```

## Custom themes with `from_dir()`

[`from_dir()`](https://economic.github.io/prefab/reference/from_dir.md)
creates a step-builder that resolves source paths relative to a local
directory:

``` r
from_templates <- from_dir("~/my-templates")

my_theme <- new_theme(
  from_templates("header.md", "README.md", strategy = "skip"),
  from_templates("gitignore", ".gitignore", strategy = "union"),
  from_templates("Makefile", "Makefile")
)
use_theme(r_analysis() + my_theme)
```

The directory path is resolved to absolute at creation time, so later
working directory changes do not affect it.

## Theme functions

A theme function is any R function that returns a `prefab_theme`.
Parameters let you customize what gets deployed:

``` r
my_analysis <- function(use_data_dir = TRUE, extra_ignores = character(0)) {
  from_templates <- from_dir("~/my-templates")
  ignore_lines <- c(".Rproj.user", ".Rhistory", ".RData", extra_ignores)
  new_theme(
    from_templates("main.R", "main.R", strategy = "skip"),
    from_templates("README.md", "README.md", strategy = "skip"),
    step_text(ignore_lines, ".gitignore", strategy = "union"),
    if (use_data_dir) step_run(fs::dir_create, "data", .label = "fs::dir_create")
  )
}

use_theme(my_analysis(extra_ignores = "*.csv") + claude_r_analysis())
```

## Distributing themes via a package

Put template files in a package’s `inst/` directory and use
[`from_package()`](https://economic.github.io/prefab/reference/from_package.md):

``` r
# In mythemes/R/themes.R
#' @export
my_org_analysis <- function() {
  f <- from_package("mythemes")
  new_theme(
    f("templates/main.R", "main.R", strategy = "skip"),
    f("templates/README.md", "README.md", strategy = "skip", data = list()),
    f("claude/settings.json", ".claude/settings.json", strategy = "merge_json"),
    f("claude/rules/conventions.md", ".claude/rules/conventions.md")
  )
}
```

[`from_package()`](https://economic.github.io/prefab/reference/from_package.md)
works with both installed packages and `devtools::load_all()`. Users
compose your themes with any others:

``` r
use_theme(mythemes::my_org_analysis() + prefab::claude_r_analysis())
```

## Inspecting themes with `theme_code()`

[`theme_code()`](https://economic.github.io/prefab/reference/theme_code.md)
prints R code that reproduces a theme – useful for understanding
built-in themes or as a starting point for customization:

``` r
theme_code(claude_r_analysis())
#> new_theme(
#>   from_package("prefab")("claude/settings.json", ".claude/settings.json", strategy = "merge_json"),
#>   from_package("prefab")("claude/rules/r_analysis.md", ".claude/rules/r_analysis.md"),
#>   step_text(c(".Rproj.user", ".Rhistory", ".RData", ".DS_Store"), ".gitignore", strategy = "union")
#> )
```

Copy the output, edit it into your own theme function, and swap out or
add steps. The code is also returned invisibly as a string.

## Merge strategies

Every file step declares a **strategy** for handling pre-existing
destination files. Strategies are what make
[`use_theme()`](https://economic.github.io/prefab/reference/use_theme.md)
safe to re-run.

| Strategy       | Behavior                           | Idempotent | Typical use                   |
|----------------|------------------------------------|------------|-------------------------------|
| `"overwrite"`  | Replace the file entirely          | Yes        | Managed config files          |
| `"skip"`       | Do nothing if file exists          | Yes        | Starter files users will edit |
| `"union"`      | Append lines not already present   | Yes        | `.gitignore`, `.Rbuildignore` |
| `"append"`     | Append all content unconditionally | No         | Rare; prefer `"union"`        |
| `"merge_json"` | Recursively merge JSON objects     | Yes        | `.claude/settings.json`       |

Guidelines for choosing:

- Files the user should never edit: `"overwrite"`.
- Files the user will customize after first deploy: `"skip"`.
- Line-based config where entries accumulate: `"union"`.
- Structured JSON config: `"merge_json"` (objects merge key-by-key,
  arrays are union-merged, scalar collisions preserve the destination
  value).
- Avoid `"append"` unless you want duplicate content on re-runs.

## Template rendering

File steps support `{{var}}` interpolation when `data` is non-NULL:

``` r
from_templates <- from_dir("~/my-templates")
new_theme(
  # data = list() enables rendering with auto-discovered variables only
  from_templates("README.md", "README.md", strategy = "skip", data = list()),
  # Explicit variables supplement or override auto-context
  from_templates("CITATION.md", "CITATION.md",
                 data = list(org_name = "Acme Corp"))
)
```

Auto-discovered variables (built once per
[`use_theme()`](https://economic.github.io/prefab/reference/use_theme.md)
call):

| Variable       | Source                                             |
|----------------|----------------------------------------------------|
| `project_dir`  | Name of the project root directory                 |
| `package_name` | `Package` field from DESCRIPTION, or `project_dir` |
| `year`         | Current year                                       |
| `date`         | Current date (`YYYY-MM-DD`)                        |

A template file like:

    # {{project_dir}}

    Created {{date}} by {{org_name}}.

is rendered by merging explicit `data` on top of auto-context. Explicit
values win on collision. If a variable is referenced but not available,
rendering fails with an informative error.

[`step_text()`](https://economic.github.io/prefab/reference/step_text.md)
does not support `data` – inline content can interpolate R variables
directly.
