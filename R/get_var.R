#' @title Retrive the value of the variable
#'
#' @description Get a variable from, in order of priority, environment
#' variable, .env or settings.ini, or default values. Data type can be
#' cast to boolean or integer.
#'
#' @param config an object returned by the \code{init_config} function.
#' If NULL, the config will be evaluated from the path argument.
#' @param var_name the variable of interest
#' @param path the path from where config files are searched for. If NULL,the
#' current directory will be considered as default.
#' @param default a default value
#' @param cast Either a function or a type of cast. Currently implemented
#' options are `integer`,  `boolean` or `float`.
#'
#' @return The value associated to the config variable. The type depends on
#' the cast argument. Default is string.
#'
#' @examples
#' config <- get_config()
#' get_var(config, "test", default = "yes", cast = "bool")
#' @import assertthat
#' @export

get_var <- function(config = NULL,
                    var_name = NULL,
                    path = NULL,
                    default = structure("UNDEFINED_", class = "UNDEFINED_"),
                    cast = NULL) {
  assert_that(is.scalar(var_name))
  if (!is_undefined(default)) {
    assert_that(is.scalar(default) | is.null(default))
  }
  if (!is.null(cast)) {
    assert_that(is.scalar(cast))
  }
  if (!is.null(config) && !is.null(path)) {
    stop("Either config or path must be not NULL.")
  }

  if (is.null(config)) {
    config <- get_config(path = path)
  }

  env_var <- Sys.getenv()

  if (var_name %in% names(env_var)) {
    variable <- env_var[[var_name]]
  } else {
    variable <- config[[var_name]] %>%
      unlist() %>%
      unname()
  }


  if (is.null(variable) && !is_undefined(default)) {
    variable <- default
  }

  if (is.null(variable)) {
    stop(paste(
      "UndefinedValueError:",
      variable,
      "not found. Declare it as envvar or define a default value."
    ))
  }

  if (!is.null(cast)) {
    return(cast_as(variable, cast))
  }

  return(variable)
}

#' Helper function to cast data from keyword of function
#'
#' @param variable String to be casted
#' @param cast Casting function or keyword
#'
#' @return casted variable

cast_as <- function(variable, cast) {
  if (is.function(cast)) {
    variable <- variable %>% cast()
  } else if (cast %in% c("bool", "boolean", "logical")) {
    variable <- variable %>% to_logical()
  } else if (cast %in% c("int", "integer")) {
    variable <- variable %>% as.integer()
  } else if (cast %in% c("float", "numeric")) {
    variable <- variable %>% as.numeric()
  } else if (cast %in% c("str", "string", "character")) {
  } else {
    stop("TypeError: Inconsistent cast argument")
  }

  if (any(is.na(variable))) {
    stop("TypeError: Error during cast step")
  }

  variable
}
