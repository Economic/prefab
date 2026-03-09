## Guidance for using targets-based workflows in R

If the general targets scaffolding (`_targets.R`, etc.) does not exist, create

- `packages.R`: for all `library()` calls
- `_targets.R`: for the pipeline
- `R/`: for all functions

### Development workflow


### `_targets.R`

`_targets.R` should have the following structure

```
source("./packages.R")
tar_source()

## targets pipeline goes here
```
### Pipeline conventions

Use `tarchetypes::tar_assign()` instead of a simple list.  

Every assignment inside `tar_assign` must pipe into (or be wrapped by) a target factory — `tar_target()`, `tar_file()`, `tar_file_read()`, etc. A bare `my_target = f(input)` without `tar_target()` will fail. 

Prefer `f(x) |> tar_target()` over `tar_target(f(x))` — the pipe style reads top-to-bottom as "compute, then store."

Here is a complete example showing the preferred syntax for regular targets, file inputs, and file outputs together inside one `tar_assign` block:

```
tar_assign({
  raw_file = "data.csv" |>
    tar_file()

  raw_data = read_csv(raw_file) |>
    tar_target()

  result = analyze(raw_data) |>
    tar_target()

  output_file = write_output(result) |>
    tar_file()
})
```

### File targets

For tracking input or output files, do not use `tar_target(format = "file")` but instead use `tarchetypes::tar_file()`.

If an input file can be parsed easily without a complicated set of arguments use `tarchetypes::tar_file_read`:

```
data_input = "data_input.csv" |>
  tar_file_read(read_csv(file = !!.x, show_col_types = F))
```

### Packages

Do not use `renv` unless requested explicitly.

All packages should be loaded in packages.R. Do not use syntax like `package::function()`.

### Structuring pipelines: default to "wide" instead of "long"

Wide pipelines split work into independent targets that read from shared upstream targets rather than from each other. Long, linear pipelines chain targets sequentially, where each step feeds the next. 

Default to wide. Wide pipelines pay off quickly because we re-run the pipeline many times as we develop and unrelated targets stay cached. Go long only when steps are genuinely linear with no branching consumers, or for simple projects where end-to-end run time is very short.

If an upstream change invalidates many targets, the pipeline may be too long and should be widened.