#' Download large number of files
#'
#' Downloads a large number of files with a wide range of options, including custom sleep times, custom retries, custom sleep during retries, timeout and a debug toggle for testing a reduced number of files. Will check the filenames in the destination folder to ensure that only files scheduled to be downloaded are present. Will skip already downloaded files.


#' @param url Character. A vector of URLS.
#' @param filename Character. A vector of filenames.
#' @param dir Character. The destination directory. Will be created if not already present.
#' @param sleep.min Positive Integer. Minimum number of seconds to randomly sleep between requests.
#' @param sleep.max Positive Integer. Maximum number of seconds to randomly sleep between requests.
#' @param retries Positive Integer. Number of retries for entire download set.
#' @param retry.sleep.min Positive Integer. Minimum number of seconds to randomly sleep between requests in retry mode.
#' @param retry.sleep.max Positive Integer. Maximum number of seconds to randomly sleep between requests in retry mode.
#' @param timeout Positive Integer. Number of seconds for a download to timeout, even active ongoing ones.
#' @param debug.toggle Logical. Whether to activate debugging mode.
#' @param debug.files Positive Integer. The number of files to download during debugging mode. Default is 500.

#' @return Character. A vector of the downloaded file names.


f.download <- function(url,
                       filename,
                       dir,
                       sleep.min = 0,
                       sleep.max = 0.1,
                       retries = 3,
                       retry.sleep.min = 2,
                       retry.sleep.max = 5,
                       timeout = 300,
                       debug.toggle = FALSE,
                       debug.files = 500){
    
    ## Test for equality of length
    if(length(url) != length(filename)){

        stop("Length of arguments url and filename is not equal.")
        
    }

    ## Set timeout for downloads
    options(timeout = timeout)

    ## [Debugging Mode] Reduce download scope
    if (debug.toggle == TRUE){

        sample.index <- sample(length(url), debug.files)

        url <- url[sample.index]
        filename <- filename[sample.index]

    }

    ## Create folder
    dir.create(dir, showWarnings = FALSE)

    ## Clean folder: Only files included in 'filename' may be present
    files.all <- list.files(dir, full.names = TRUE)
    delete <- setdiff(files.all, file.path(dir, filename))
    unlink(delete)

    ## Exclude already downloaded files
    files.present <- list.files(dir)
    filename.todo <- setdiff(filename, files.present)
    url.todo  <- url[filename %in% filename.todo]
    
    
    ## Download: First Try
    for (i in sample(length(url.todo))){
        tryCatch({download.file(url = url.todo[i],
                                destfile = file.path(dir,
                                                     filename.todo[i]))
        },
        error = function(cond) {
            return(NA)}
        )
        
        Sys.sleep(runif(1, sleep.min, sleep.max))
    }

    


    ## Download: Retries

    for(i in 1:retries){

        ## Missing files
        files.present <- list.files(dir)
        filename.missing <- setdiff(filename, files.present)
        url.missing  <- url[filename %in% filename.missing]

        if(length(filename.missing) > 0){
            
            for (i in 1:length(filename.missing)){
                
                response <- GET(url.missing[i])
                
                Sys.sleep(runif(1, 0.25, 0.75))
                
                if (response$status_code == 200){
                    tryCatch({download.file(url = url.missing[i],
                                            destfile = file.path(dir,
                                                                 filename.missing[i]))
                    },
                    error = function(cond) {
                        return(NA)}
                    )     
                }else{
                    message("Response code is not 200.")  
                }
                
                Sys.sleep(runif(1, retry.sleep.min, retry.sleep.max))
            } 
        }
        
    }

    if(length(filename.missing) > 0){

        warning(paste("Missing file:", filename.missing, collapse = "\n"))
        
    }


    ## Final File Count
    files.all <- list.files(dir, full.names = TRUE)

    message(paste("Downloaded", length(files.all), "of", length(filename), "files."))

    return(files.all)
    
}
