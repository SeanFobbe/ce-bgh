#' Parallel conversion of PDF files to TXT
#'
#' Extracts PDF files and converts to TXT files. Parallelized. Compatible with the targets framework. 

#' @param x Character. A vector of PDF filenames.
#' @param outputdir Character. The directory to store the extracted TXT files in.

f.tar_pdf_extract <- function(x,
                              outputdir = "txt",
                              cores = parallel::detectCores()){
    
    unlink(outputdir, recursive = TRUE)
    dir.create(outputdir)

    plan(multicore,
         workers = cores)
    
    pdf_extract(x,
                outputdir = outputdir)

    files.txt <- list.files(outputdir, pattern = "\\.txt", full.names = TRUE)

    return(files.txt)
    
}
