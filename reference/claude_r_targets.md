# Claude Code configuration theme for R targets projects

Creates a theme that deploys Claude Code agent settings and rules for an
R targets project.

## Usage

``` r
claude_r_targets()
```

## Value

A `prefab_theme` object.

## Examples

``` r
claude_r_targets()
#> <theme> 4 steps
#> • file → .claude/settings.json (merge_json)
#> • file → .claude/rules/r_targets.md (overwrite)
#> • file → .claude/rules/r_analysis.md (skip)
#> • text → .gitignore (union)
#> ℹ Apply with `use_theme()` or `create_project()`
```
