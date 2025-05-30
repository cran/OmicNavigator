#' Summarize elements of OmicNavigator study
#'
#' Displays a tree-like summary of the elements that have been added to an
#' OmicNavigator study.
#'
#' @param object OmicNavigator study object (class \code{onStudy})
#' @param elements Subset the output to only include specific elements of the
#'   study, e.g. \code{c("results", "enrichments")}
#' @param ... Currently unused
#'
#' @return Invisibly returns the original \code{onStudy} object
#'
#' @export
summary.onStudy <- function(object, elements = NULL, ...) {
  if (!is.null(elements) && is.character(elements)) {
    object <- object[elements]
  }
  display(object)
  return(invisible(object))
}

display <- function(x, indent = "") {
  for (i in seq_along(x)) {
    if (isEmpty(x[[i]])) {
      next
    } else if (is.data.frame(x[[i]])) {
      writeLines(displayDataFrame(x[[i]], names(x)[i], indent = indent))
    } else if (is.list(x[[i]])) {
      writeLines(displayList(x[[i]], names(x)[i], indent = indent))
      display(x[[i]], indent = paste0(indent, "  "))
    } else if (is.character(x[[i]])) {
      if (length(x[[i]]) == 1) {
        writeLines(displayCharacter(x[[i]], names(x)[i], indent = indent))
      }
    }
  }
}

displayDataFrame <- function(x, name, indent = "") {
  sprintf("%so-%s: %dx%d", indent, name, nrow(x), ncol(x))
}

displayList <- function(x, name, indent = "") {
  sprintf("%s|-%s (%d)", indent, name, length(x))
}

displayCharacter <- function(x, name, indent = "") {
  sprintf("%so-%s: %s", indent, name, x)
}
