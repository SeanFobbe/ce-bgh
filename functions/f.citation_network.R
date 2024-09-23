#' f.citation_network  - EXPERIMENTELL!
#'
#' Zitationsnetzwerk für den BGH erstellen.
#'
#' @param dt.bgh.final Data.table. Der finale BGH-Datensatz.
#' @param az.brd Ein data.frame oder data.table mit dem Datensatz "Seán Fobbe (2021). Aktenzeichen der Bundesrepublik Deutschland (AZ-BRD). Version 1.0.1. Zenodo. DOI: 10.5281/zenodo.4569564."
#' @param multictore Logical. Parallelisierung aktivieren.
#' @param cores Integer. Anzahl cores für Parallelisierung.
#'
#' @return Igraph object. Alle Zitate zwischen Aktenzeichen in den Entscheidungen des BGH.




f.citation_network <- function(dt.bgh.final,
                               az.brd){

    
    ## Create Number Senate REGEX

    regex.senat <-  paste0("(",
                           paste0(c(1:6, as.character(utils::as.roman(1:15))),
                                  collapse = "|"),
                           ")")

    ## Create Registerzeichen REGEX for Number Senates

    regz.numbersenate <- c("BGs", "ZR", "StR", "ARs", "ZB", "ZA",
                           "ARsVollz", "ARVS", "ARZ", "ZRÜ", "ARVZ")
    
    regex.regz.numbersenate <- paste0("(", paste0(regz.numbersenate,
                                              collapse = "|"),
                                  ")")
    
    ## Create FULL Number Senate AZ REGEX

    regex.az.numbersenate <- paste0(regex.senat, # Spruchkörper
                                "\\s*",
                                regex.regz.numbersenate, # Registerzeichen
                                "\\s*",
                                "[0-9]{1,5}", # Eingangsnummer
                                "/",
                                "[0-9]{2}" # Eingangsjahr
                                )


    ## Create Registerzeichen REGEX for Letter Senates

    regz.lettersenate <- setdiff(az.brd[stelle == "BGH"]$zeichen_original,
                                 regz.numbersenate)

    regex.regz.lettersenate <- paste0(regz.lettersenate,
                                      collapse = "|")
    
    regex.regz.lettersenate <- gsub("\\(",
                                  " \\*\\\\\\(",
                                  regex.regz.lettersenate)

    regex.regz.lettersenate <- gsub("\\)",
                                  "\\\\\\)",
                                  regex.regz.lettersenate)

    
    regex.regz.lettersenate <- paste0("(", regex.regz.lettersenate, ")")
    
    
    ## Create FULL Letter Senate AZ REGEX

    regex.az.lettersenate <- paste0(regex.regz.lettersenate, # Registerzeichen
                                    "\\s*",
                                    "[0-9]{1,5}", # Eingangsnummer
                                    "/",
                                    "[0-9]{2}" # Eingangsjahr
                                    )
    



    
    ## begin <- Sys.time()

    target.az.numbersenate <- stringi::stri_extract_all(dt.bgh.final$text,
                                                        regex = regex.az.numbersenate)
    
    target.az.lettersenate <- stringi::stri_extract_all(dt.bgh.final$text,
                                                        regex = regex.az.lettersenate)
    

    
    ## end <- Sys.time()
    ## end-begin
    

    ## Define source Aktenzeichen
    source <- dt.bgh.final$aktenzeichen
    
    ## [Number Senates] Combine source Aktenzeichen and target Aktenzeichen 
    bind <- mapply(cbind, source, target.az.numbersenate)
    bind <- lapply(bind, as.data.table)
    dt.az.numbersenate <- rbindlist(bind)
    setnames(dt.az.numbersenate, new = c("source", "target"))

    ## [Letter Senates] Combine source Aktenzeichen and target Aktenzeichen 
    bind <- mapply(cbind, source, target.az.lettersenate)
    bind <- lapply(bind, as.data.table)
    dt.az.lettersenate <- rbindlist(bind)
    setnames(dt.az.lettersenate, new = c("source", "target"))


    ## Create Edgelist
    
    source <- dt.bgh.final$aktenzeichen
    
    bind <- mapply(cbind, source, target)

    bind2 <- lapply(bind, as.data.table)

    dt <- rbindlist(bind2)

    setnames(dt, new = c("source", "target"))


    dt$target <- gsub(" \\(",
                      "\\(",
                      dt$target)


    ## Remove self-citations    
    dt <- dt[!(dt$source == dt$target)]



    ## Create Graph
    g  <- igraph::graph.data.frame(dt, directed = TRUE)



    
    return(g)


}




#' Debugging

## library(data.table)
## library(stringi)
## library(igraph)
## tar_load(dt.bgh.final)
## tar_load(az.brd)
        



## Extract Citations

## begin <- Sys.time()

## target <- stringi::stri_extract_all(dt.bgh.final$text,
##                                     regex = paste0("[0-9XIVa-z]{0,5}", # Spruchkörper
##                                                    " *",
##                                                    registerzeichen.regex, # Registerzeichen
##                                                    " ",
##                                                    "[0-9]+", # Eingangsnummer
##                                                    "/",
##                                                    "[0-9]{2}" # Eingangsjahr
##                                                    ))

## target <- lapply(target, trimws)

## end <- Sys.time()
## end-begin





## png("output/test1.png", width = 12, height = 12, res = 300, units = "in")
## ggraph(g, layout = "kk") + 
##     geom_edge_diagonal(colour = "grey")+
##     geom_node_point()+
##     theme_void()
## dev.off()




    ## stringi::stri_extract_all(dt.bgh.final[1]$text,
    ##                                     regex = paste0("[0-9XIVa-z]{0,5}", # Spruchkörper
    ##                                                    " *",
    ##                                                    "[\\(\\)ÜA-Za-z-]+", # Registerzeichen
    ##                                                    " ",
    ##                                                    "[0-9]+", # Eingangsnummer
    ##                                                    "/",
    ##                                                    "[0-9]{2}" # Eingangsjahr
    ##                                                    ))

