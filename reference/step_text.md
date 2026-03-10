# Create an inline text deployment step

Creates a step that deploys inline text content to the project. Like
[`step_file()`](https://economic.github.io/prefab/reference/step_file.md)
but takes a character vector instead of a source file path.

## Usage

``` r
step_text(content, dest, strategy = "overwrite")
```

## Arguments

- content:

  Character vector of lines to deploy (one element per line).
  `character(0)` is allowed except with `strategy = "merge_json"`.

- dest:

  Path to the destination, relative to the project root.

- strategy:

  How to handle a pre-existing destination file. One of `"overwrite"`,
  `"skip"`, `"union"`, `"append"`, or `"merge_json"`.

## Value

A list with class `"prefab_step_text"`.
