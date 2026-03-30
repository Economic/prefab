# prefab

prefab provides an opinionated theme system for setting up R projects. A
theme is a function that returns an ordered list of steps that deploy
files, inject text, or run functions. Because themes are functions, they
take parameters, compose with `+`, and ship in packages. Nothing touches
the file system until you apply a theme with
[`use_theme()`](https://economic.github.io/prefab/reference/use_theme.md)
or
[`create_project()`](https://economic.github.io/prefab/reference/create_project.md).

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

create_project("~/projects/my-analysis", r_analysis())
#> ✔ Running fs::dir_create('data_raw')
#> ✔ Running fs::dir_create('data_processed')
#> ✔ Writing 'main.R' (new)
#> ✔ Writing 'README.md' (new)
#> ✔ Writing '.gitignore' (new)
```

Add a theme to an existing project:

``` r
use_theme(claude_r_analysis())
#> ✔ Writing '.claude/settings.json' (new)
#> ✔ Writing '.claude/rules/r_analysis.md' (new)
#> ✔ Writing '.gitignore' (new)
```

## Built-in themes

| Theme                                                                                     | Description                                                         |
|-------------------------------------------------------------------------------------------|---------------------------------------------------------------------|
| [`r_analysis()`](https://economic.github.io/prefab/reference/r_analysis.md)               | `main.R`, `README.md`, `.gitignore`, `data_raw/`, `data_processed/` |
| [`r_targets()`](https://economic.github.io/prefab/reference/r_targets.md)                 | `_targets.R`, `packages.R`, `README.md`, `R/` dir, `.gitignore`     |
| [`claude_r_analysis()`](https://economic.github.io/prefab/reference/claude_r_analysis.md) | Claude Code settings and rules for data analysis projects           |
| [`claude_r_package()`](https://economic.github.io/prefab/reference/claude_r_package.md)   | Claude Code settings and rules for R packages                       |
| [`claude_r_targets()`](https://economic.github.io/prefab/reference/claude_r_targets.md)   | Claude Code settings and rules for targets projects                 |

## Composition

Themes compose with `+`. Steps execute left-to-right:

``` r
theme <- r_targets() + claude_r_targets()

create_project("my-project", theme)
#> ✔ Writing '_targets.R' (new)
#> ✔ Writing 'packages.R' (new)
#> ✔ Writing 'README.md' (new)
#> ✔ Writing '.gitignore' (new)
#> ✔ Running fs::dir_create('R')
#> ✔ Writing '.claude/settings.json' (new)
#> ✔ Writing '.claude/rules/r_targets.md' (new)
#> ✔ Writing '.claude/skills/targets-branching/SKILL.md' (new)
#> ✔ Writing '.claude/rules/r_analysis.md' (new)
#> ✔ Writing '.gitignore' (union)
```

## Building custom themes

prefab ships with some basic themes, but its real goal is to make it
simple for you to apply the kinds of project scaffolding that you
prefer. There are three ways to build your own themes:

**From a directory of files.** Arrange template files in a folder and
[`theme_from_dir()`](https://economic.github.io/prefab/reference/theme_from_dir.md)
turns them into a theme.

``` r
my_theme <- theme_from_dir("~/my-project-layout")
```

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

**By composing existing themes.** Combine and extend built-in or custom
themes with `+`:

``` r
my_theme <- theme_from_dir("~/my-project-layout") + claude_r_analysis() 
```

## Sharing and re-using custom themes

**Source a file.** Save theme functions in an external script and source
them.
[`load_themes()`](https://economic.github.io/prefab/reference/load_themes.md)
makes that easy: put themes in `~/.prefab-themes.R` (or set the
`PREFAB_THEMES` environment variable) and call
[`load_themes()`](https://economic.github.io/prefab/reference/load_themes.md)
to make them available.

``` r
load_themes()
use_theme(my_analysis_theme())
```

**Ship in a package.** This package ships with several basic themes, and
you can add themes (which are just functions) to your own package. Use
[`from_package()`](https://economic.github.io/prefab/reference/from_package.md)
to resolve template files from `inst/`. Best for sharing themes across
an organization.

More information on building and deploying themes is in the [Getting
Started
vignette](https://economic.github.io/prefab/articles/prefab.html).

## Acknowledgments

This package draws heavily on ideas from the R packages:

- [starter](https://www.danieldsjoberg.com/starter/) by Daniel D.
  Sjoberg
- [tflow](https://milesmcbain.r-universe.dev/tflow) by Miles McBain
- [usethis](https://usethis.r-lib.org/) by Hadley Wickham, Jennifer
  Bryan, Malcolm Barrett, and Andy Teucher.
