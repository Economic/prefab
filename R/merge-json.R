#' Recursive JSON tree merge
#'
#' Merges two parsed JSON trees (R lists from
#' `jsonlite::fromJSON(simplifyVector = FALSE)`).
#'
#' @param source_list Named list (parsed JSON object) to merge from.
#' @param dest_list Named list (parsed JSON object) to merge into.
#' @return Merged named list.
#' @noRd
merge_json_tree <- function(source_list, dest_list) {
  if (!is_json_object(source_list)) {
    cli::cli_abort(
      "Source JSON must be an object (named list), not an array or scalar."
    )
  }
  if (!is_json_object(dest_list)) {
    cli::cli_abort(
      "Dest JSON must be an object (named list), not an array or scalar."
    )
  }

  merged <- dest_list

  for (key in names(source_list)) {
    src_val <- source_list[[key]]
    if (is.null(merged[[key]])) {
      # Key only in source: take it
      merged[[key]] <- src_val
    } else {
      dest_val <- merged[[key]]
      src_type <- json_type(src_val)
      dest_type <- json_type(dest_val)

      if (src_type != dest_type) {
        # Type mismatch: dest wins
        next
      }

      if (src_type == "object") {
        merged[[key]] <- merge_json_tree(src_val, dest_val)
      } else if (src_type == "array") {
        merged[[key]] <- merge_json_arrays(src_val, dest_val)
      } else {
        # Scalar collision: dest wins
        next
      }
    }
  }

  merged
}

#' Classify a parsed JSON value
#' @noRd
json_type <- function(x) {
  if (is.list(x)) {
    if (is.null(names(x)) || length(x) == 0 && !is_json_object(x)) {
      "array"
    } else {
      "object"
    }
  } else {
    "scalar"
  }
}

#' Check if a value is a JSON object (named list)
#' @noRd
is_json_object <- function(x) {
  is.list(x) && !is.null(names(x))
}

#' Check if all elements of an array are objects with a "matcher" field
#' @noRd
is_matcher_array <- function(arr) {
  if (length(arr) == 0) {
    return(TRUE)
  }
  all(vapply(
    arr,
    function(el) {
      is_json_object(el) && "matcher" %in% names(el)
    },
    logical(1)
  ))
}

#' Merge two JSON arrays via union semantics
#' @noRd
merge_json_arrays <- function(src_arr, dest_arr) {
  if (is_matcher_array(src_arr) && is_matcher_array(dest_arr)) {
    merge_by_matcher(src_arr, dest_arr)
  } else {
    merge_by_value(src_arr, dest_arr)
  }
}

#' Merge arrays by value using identical()
#' @noRd
merge_by_value <- function(src_arr, dest_arr) {
  result <- dest_arr
  for (src_el in src_arr) {
    already_present <- FALSE
    for (dest_el in result) {
      if (identical(src_el, dest_el)) {
        already_present <- TRUE
        break
      }
    }
    if (!already_present) {
      result <- c(result, list(src_el))
    }
  }
  result
}

#' Merge arrays by matcher field
#' @noRd
merge_by_matcher <- function(src_arr, dest_arr) {
  result <- dest_arr

  # Build index of dest matchers

  dest_matchers <- vapply(result, function(el) el$matcher, character(1))

  for (src_el in src_arr) {
    src_matcher <- src_el$matcher
    match_idx <- match(src_matcher, dest_matchers)

    if (is.na(match_idx)) {
      # New entry: append
      result <- c(result, list(src_el))
      dest_matchers <- c(dest_matchers, src_matcher)
    } else {
      # Collision: recursively merge as objects
      result[[match_idx]] <- merge_json_tree(src_el, result[[match_idx]])
    }
  }

  result
}
