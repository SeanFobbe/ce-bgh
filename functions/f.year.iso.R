#'## f.year.iso: Tranform Double-Digit Years to ISO Year Format
#' This function transforms double-digit years (YY) to four-digit years as per the ISO standard (YYYY). It is based on the assumption that years above a certain boundary belong to the 20th century and years at or below that boundary belong to the 21st century.
#'
#'
#'
#' @param inputyear A vector of two-digit years.
#' @param boundary The boundary year. Default is 50 (=1950). 


f.year.iso <- function(inputyear, boundary=50){
    ifelse(inputyear > boundary,
           1900+inputyear,
           2000+inputyear)
}
