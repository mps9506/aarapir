#' Return layer information
#'
#' @param mapservice object output from service_info
#' @param layer_id numeric, specifying the layer id.
#'
#' @return list
#' @export
#'
layer_info <- function(mapservice, layer_id) {

  url <- paste0(mapservice$url,
                "/",
                layer_id)

  data <- make_request(url,
                       args = list(f="pjson"),
                       verbose = TRUE)

  data$url <- url

  return(data)
}
