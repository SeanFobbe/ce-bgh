#' Read TXT files and remove hyphens
#'
#' Reads a vector of TXT files, converts to data.table and removes hyphens.

#' @param x Character. A vector of TXT files.
#' @param docvarnames The variables names encoded in the TXT filenames. 
#'
#' @return Data.table containing the name of the TXT files, their content and the filename metadata.



f.readtext <- function(x,
                       docvarnames){


    ## Read TXT files with filename metadata    
    dt <- readtext(x,
                   docvarsfrom = "filenames", 
                   docvarnames = docvarnames,
                   dvsep = "_", 
                   encoding = "UTF-8")


    ## Coerce to Data.table
    setDT(dt)

    ## Remove Hyphenation
    dt[, text := lapply(.(text), f.hyphen.remove)]

    return(dt)

    
}

