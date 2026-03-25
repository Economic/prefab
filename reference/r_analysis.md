# R analysis project theme

Creates a theme that scaffolds a simple R analysis project with
`main.R`, `README.md`, and `.gitignore`.

## Usage

``` r
r_analysis(data_dirs = TRUE)
```

## Arguments

- data_dirs:

  Logical. If `TRUE` (default), creates directories `./data_raw` and
  `./data_processed`.

## Value

A `prefab_theme` object.

## Examples

``` r
r_analysis()
#> <theme> 5 steps
#> • run → fs::dir_create('data_raw')
#> • run → fs::dir_create('data_processed')
#> • Writing main.R (skip)
#> • Writing README.md (skip)
#> • Writing .gitignore (union)
#> ℹ Apply with `use_theme()` or `create_project()`
```
