# Create a function execution step

Creates a step that executes an R function for its side effects.

## Usage

``` r
step_run(fn, ..., .label = NULL)
```

## Arguments

- fn:

  A function to execute.

- ...:

  Additional arguments passed to `fn` at execution time.

- .label:

  Optional label for display. When `NULL` (default), captured via
  `deparse(substitute(fn))`.

## Value

A list with class `"prefab_step_run"`.
