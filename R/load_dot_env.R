#' Load environment variables from the specified file
#'
#' Load variables defined in the given file, as environment
#' variables.
#'
#' @description
#' The file is parsed, and line is expected to have one of the
#'  following formats:
#' \preformatted{VARIABLE=value
#' VARIABLE2="quoted value"
#' VARIABLE3='another quoted variable'
#' # Comment line
#' export EXPORTED="exported variable"
#' export EXPORTED2=another}
#'
#' @details
#' Detailed specification:
#' \itemize{
#'   \item A leading \code{export} is ignored, to keep the file
#'      compatible with Unix shells.
#'   \item No whitespace is allowed right before or after the
#'      equal sign, again, to promote compatilibity with Unix shells.
#'   \item No multi-line variables are supported currently. The
#'      file is strictly parsed line by line.
#'   \item Unlike for Unix shells, unquoted values are \emph{not}
#'      terminated by whitespace.
#'   \item Comments start with \code{#}, without any leading
#'      whitespace. You cannot mix variable definitions and
#'      comments in the same line.
#'   \item Empty lines (containing whitespace only) are ignored.
#' }
#'
#' It is suggested to keep the file in a form that is parsed the
#' same way with \code{dotenv} and \code{bash} (or other shells).
#'
#' @param fpath The path to the `.env` config file
#' @export
#'
#' @examples
#' # Load from a file
#' tmp <- tempfile()
#'
#' cat("dotenvexamplefoo=bar\n", file = tmp)
#' load_dot_env(tmp)
#'
#' # Clean up
#' unlink(tmp)
#' @import magrittr

load_dot_env <- function(fpath = ".env") {
  assert_that(is.readable(fpath))

  env <- readLines(fpath)
  env <- remove_comments(env)
  env <- remove_empty_lines(env)
  env <- parse_dot_line(env)
  env
}

parse_dot_line <- function(lines) {
  line_regex <- paste0(
    "^\\s*", # leading whitespace
    "(?<export>export\\s+)?", # export, if given
    "(?<key>[^=^\\s]+)", # variable name
    "\\s*=\\s*", # equals sign
    "(?<q>[\'\"]?)", # quote if present
    "(?<value>.*)", # value
    "(\\k<q>)", # the same quote again
    "\\s*", # trailing whitespace
    "$"
  ) # end of line

  extr <- stringr::str_match(lines, line_regex)
  extr <- extr[, c(3, 5), drop = FALSE]
  res <- as.list(extr[, 2])
  names(res) <- extr[, 1]
  res
}
