# Print R code that reproduces a theme

Prints the R code that would reproduce the given theme via
[`cat()`](https://rdrr.io/r/base/cat.html), and returns the code
invisibly as a single character string.

## Usage

``` r
theme_code(theme)
```

## Arguments

- theme:

  A `prefab_theme` object.

## Value

The generated R code as a single character string (invisibly).
