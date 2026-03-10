# Apply a theme to the current project

Discovers the project root and executes the theme against it.

## Usage

``` r
use_theme(theme)
```

## Arguments

- theme:

  A `prefab_theme` object created by
  [`new_theme()`](https://economic.github.io/prefab/reference/new_theme.md)
  or a pre-set theme function.

## Value

The project root path (invisibly).

## Examples

``` r
if (FALSE) { # \dontrun{
use_theme(r_analysis())
use_theme(r_analysis() + claude_r_analysis())
} # }
```
