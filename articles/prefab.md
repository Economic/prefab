# Getting started with prefab

## Basics

The goal of prefab is to make it easier for you to set up files and
directories you need for a given project. You can think of the project
scaffolding–like README files and directory structures–as a *theme* you
want to apply to a new or existing project directory.

### Viewing and applying themes

For example,
[`r_analysis()`](https://economic.github.io/prefab/reference/r_analysis.md)
is a prefab theme shipped with this package to provide scaffolding for a
simple R data analysis project. To understand what it does, simply call
the theme to show the outline of steps:

``` r

library(prefab)

r_analysis()
#> <theme> 5 steps
#> • run → fs::dir_create('data_raw')
#> • run → fs::dir_create('data_processed')
#> • Writing main.R (skip)
#> • Writing README.md (skip)
#> • Writing .gitignore (union)
#> ℹ Apply with `use_theme()` or `create_project()`
```

Nothing happens to the file system until you pass the theme to
[`use_theme()`](https://economic.github.io/prefab/reference/use_theme.md)
or
[`create_project()`](https://economic.github.io/prefab/reference/create_project.md).
Above, the
[`r_analysis()`](https://economic.github.io/prefab/reference/r_analysis.md)
theme indicated that it contains five steps: two create directories, and
three write files. File steps also contain a merge strategy shown in
`()` for handling pre-existing destination files.

Pass the theme to
[`create_project()`](https://economic.github.io/prefab/reference/create_project.md)
to create a new project folder with that scaffolding.

``` r

create_project(tempfile("my-analysis-project"), r_analysis())
#> ✔ Running fs::dir_create('data_raw')
#> ✔ Running fs::dir_create('data_processed')
#> ✔ Writing main.R (new)
#> ✔ Writing README.md (new)
#> ✔ Writing .gitignore (new)
```

That created a directory called `~/my-analysis-project` and added two
new subdirectories and three new files. Then (assuming you are using
Positron or Rstudio) it opened the project in a new session.

Instead of creating a new project directory, you can also apply a theme
to your current project with
[`use_theme()`](https://economic.github.io/prefab/reference/use_theme.md):

``` r

use_theme(r_analysis())
#> ✔ Running fs::dir_create('data_raw')
#> ✔ Running fs::dir_create('data_processed')
#> ✔ Writing main.R (new)
#> ✔ Writing README.md (new)
#> ✔ Writing .gitignore (new)
```

Alternatively you may find it useful to create and launch a new project
via a keyboard shortcut mapped to
[`launch_project()`](https://economic.github.io/prefab/reference/launch_project.md).

### Composing themes with `+` and arguments

A prefab theme is a function that returns an ordered list of steps that
modify files and paths, or run other functions Because themes are just
functions, they can have arguments and you can compose them with `+`,
concatenating their steps.

``` r

use_theme(r_analysis(data_dirs = FALSE) + claude_r_analysis())
#> ✔ Running fs::dir_create('data_raw')
#> ✔ Running fs::dir_create('data_processed')
#> ✔ Writing main.R (new)
#> ✔ Writing README.md (new)
#> ✔ Writing .gitignore (new)
#> ✔ Writing .claude/rules/r_analysis.md (new)
#> ✔ Writing .gitignore (union)
```

Steps run left to right.

## Building your own theme

There are three ways to build your own theme:

**From a directory of files.** Arrange template files in a folder and
[`theme_from_dir()`](https://economic.github.io/prefab/reference/theme_from_dir.md)
turns them into a theme. For example, put your desired template files in
the folder `~/my-project-structure`:

``` r
├── data
├── R
│   └── analysis.R
│   .gitignore
└── README.md
```

Use
[`theme_from_dir()`](https://economic.github.io/prefab/reference/theme_from_dir.md)
to turn them into a theme, and then apply them to a new or existing
project:

``` r

my_theme <- theme_from_dir("~/my-project-structure")
use_theme(my_theme)
#> ✔ Running fs::dir_create('data')
#> ✔ Writing .gitignore (new)
#> ✔ Writing R/analysis.R (new)
#> ✔ Writing README.md (new)
```

An optional `_prefab.yml` sidecar controls per-file merge strategies and
template data.

**By composing existing themes.** Combine and extend built-in or custom
themes with `+`:

``` r

my_theme <- theme_from_dir("~/my-extras") + claude_r_analysis()
```

Themes are combined left to right.

**From steps.** Build themes programmatically with
[`step_file()`](https://economic.github.io/prefab/reference/step_file.md),
[`step_text()`](https://economic.github.io/prefab/reference/step_text.md),
and
[`step_run()`](https://economic.github.io/prefab/reference/step_run.md):

``` r

my_theme <- function() {
  new_theme(
    step_file("~/my_themes/header.R", "R/header.R"),
    step_text(c("*.csv", "*.rds"), ".gitignore", strategy = "union"),
    step_run(fs::dir_create, "tables", .label = "fs::dir_create('tables')")
  )
}
```

## Writing themes from steps

A prefab theme is a function that returns an ordered list of steps that
modify files and paths, or run other functions.

The three step types are:

- `step_file(source, dest)` – deploy a file
- `step_text(content, dest)` – deploy inline text
- `step_run(fn, ...)` – execute a function for its side effects

``` r

my_analysis_theme <- function() {
  ignore_lines <- c(".Rproj.user", ".Rhistory", ".RData")
  new_theme(
    step_file("~/my-templates/main.R", "main.R", strategy = "skip"),
    step_text(ignore_lines, ".gitignore", strategy = "union"),
    step_run(fs::dir_create, "data", .label = "fs::dir_create")
  )
}
```

Because themes are just functions, parameters give you conditional
behavior for free. `NULL` arguments to
[`new_theme()`](https://economic.github.io/prefab/reference/new_theme.md)
are silently dropped, so `if (cond) step(...)` works naturally.

``` r

my_analysis_theme <- function(use_data_dir = TRUE, extra_ignores = character(0)) {
  ignore_lines <- c(".Rproj.user", ".Rhistory", ".RData", extra_ignores)
  new_theme(
    step_file("~/my-templates/main.R", "main.R", strategy = "skip"),
    step_text(ignore_lines, ".gitignore", strategy = "union"),
    if (use_data_dir) step_run(fs::dir_create, "data", .label = "fs::dir_create")
  )
}
```

### Source helpers

[`from_dir()`](https://economic.github.io/prefab/reference/from_dir.md)
and
[`from_package()`](https://economic.github.io/prefab/reference/from_package.md)
create step-builders that resolve source paths relative to a directory
or an installed R package:

``` r

# Resolve from a local directory
from_templates <- from_dir("~/my-templates")
from_templates("header.md", "README.md", strategy = "skip")

# Resolve from an installed package's inst/ directory
from_my_package <- from_package("my_package")
from_my_package("r_analysis/main.R", "main.R", strategy = "skip")
```

[`from_dir()`](https://economic.github.io/prefab/reference/from_dir.md)
resolves its path to absolute at creation time, so later working
directory changes do not affect it.
[`from_package()`](https://economic.github.io/prefab/reference/from_package.md)
works with both installed packages and `devtools::load_all()`.

### Merge strategies

Every file step declares a **strategy** for handling pre-existing
destination files. Strategies are what make
[`use_theme()`](https://economic.github.io/prefab/reference/use_theme.md)
safe to re-run.

| Strategy | Behavior | Idempotent | Typical use |
|----|----|----|----|
| `"overwrite"` | Replace the file entirely | Yes | Managed config files |
| `"skip"` | Do nothing if file exists | Yes | Starter files users will edit |
| `"union"` | Append lines not already present | Yes | `.gitignore`, `.Rbuildignore` |
| `"append"` | Append all content unconditionally | No | Rare; prefer `"union"` |
| `"merge_json"` | Recursively merge JSON objects | Yes | `.claude/settings.json` |

Guidelines for choosing:

- Files the user should never edit: `"overwrite"`.
- Files the user will customize after first deploy: `"skip"`.
- Line-based config where entries accumulate: `"union"`.
- Structured JSON config: `"merge_json"` (objects merge key-by-key,
  arrays are union-merged, scalar collisions preserve the destination
  value).
- Avoid `"append"` unless you want duplicate content on re-runs.

### Template rendering

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

## Sharing and re-using custom themes

**Source a file.** Save theme functions in an external script and source
them. This can of course be any external script, or you can put themes
in `~/.prefab-themes.R` which is sourced by the function
[`load_themes()`](https://economic.github.io/prefab/reference/load_themes.md):

``` r

load_themes()
use_theme(my_analysis_theme())
```

**Ship in a package.** This package ships with several basic themes, and
you can add themes (which are just functions) to your own package. Using
a package is best sharing themes across an organization.

When writing a theme function for your own package, place template files
in `inst/` and use
[`from_package()`](https://economic.github.io/prefab/reference/from_package.md).

``` r
my_theme <- function() {
  from_my_package <- from_package("my_package")
  new_theme(
    from_my_package("main.R", "main.R", strategy = "skip")
    from_my_package("README.md", "README.md", strategy = "skip")
  )
}
```

## Inspecting themes with `theme_code()`

[`theme_code()`](https://economic.github.io/prefab/reference/theme_code.md)
prints R code that reproduces a theme – useful for understanding
built-in themes or as a starting point for customization:

``` r

theme_code(claude_r_analysis())
#> new_theme(
#> 
#>   from_package("prefab")("claude/settings.json", ".claude/settings.json", strategy = "merge_json"),
#> 
#>   from_package("prefab")("claude/rules/r_analysis.md", ".claude/rules/r_analysis.md"),
#> 
#>   step_text(c(".Rproj.user", ".Rhistory", ".RData", ".DS_Store"), ".gitignore", strategy = "union")
#> )
```

Copy the output, edit it into your own theme function, and swap out or
add steps. The code is also returned invisibly as a string.
