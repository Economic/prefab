# Create a step-builder from an installed package

Returns a step-builder function that resolves source paths relative to a
package's `inst/` directory. Works with both installed packages and
during development with `devtools::load_all()`.

## Usage

``` r
from_package(package)
```

## Arguments

- package:

  Package name (string).

## Value

A function with signature
`function(source, dest, strategy = "overwrite", data = NULL)` that
returns a
[`step_file()`](https://economic.github.io/prefab/reference/step_file.md)
object.
