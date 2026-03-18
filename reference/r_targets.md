# R targets project theme

Creates a theme that scaffolds an R targets project with `_targets.R`,
`packages.R`, `README.md`, and `.gitignore`.

## Usage

``` r
r_targets()
```

## Value

A `prefab_theme` object.

## Examples

``` r
r_targets()
#> <theme> 5 steps
#> • Writing _targets.R (skip)
#> • Writing packages.R (skip)
#> • Writing README.md (skip)
#> • Writing .gitignore (union)
#> • run → fs::dir_create('R')
#> ℹ Apply with `use_theme()` or `create_project()`
```
