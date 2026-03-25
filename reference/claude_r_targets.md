# Claude Code configuration theme for R targets projects

Creates a theme that deploys Claude Code agent settings and rules for an
R targets project.

## Usage

``` r
claude_r_targets(settings_json = TRUE)
```

## Arguments

- settings_json:

  Logical. If `TRUE` (default), merges the package `settings.json` into
  `.claude/settings.json`.

## Value

A `prefab_theme` object.

## Examples

``` r
claude_r_targets()
#> <theme> 4 steps
#> • Writing .claude/settings.json (merge_json)
#> • Writing .claude/rules/r_targets.md (overwrite)
#> • Writing .claude/rules/r_analysis.md (skip)
#> • Writing .gitignore (union)
#> ℹ Apply with `use_theme()` or `create_project()`
```
