# Changelog

## prefab 0.0.0.9000

- Initial implementation of the composable theme system.
- Step constructors:
  [`step_file()`](https://economic.github.io/prefab/reference/step_file.md),
  [`step_text()`](https://economic.github.io/prefab/reference/step_text.md),
  [`step_run()`](https://economic.github.io/prefab/reference/step_run.md).
- Source helpers:
  [`from_package()`](https://economic.github.io/prefab/reference/from_package.md),
  [`from_dir()`](https://economic.github.io/prefab/reference/from_dir.md).
- Theme construction and composition:
  [`new_theme()`](https://economic.github.io/prefab/reference/new_theme.md),
  `+`.
- Five merge strategies: `"overwrite"`, `"skip"`, `"append"`, `"union"`,
  `"merge_json"`.
- Template rendering with `{{var}}` syntax via glue.
- Public API:
  [`use_theme()`](https://economic.github.io/prefab/reference/use_theme.md),
  [`create_project()`](https://economic.github.io/prefab/reference/create_project.md),
  [`theme_code()`](https://economic.github.io/prefab/reference/theme_code.md).
- Pre-set project themes:
  [`r_analysis()`](https://economic.github.io/prefab/reference/r_analysis.md),
  [`r_targets()`](https://economic.github.io/prefab/reference/r_targets.md).
- Pre-set Claude Code agent themes:
  [`claude_r_analysis()`](https://economic.github.io/prefab/reference/claude_r_analysis.md),
  [`claude_r_targets()`](https://economic.github.io/prefab/reference/claude_r_targets.md).
