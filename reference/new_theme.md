# Create a theme from steps

Constructs a theme from step objects. `NULL` arguments are silently
dropped, enabling conditional steps via `if (cond) step(...)`.

## Usage

``` r
new_theme(...)
```

## Arguments

- ...:

  Step objects
  ([`step_file()`](https://economic.github.io/prefab/reference/step_file.md),
  [`step_text()`](https://economic.github.io/prefab/reference/step_text.md),
  [`step_run()`](https://economic.github.io/prefab/reference/step_run.md)).

## Value

A list with class `"prefab_theme"` containing a `steps` element.
