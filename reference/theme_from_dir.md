# Create a theme from a directory of template files

Converts a directory tree into a theme where each file becomes a
[`step_file()`](https://economic.github.io/prefab/reference/step_file.md).
An optional `_prefab.yml` sidecar file in the directory can override the
strategy and template data per file.

## Usage

``` r
theme_from_dir(path, strategy = "skip")
```

## Arguments

- path:

  Path to a directory of template files. Resolved to an absolute path
  via [`fs::path_abs()`](https://fs.r-lib.org/reference/path_math.html).
  Must exist.

- strategy:

  Default merge strategy for all files. Can be overridden per file via a
  `_prefab.yml` sidecar. One of `"overwrite"`, `"skip"`, `"union"`,
  `"append"`, or `"merge_json"`.

## Value

A `prefab_theme` object.

## Examples

``` r
if (FALSE) { # \dontrun{
# Create a theme from a directory of config files
use_theme(theme_from_dir("~/my-template"))

# Compose with other themes
use_theme(r_analysis() + theme_from_dir("~/my-extras"))
} # }
```
