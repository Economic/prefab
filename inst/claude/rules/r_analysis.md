## Guidance for data analysis in R

### General conventions

- Use tidyverse-friendly code
- Make plots using ggplot
- Use base pipe `|>` instead of `%>%`

### Development workflow

To run R code, use `Rscript main.R` or `Rscript -e "some_expression"`. Run code you write or edit in order to verify that it works and fix any problems.

### Syntax and structure

#### File names

Use lower case for file names. Delimit words with `_` or `-`. Avoid spaces.

#### Packages

If the complete data analysis is a single script, load all packages with `library()` calls at the beginning of the file. For multi-file workflows, source a separate `packages.R` file that contains all `library()` calls.

Use the `conflicted` package to resolve conflicts.

Use `renv` only if explicitly requested or already initialized.

#### Object names

Use snake case (lower case with underscores `_`) for variable and function names. Prefer verbs for function names.

#### Function calls

Never partially match function arguments with a unique prefix; use the full argument name instead.

For legibility purposes you may omit names of very common arguments, like a `data` argument.

Never omit argument names in a `switch()` statement.

#### Control flow

Never use `&` and `|` inside of an if clause because they can unexpectedly return vectors; always use `&&` and `||` instead.

#### Returned values in functions

Only use `return()` for early returns. Otherwise, rely on R to return the result of the last evaluated expression.

#### Comments

Use comments to explain the "why", and not the "what" or "how".

#### Style preferences

In dplyr-based joins use `by = join_by()` syntax, such as `by = join_by(a == b)` instead of `by = c("a" = "b")`.

When possible avoid `group_by` and use the `.by` argument.

Use `map_*()` instead of `sapply`.
