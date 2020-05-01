

## input a vector, start position, and total number of records (n) that can be returned per call
## returns a vector of the first and last vector values spaced n apart
nth_element <- function(vector, starting_position, n) {
  vector[seq(starting_position, length(vector), n)]
}


