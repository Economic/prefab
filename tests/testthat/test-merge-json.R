# merge_json_tree() -----------------------------------------------------------

test_that("merge_json preserves user-added permissions", {
  source <- list(
    permissions = list(
      allow = list("Bash(ls:*)")
    )
  )
  dest <- list(
    permissions = list(
      allow = list("Bash(ls:*)", "Bash(custom:*)")
    )
  )
  result <- merge_json_tree(source, dest)
  expect_equal(
    result$permissions$allow,
    list("Bash(ls:*)", "Bash(custom:*)")
  )
})

test_that("merge_json handles hooks merging", {
  source <- list(
    hooks = list(
      PostToolUse = list(
        list(
          matcher = "Edit|Write",
          hooks = list(
            list(type = "command", command = "air format .")
          )
        )
      )
    )
  )
  dest <- list(
    hooks = list(
      PostToolUse = list(
        list(
          matcher = "Bash",
          hooks = list(
            list(type = "command", command = "echo done")
          )
        )
      )
    )
  )
  result <- merge_json_tree(source, dest)

  # Both matcher entries should be present
  matchers <- vapply(
    result$hooks$PostToolUse,
    function(x) x$matcher,
    character(1)
  )
  expect_true("Bash" %in% matchers)
  expect_true("Edit|Write" %in% matchers)
})

test_that("merge_json by-matcher collision merges hook commands", {
  source <- list(
    hooks = list(
      PostToolUse = list(
        list(
          matcher = "Edit|Write",
          hooks = list(
            list(type = "command", command = "air format ."),
            list(type = "command", command = "lint .")
          )
        )
      )
    )
  )
  dest <- list(
    hooks = list(
      PostToolUse = list(
        list(
          matcher = "Edit|Write",
          hooks = list(
            list(type = "command", command = "air format .")
          )
        )
      )
    )
  )
  result <- merge_json_tree(source, dest)

  # Should have a single matcher entry with both hooks
  expect_length(result$hooks$PostToolUse, 1)
  hooks <- result$hooks$PostToolUse[[1]]$hooks
  expect_length(hooks, 2)
  commands <- vapply(hooks, function(x) x$command, character(1))
  expect_true("air format ." %in% commands)
  expect_true("lint ." %in% commands)
})

test_that("merge_json preserves dest scalars on collision", {
  source <- list(model = "sonnet", `$schema` = "https://example.com")
  dest <- list(model = "opus", `$schema` = "https://example.com")
  result <- merge_json_tree(source, dest)
  expect_equal(result$model, "opus")
})

test_that("merge_json handles non-existent dest (just writes source)", {
  # This tests the merge_json strategy path in apply_strategy
  # when dest does not exist
  tmp <- withr::local_tempdir()
  dest <- file.path(tmp, "out.json")
  source_json <- '{"permissions": {"allow": ["Bash(ls:*)"]}}'
  apply_strategy(source_json, dest, "merge_json")

  result <- jsonlite::fromJSON(dest, simplifyVector = FALSE)
  expect_equal(result$permissions$allow, list("Bash(ls:*)"))
})

test_that("merge_json errors on non-object inputs", {
  expect_error(
    merge_json_tree(list("a", "b"), list(key = "val")),
    "Source JSON must be an object"
  )
  expect_error(
    merge_json_tree(list(key = "val"), list("a", "b")),
    "Dest JSON must be an object"
  )
})

test_that("merge_json dest wins on type mismatch", {
  source <- list(key = list("an", "array"))
  dest <- list(key = "a string")
  result <- merge_json_tree(source, dest)
  expect_equal(result$key, "a string")
})
