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
                           "ARsVollz", "ARVS", "ARZ", "ZR(Ü)", "ARVZ")

    regz.numbersenate <- gsub("\\(",
                                    " \\*\\\\\\(",
                                    regz.numbersenate)

    regz.numbersenate <- gsub("\\)",
                                    "\\\\\\)",
                                    regz.numbersenate)
    
    
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


    ## Combine Tables
    dt <- rbind(dt.az.numbersenate,
                dt.az.lettersenate)

    ## Remove non-citations
    dt <- dt[!is.na(target)]
    
    ## Clean whitespace
    dt$source <- gsub("\\s+", " ", dt$source)
    dt$target <- gsub("\\s+", " ", dt$target)

    dt$source <- trimws(dt$source)
    dt$target <- trimws(dt$target)

    dt$source <- gsub(" \\(", "\\(", dt$source)
    dt$target <- gsub(" \\(", "\\(", dt$target)

    ## Remove self-citations    
    dt <- dt[!(dt$source == dt$target)]

    
    ## Create Graph Object
    g  <- igraph::graph_from_data_frame(dt,
                                        directed = TRUE)

    
    ## Convert Parallel Edges to Weights
    igraph::E(g)$weight <- 1
    g <- igraph::simplify(g, edge.attr.comb = list(weight = "sum"))


    ## Extract Senate
    g.names <- igraph::vertex_attr(g, "name")
    
    g.senat <- stringi::stri_extract_all(g.names,
                                         regex = "^[0-6IXV]{1,4}a?")
    g.senat <- unlist(g.senat)

    stopifnot(length(g.names) == length(g.senat))
    

    ## Extract Registerzeichen

    g.regz <- stringi::stri_extract_all(g.names,
                                        regex = " ([A-Za-z\\(\\)]+) ")

    g.regz <- gsub("[IVXa-d0-9 ]*([A-Za-z\\(\\)]+) *[0-9]+/[0-9]+", "\\1", g.names)

    g.regz <- unlist(g.regz)

    stopifnot(length(g.names) == length(g.regz))
    
    ## Set Vertex Attributes
    g <- igraph::set_vertex_attr(g, "registerzeichen", index = igraph::V(g), g.regz)
    g <- igraph::set_vertex_attr(g, "senat", index = igraph::V(g), g.senat)


    ## Delete incorrect Registerzeichen Nodes
    regz.final <- igraph::vertex_attr(g, "registerzeichen")
    regz.correct <- regz.final %in% az.brd$zeichen_original
    g <- igraph::delete_vertices(g, !regz.correct)

    if (sum(!regz.correct) > 0){
        warning(paste("Warnung!",
                      sum(!regz.correct),
                      "Nodes entfernt, weil Registerzeichen fehlerhaft."))

    }

    
  
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

