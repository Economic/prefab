# Claude Code configuration theme for R analysis projects

Creates a theme that deploys Claude Code agent settings and rules for an
R analysis project.

## Usage

``` r
claude_r_analysis()
```

## Value

A `prefab_theme` object.

## Examples

``` r
claude_r_analysis()
#> <theme> 3 steps
#> • file → .claude/settings.json (merge_json)
#> • file → .claude/rules/r_analysis.md (overwrite)
#> • text → .gitignore (union)
#> ℹ Apply with `use_theme()` or `create_project()`
```
