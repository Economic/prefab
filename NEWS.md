# prefab 0.5.0
* `create_project()` gains an `open` argument (default `rlang::is_interactive()`) controlling whether the new project is activated; follows usethis patterns and fixes VS Code specific bugs.

# prefab 0.4.0
* change `theme_from_dir` default strategy to "skip"
* reference `CLAUDE.md` as source of truth in `claude_r_analysis()`
* improve documentation

# prefab 0.3.0

* Improve agent guidance in `claude_r_analysis()` and `claude_r_targets()`
* Add targets-branching skill to files `claude_r_targets()` deploys

# prefab 0.2.0

* New `theme_from_dir()` creates a theme from a directory of template files, with optional `_prefab.yml` sidecar for per-file strategy and template data control.
* New `load_themes()` sources custom theme definitions from a file, with support for the `PREFAB_THEMES` environment variable and a `~/.prefab-themes.R` default.
* `step_file()` now accepts `data = "auto"` as a clearer alternative to `data = list()` for enabling auto-context template rendering.
* `claude_r_analysis()` and `claude_r_targets()` gain a `settings_json` argument to optionally skip deploying `settings.json`.
* Updated bundled `settings.json` to make the `air` formatter hook conditional on `air` being installed.
* Updated bundled `r_analysis.md` with guidance on column-wise operations and naming intermediate objects.

# prefab 0.1.0

* Initial release