
#' Make a request
#'
#' Right now this works with json files
#'
#' @param url character, the base url
#' @param path character, anything after the url
#' @param args list, named query list
#' @param parse_json logical, probably \code{TRUE}
#' @param ... curl options
#'
#' @return If \code{parse_json = TRUE} returns a list, else returns unparsed text.
#' @export
#' @import crul
#' @importFrom  jsonlite fromJSON
#' @keywords internal
make_request <- function(url,
                         path = NULL,
                         args = list(),
                         parse_json = TRUE,
                         ...) {
  # create a HttpClient object, defining the url
  cli <- crul::HttpClient$new(url = url,
                              opts = list(...))
  # do a GET request
  res <- cli$get(path = path, query = args)

  message(res$url)


  # check to see if request failed or succeeded
  # - if succeeds this will return nothing and proceeds to next step
  res$raise_for_status()
  # parse response to plain text (JSON in this case) - most likely you'll
  # want UTF-8 encoding
  txt <- res$parse("UTF-8")
  # parse the JSON to an R list
  if (parse_json == TRUE) {
    jsonlite::fromJSON(txt)
  }
  else {
    return(txt)
  }
}
