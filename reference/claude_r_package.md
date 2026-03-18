# Claude Code configuration theme for R packages

Creates a theme that deploys Claude Code agent settings and rules for an
R package.

## Usage

``` r
claude_r_package()
```

## Value

A `prefab_theme` object.

## Examples

``` r
claude_r_package()
#> <theme> 4 steps
#> • Writing .claude/settings.json (merge_json)
#> • Writing .claude/rules/r_package.md (overwrite)
#> • Writing .gitignore (union)
#> • Writing .Rbuildignore (union)
#> ℹ Apply with `use_theme()` or `create_project()`
```
