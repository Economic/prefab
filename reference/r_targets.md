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
#> ── Theme (5 steps) ─────────────────────────────────────────────────────────────
#> file _targets.R skip
#> file packages.R skip
#> file README.md skip
#> text .gitignore union
#> run fs::dir_create()
```
