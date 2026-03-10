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
#> ── Theme (3 steps) ─────────────────────────────────────────────────────────────
#> file .claude/settings.json merge_json
#> file .claude/rules/r_targets.md overwrite
#> text .gitignore union
```
