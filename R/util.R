

## input a vector, start position, and total number of records (n) that can be returned per call
## returns a vector of the first and last vector values spaced n apart
nth_element <- function(vector, starting_position, n) {
  vector[seq(starting_position, length(vector), n)]
}


#' Modified percent encode
#' @param query character string you want to encode.
#'
#' @return character string
#' @export
#' @keywords internal
p_encode_m <- function(query) {

  query <- percent_encode(query)

  return(query)
}

## percent_encode is slightly modified version
## of RCurl::curlPercentEncode
## mainly does percent encode, but replaces
## spaces with "+" so we can insert query
## in format required by arcgis online
percent_encode <-  function(x,
                            amp = TRUE,
                            post.amp = FALSE) {
  ## modified named vector used to
  ## encode reserved values
  codes <- c(
    '%' = "%25",  # this has to go first.
    '!' = "%21",
    '*' = "%2A",
    '"' = "%22",
    '\'' = "%27",
    '(' = "%28",
    ')' = "%29",
    ';' = "%3B",
    ':' = "%3A",
    '@' = "%40",
    '&' = "%26",
    '=' = "%3D",
    '+' = "%2B",
    '$' = "%24",
    ',' = "%2C",
    '/' = "%2F",
    '?' = "%3F",
    '#' = "%23",
    '[' = "%5B",
    ']' = "%5D",
    '{' = "%7B",
    '}' = "%7D",
    ' ' = '+',
    '\r' = '%0D',
    '\n' = '%0A')

  if(!amp) {
    i = match("&", names(codes))
    if(!is.na(i))
      codes = codes[ - i ]
  }

  for(i in seq(along = codes)) {
    x = gsub(names(codes)[i], codes[i], x, fixed = TRUE)
  }

  if(post.amp)
    x = gsub("%", "%25", x, fixed = TRUE)
  x
}
