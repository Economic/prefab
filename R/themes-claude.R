#' Claude Code configuration theme for R analysis projects
#'
#' Creates a theme that deploys Claude Code agent settings and rules for an
#' R analysis project.
#'
#' @return A `prefab_theme` object.
#' @export
#'
#' @examples
#' claude_r_analysis()
claude_r_analysis <- function() {
  from_prefab <- from_package("prefab")
  new_theme(
    from_prefab(
      "claude/settings.json",
      ".claude/settings.json",
      strategy = "merge_json"
    ),
    from_prefab("claude/rules/r_analysis.md", ".claude/rules/r_analysis.md"),
    step_text(gitignore_lines, ".gitignore", strategy = "union")
  )
}

#' Claude Code configuration theme for R targets projects
#'
#' Creates a theme that deploys Claude Code agent settings and rules for an
#' R targets project.
#'
#' @return A `prefab_theme` object.
#' @export
#'
#' @examples
#' claude_r_targets()
claude_r_targets <- function() {
  from_prefab <- from_package("prefab")
  new_theme(
    from_prefab(
      "claude/settings.json",
      ".claude/settings.json",
      strategy = "merge_json"
    ),
    from_prefab("claude/rules/r_targets.md", ".claude/rules/r_targets.md"),
    from_prefab(
      "claude/rules/r_analysis.md",
      ".claude/rules/r_analysis.md",
      strategy = "skip"
    ),
    step_text(gitignore_lines, ".gitignore", strategy = "union")
  )
}

# Internal Rbuildignore lines for R package themes
rbuildignore_lines <- c("^\\.claude$", "^CLAUDE\\.md$")

#' Claude Code configuration theme for R packages
#'
#' Creates a theme that deploys Claude Code agent settings and rules for an
#' R package.
#'
#' @return A `prefab_theme` object.
#' @export
#'
#' @examples
#' claude_r_package()
claude_r_package <- function() {
  from_prefab <- from_package("prefab")
  new_theme(
    from_prefab(
      "claude/settings.json",
      ".claude/settings.json",
      strategy = "merge_json"
    ),
    from_prefab("claude/rules/r_package.md", ".claude/rules/r_package.md"),
    step_text(gitignore_lines, ".gitignore", strategy = "union"),
    step_text(rbuildignore_lines, ".Rbuildignore", strategy = "union")
  )
}
