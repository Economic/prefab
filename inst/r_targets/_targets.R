source("packages.R")
tar_source()

## pipeline
## targets must end in a target object like tar_target()
tar_assign({
  # target_name <- some_function(arg) |>
  #   tar_target()
})
