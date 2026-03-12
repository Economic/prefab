# prefab 0.0.0.9000

* Initial implementation of the composable theme system.
* Step constructors: `step_file()`, `step_text()`, `step_run()`.
* Source helpers: `from_package()`, `from_dir()`.
* Theme construction and composition: `new_theme()`, `+`.
* Five merge strategies: `"overwrite"`, `"skip"`, `"append"`, `"union"`, `"merge_json"`.
* Template rendering with `{{var}}` syntax via glue.
* Public API: `use_theme()`, `create_project()`, `theme_code()`.
* Pre-set project themes: `r_analysis()`, `r_targets()`.
* Pre-set Claude Code agent themes: `claude_r_analysis()`, `claude_r_targets()`, `claude_r_package()`.
