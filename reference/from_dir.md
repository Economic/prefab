# Create a step-builder from a local directory

Returns a step-builder function that resolves source paths relative to a
local directory. The directory path is resolved to an absolute path at
creation time.

## Usage

``` r
from_dir(path)
```

## Arguments

- path:

  Path to the directory. Resolved to absolute via
  [`fs::path_abs()`](https://fs.r-lib.org/reference/path_math.html) at
  creation time. Must exist.

## Value

A function with signature
`function(source, dest, strategy = "overwrite", data = NULL)` that
returns a
[`step_file()`](https://economic.github.io/prefab/reference/step_file.md)
object.
