#' @title Convert categorical representations of true/false values to a logical
#'
#' @description Allow the convertion of logical related data to actual Boolean
#'
#' @param x a vector of boolean compatible values.
#'
#' @return a vector of boolean
#'
#' @examples
#' to_logical(c("yes", "no"))
#' @export

to_logical <- function(x) {
  logical_cat <- data.frame(
    cat = c(
      "y", "yes", "t", "true", "1", "n", "no", "f", "false", "0", "on",
      "off", ""
    ),
    value = c(
      TRUE, TRUE, TRUE, TRUE, TRUE, FALSE, FALSE, FALSE, FALSE, FALSE,
      TRUE, FALSE, FALSE
    )
  )

  logical_cat$value[match(tolower(x), logical_cat$cat)]
}
