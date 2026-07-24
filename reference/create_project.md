# Create a new project and apply a theme

Creates a new project directory and applies a theme to it.

## Usage

``` r
create_project(path, theme, open = rlang::is_interactive())
```

## Arguments

- path:

  Path for the new project directory. Resolved to an absolute path via
  [`fs::path_abs()`](https://fs.r-lib.org/reference/path_math.html).

- theme:

  A `prefab_theme` object created by
  [`new_theme()`](https://economic.github.io/prefab/reference/new_theme.md)
  or a pre-set theme function.

- open:

  Whether to activate the new project after creating it, following the
  convention of
  [`usethis::create_project()`](https://usethis.r-lib.org/reference/create_package.html)
  and
  [`usethis::create_package()`](https://usethis.r-lib.org/reference/create_package.html):
  when `TRUE`, the project opens in a new session/window in
  RStudio/Positron, or in other editors the working directory of the
  active session is changed into the new project. Defaults to
  [`rlang::is_interactive()`](https://rlang.r-lib.org/reference/is_interactive.html),
  so it opens interactively but stays inert in scripts, tests, and
  non-interactive callers.

## Value

The normalized project path (invisibly).

## Examples

``` r
if (FALSE) { # \dontrun{
create_project("~/projects/my-analysis", r_analysis())
create_project("my-targets-project", r_targets() + claude_r_targets())
} # }
```
