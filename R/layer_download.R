#' Download layer from ArcGIS online
#'
#' @param layer_info output from \code{layer_info}
#' @param outfields character or \code{NULL} (default). Quoted text with comma
#'   sperated field names. The default value of \code{NULL} will make the
#'   function return all the fields.
#' @param verbose logical, defaults to \code{FALSE}. Passed to \code{crul::HttpClient$new()}.
#'
#' @return sf
#' @importFrom tibble tibble
#' @importFrom purrr map2
#' @importFrom dplyr mutate
#' @importFrom sf st_read
#' @export
#'
layer_download <- function(layer_info,
                           outfields = NULL,
                           verbose = FALSE) {

  ## Generate the query url
  url <- paste0(layer_info$url, "/query")

  ## Check if the layer allows query
  ## this is the only way to download data
  capabilities <- layer_info$capabilities
  capabilities <- strsplit(capabilities, ",")[[1]]

  if(!("Query" %in% capabilities)) {
    stop("The feature layer cannot be exported")
  }

  ## Check if user specified outfield (fields returned by query)
  ## if NULL (default), query all the fields
  ## if user specified, use the user specified fields
  if(is.null(outfields)) {
    outfields <- layer_info$fields
    outfields <- paste0(outfields$name, collapse = ",")
  }

  ## First query should return count
  ## if count is > layer_info$maxRecordCount
  ## then we need to make multiple queries broken up
  ## by the count/maxRecordCount
  summary_n <- make_request(url,
                            args = list(where = "1=1",
                                        outFields = outfields,
                                        returnCountOnly = "true",
                                        f = "json"),
                            verbose = FALSE)
  summary_n <- summary_n$count
  max_rc <- layer_info$maxRecordCount
  message(paste("Number of target records: ", summary_n))

  if(summary_n < max_rc) {

    ## This request will return everything
    data <- make_request(url,
                         args = list(where = "1=1",
                                     outFields = outfields,
                                     returnGeometry = "true",
                                     f = "geojson"),
                         parse_json = FALSE,
                         verbose = verbose)
    data <- sf::st_read(data)
  }

  ## Need to map/loop queries.
  else {

    ## This will query the object id field between 1 and
    ## max number of returnable records, then max number +1
    ## through max number, and so forth.

    ## This request returns the objectid field name and all the objectid values
    ## will use this to create a dataframe of object id values to query between
    j <- make_request(url,
                      args = list(where = "1=1",
                                  returnIdsOnly = "true",
                                  f = "json"))
    id_field <- j$objectIdFieldName
    id_list <- j$objectIds
    id_list <- sort(id_list)
    num_rec <- length(id_list)

    from <- nth_element(id_list, 1, max_rc)
    to <- nth_element(id_list, max_rc,  max_rc)
    to_max <- id_list[num_rec]
    to <- append(to, to_max)
    message(paste("Number of target records: ", num_rec))

    ## Setup a dataframe with the columns of object ids to query from and to
    dat <- tibble::tibble(from = from,
                           to = to)
    dat <- dat %>%
      dplyr::mutate(results = purrr::map2(.x = from,
                                   .y = to,
                                   ~{
                                     ## the queries use percent encoding,
                                     ## except spaces are "+"
                                     ## can use a modified version of RCurl curlPercentEncode to
                                     ## enode the query then wrap with I()
                                     #q <- paste0(id_field, "+>%3D+", .x, "+AND+", id_field, "+<%3D+", .y)
                                     q <- paste0(id_field, " >= ", .x, " AND ",
                                                 id_field, " <= ", .y)
                                     q <- p_encode_m(q)
                                     make_request(url,
                                                  args = list(where = I(q), ## use I() because we don't want +,>, or < encoded
                                                              outFields = outfields,
                                                              f = "geojson"),
                                                  parse_json = FALSE)
                                     }))

    for (i in 1:length(dat$results)) {
      if(i == 1) {
        out <- sf::st_read(dat$results[[i]])
      }
      else {
        temp_out <- sf::st_read(dat$results[[i]])
        data <- data %>%
          rbind(temp_out)
      }
    }
  }


  return(data)

}
