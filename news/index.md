# Changelog

## prefab 0.1.0

- Initial release

## prefab 0.2.0

- New
  [`theme_from_dir()`](https://economic.github.io/prefab/reference/theme_from_dir.md)
  creates a theme from a directory of template files, with optional
  `_prefab.yml` sidecar for per-file strategy and template data control.
- New
  [`load_themes()`](https://economic.github.io/prefab/reference/load_themes.md)
  sources custom theme definitions from a file, with support for the
  `PREFAB_THEMES` environment variable and a `~/.prefab-themes.R`
  default.
- [`step_file()`](https://economic.github.io/prefab/reference/step_file.md)
  now accepts `data = "auto"` as a clearer alternative to
  `data = list()` for enabling auto-context template rendering.
- [`claude_r_analysis()`](https://economic.github.io/prefab/reference/claude_r_analysis.md)
  and
  [`claude_r_targets()`](https://economic.github.io/prefab/reference/claude_r_targets.md)
  gain a `settings_json` argument to optionally skip deploying
  `settings.json`.
- Updated bundled `settings.json` to make the `air` formatter hook
  conditional on `air` being installed.
- Updated bundled `r_analysis.md` with guidance on column-wise
  operations and naming intermediate objects.
