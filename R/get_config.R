#' @title Search for config files and return variable / value pairs as a list.
#'
#' @description
#'
#' configulaR currently supports only .env files. `get_config` will search if
#' the speficied directory and its parent a `.env` file.
#' If no file is found, a empty list is returned.
#'
#' @details
#'
#' ## Env file:
#'
#' Simply create a .env text file on your repository's root directory
#' in the form:
#'
#' \preformatted{
#' DEBUG=True
#' TEMPLATE_DEBUG=True
#' SECRET_KEY=ARANDOMSECRETKEY
#' DATABASE_URL=mysql://myuser:mypassword@myhost/mydatabase
#' PERCENTILE=90%
#' #COMMENTED=42
#' }
#'
#' @param path a path from where a config if searched for.
#' Parent directories will be evaluated if no config file is
#' found is the specified directory. If NULL, the current
#' directory will be taken as default.
#'
#' @return a list with variables / values from config file.
#' If no config file has been found, an empyt list is returned.
#'
#' @examples
#' config <- get_config()
#' config
#' @import assertthat
#' @export

get_config <- function(path = NULL) {
  if (is.null(path)) {
    path <- here::here()
  }

  assert_that(is.readable(path))

  config_file <- find_config_files(path)

  if (!is.null(config_file)) {
    if (basename(config_file) == ".env") {
      config <- load_dot_env(config_file)
    }
  } else {
    config <- list()
  }

  return(config)
}

#' Return config file path found in a directory
#' @param path The directory were config files are looking for.
#' @return the full path of the config file found.
#' If no config file are found, it returns a `NULL`.
#'
get_config_filename_from_dir <- function(path) {
  # look for all files in the current path
  for (configfile in c("settings.ini", ".env")) {
    filename <- file.path(path, configfile)
    if (file.exists(filename)) {
      return(filename)
    }
  }
}



#' Config file search
#' @param path The directory from which the config file search is initialized.
#' Look in current and root directories until finding a config file reaching
#' the primary root.
#' @return the full path of the config file found. If no config file are found,
#'  it returns a `NULL`.
#'
find_config_files <- function(path) {
  #
  parts <- unlist(stringr::str_split(path, .Platform$file.sep))
  for (i in seq(length(parts), 1)) {
    config_file <- get_config_filename_from_dir(
      do.call(file.path, as.list(parts[1:i]))
    )
    if (!is.null(config_file)) {
      return(config_file)
    }
  }
}
