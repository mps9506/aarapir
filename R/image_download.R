#' Download Image Raster for ArcGIS Online
#'
#' @param webserver list output from \code{service_info}
#' @param bbox \code{NULL} or named list formatted like: \code{list(xmin = -123,
#'   ymin = -123, xmax = 123, ymax = 123)}. If \code{NULL}, will default to the
#'   intial extent specified in the source file.
#' @param bbox_sr \code{NULL}, default; or 4-digit wkid as character. If
#'   \code{NULL}, will default to the spatial reference in the source file.
#' @param size character, defaults to "600,800"; change to what you need.
#' @param verbose Logical, defaults to \code{FALSE}
#'
#' @return RasterBrick
#' @export
#'
image_download <- function(webserver,
                           bbox = NULL,
                           bbox_sr = NULL,
                           size = "600,800",
                           verbose = FALSE) {

  ## Check that the webserver supports exporting raster images
  capabilities <- strsplit(webserver$capabilities, ",")[[1]]

  if(!("Image" %in% capabilities)) {
    stop("The webserver does not support exporting raster images")
  }

  ## Generate the query url
  url <- paste0(webserver$url, "/exportImage")

  ## Generate bounding box from the default intial extent
  if (is.null(bbox)) {
    extent <- webserver$initialExtent
    bbox <- paste(extent$xmin,
                  extent$ymin,
                  extent$xmax,
                  extent$ymax,
                  sep = ",")
  }
  else {

    ## Check that bbox format is correct
    if (!all(c("xmin", "ymin", "ymax", "xmax") %in% names(bbox))) {
      stop("argument bbox must be NULL or a nammed list, for example: list(xmin = -123, ymin = -123, xmax = 123, ymax = 123)")
    }
    bbox <- paste(bbox$xmin,
                  bbox$ymin,
                  bbox$xmax,
                  bbox$ymax,
                  sep = ",")
  }

  ## Generate the bounding box spatial ref
  if (is.null(bbox_sr)) {
    bbox_sr <- webserver$initialExtent$spatialReference$latestWkid
  }

  else {
    ## I don't know how to check against WKIDs, might be in geos somewhere
    ## not sure if it is worth it though?
    ## consider this a placeholder to add the check
    bbox_sr <- bbox_sr
  }


  data <- make_request(url,
                       args = list(bbox = bbox,
                                   bboxSR = bbox_sr,
                                   size = size,
                                   format = "tiff",
                                   f = "image"),
                       parse_json = FALSE,
                       img = TRUE,
                       verbose = verbose)
  return(data)
}
