# Load custom theme definitions

Sources an R file containing custom theme functions into the global
environment, making them available for use with
[`use_theme()`](https://economic.github.io/prefab/reference/use_theme.md)
and
[`create_project()`](https://economic.github.io/prefab/reference/create_project.md).

## Usage

``` r
load_themes(file = NULL)
```

## Arguments

- file:

  Path to an R file defining theme functions. If `NULL`, falls back to
  the `PREFAB_THEMES` environment variable, then `~/.prefab-themes.R`.

## Value

The file path that was sourced (invisibly), or `NULL` invisibly if no
file was found.

## Details

The file is resolved in order: the explicit `file` argument, then the
`PREFAB_THEMES` environment variable, then `~/.prefab-themes.R`.

## Examples

``` r
if (FALSE) { # \dontrun{
# Source from default locations
load_themes()

# Source from a specific file
load_themes("~/my-org-themes.R")
} # }
```
