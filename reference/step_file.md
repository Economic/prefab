# Create a file deployment step

Creates a step that deploys a file or directory to the project.

## Usage

``` r
step_file(source, dest, strategy = "overwrite", data = NULL)
```

## Arguments

- source:

  Absolute path to the source file or directory. Typically produced by a
  source helper
  ([`from_package()`](https://economic.github.io/prefab/reference/from_package.md),
  [`from_dir()`](https://economic.github.io/prefab/reference/from_dir.md))
  rather than written by hand.

- dest:

  Path to the destination, relative to the project root.

- strategy:

  How to handle a pre-existing destination file. One of `"overwrite"`,
  `"skip"`, `"union"`, `"append"`, or `"merge_json"`.

- data:

  `NULL` (default) for static file copy, or a named list of variables to
  interpolate into the file via `{{var}}` syntax before deploying.

## Value

A list with class `"prefab_step_file"`.
