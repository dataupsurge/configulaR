#' @title Parse config file and remove comment lines
#'
#' @param lines A list of config file lines.
#'
#' @return A list of config file lines where comment lines have been filtered
#' out.
#' @importFrom stringr str_subset

remove_comments <- function(lines) {
  stringr::str_subset(lines, "^#", negate = TRUE)
}


#' @title Parse config file and remove empty lines
#'
#' @param lines A list of config file lines.
#'
#' @return A list of config file lines where empty lines have been filtered out.
#' @importFrom stringr str_subset

remove_empty_lines <- function(lines) {
  stringr::str_subset(lines, "^\\s*$", negate = TRUE)
}


#' @title Test if object if of class _UNDEFINED
#'
#' @param x an object.
#'
#' @return a boolean

is_undefined <- function(x) {
  class <- attr(x, "class")
  if (is.null(class)) {
    return(FALSE)
  }
  class == "UNDEFINED_"
}


#' Generate a random string of specified length
#' @param string_length Integer, length of the string to generate.
#' @param replace Bollean, Use replace in the sampling procedure.
#'
#' @return A random string.

random_string <- function(string_length = 6, replace = TRUE) {
  paste(
    sample(
      c(letters, LETTERS, as.character(0:9)),
      string_length,
      replace = replace
    ),
    collapse = ""
  )
}
