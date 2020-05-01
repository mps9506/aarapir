#' Return Mapserver Info
#'
#' @param mapserver_url character
#'
#' @return list
#' @export
#'
service_info <- function(mapserver_url) {

  ## todo: make_request should return null and print errors
  ## should I add ... so users can specify options used by crul? eg verbose
  data <- make_request(mapserver_url,
               args = list(f="pjson"),
               verbose = TRUE)
  data$url <- mapserver_url

  data


  ### notes: should consider s3 summary
}
