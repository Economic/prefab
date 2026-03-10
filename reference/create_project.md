# Create a new project and apply a theme

Creates a new project directory and applies a theme to it. If RStudio is
available, opens the new project in a new session.

## Usage

``` r
create_project(path, theme)
```

## Arguments

- path:

  Path for the new project directory. Resolved to an absolute path via
  [`fs::path_abs()`](https://fs.r-lib.org/reference/path_math.html).

- theme:

  A `prefab_theme` object created by
  [`new_theme()`](https://economic.github.io/prefab/reference/new_theme.md)
  or a pre-set theme function.

## Value

The normalized project path (invisibly).

## Examples

``` r
if (FALSE) { # \dontrun{
create_project("~/projects/my-analysis", r_analysis())
create_project("my-targets-project", r_targets() + claude_r_targets())
} # }
```
