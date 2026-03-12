# prefab <a href="https://economic.github.io/prefab"><img src="man/figures/logo.png" align="right" height="139" alt="prefab website" /></a>

prefab provides an opinionated theme system for setting up R projects. A theme
is a function that returns an ordered list of steps that deploy
files, inject text, or run functions. Because themes are functions, they take
parameters, compose with `+`, and ship in packages. Nothing touches the file
system until you apply a theme with `use_theme()` or `create_project()`.

## Installation

``` r
install.packages(
  "prefab", 
  repos = c("https://economic.r-universe.dev", getOption("repos"))
)
```

## Quick start

Create a new project with scaffolding and Claude Code config:

``` r
library(prefab)

create_project("~/projects/my-analysis", r_analysis() + claude_r_analysis())
```

Add a theme to an existing project:

``` r
use_theme(claude_r_analysis())
```

## Built-in themes

| Theme | Description |
|---|---|
| `r_analysis()` | `main.R`, `README.md`, `.gitignore` |
| `r_targets()` | `_targets.R`, `packages.R`, `README.md`, `R/` dir, `.gitignore` |
| `claude_r_analysis()` | Claude Code settings and rules for analysis projects |
| `claude_r_targets()` | Claude Code settings and rules for targets projects |

## Composition

Themes compose with `+`. Steps execute left-to-right:
``` r
# Project structure + agent config in one call
theme <- r_targets() + claude_r_targets()

create_project("my-project", theme)
```

## Custom themes

Build themes from steps using `step_file()`, `step_text()`, `step_run()`, and
source helpers like `from_dir()`:

``` r
from_shared <- from_dir("~/shared-config")

my_theme <- new_theme(
  from_shared("header.R", "R/header.R"),
  step_text(c("*.csv", "*.rds"), ".gitignore", strategy = "union"),
  step_run(fs::dir_create, "output", .label = "fs::dir_create")
)

# Combine with built-in themes
create_project("my-project", r_analysis() + my_theme)
```

Source helpers resolve file paths from a directory (`from_dir()`) or an
installed R package (`from_package()`). Files with `data = list(...)` support
`{{var}}` template interpolation via glue.

## Merge strategies

Each step has a strategy that controls how it interacts with existing files:

| Strategy | Behaviour |
|---|---|
| `"overwrite"` | Replace the file (default) |
| `"skip"` | Do nothing if the file exists |
| `"union"` | Merge lines, keeping unique entries |
| `"append"` | Add content to the end of the file |
| `"merge_json"` | Deep-merge JSON trees |

## Inspecting themes

Use `theme_code()` to print the R code that reproduces any theme. This is
useful for understanding what a built-in theme does or as a starting point for
customization:

``` r
theme_code(r_analysis())
#> new_theme(
#>   from_package("prefab")("r_analysis/main.R", "main.R", strategy = "skip"),
#>   from_package("prefab")("r_analysis/README.md", "README.md", strategy = "skip", data = list()),
#>   step_text(c(".Rproj.user", ".Rhistory", ".RData", ".DS_Store"), ".gitignore", strategy = "union")
#> )
```

## Acknowledgments 

This package draws heavily on ideas from the R packages:

  - [starter](https://www.danieldsjoberg.com/starter/) by Daniel D. Sjoberg
  - [tflow](https://milesmcbain.r-universe.dev/tflow) by Miles McBain
  - [usethis](https://usethis.r-lib.org/) by Hadley Wickham, Jennifer Bryan, Malcolm Barrett, and Andy Teucher.

## License
MIT

