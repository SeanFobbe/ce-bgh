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
                               az.brd,
                               multicore = TRUE,
                               cores = parallel::detectCores()){


    
    ## Create Registerzeichen REGEX

    registerzeichen.bgh <- paste0(az.brd[stelle == "BGH"]$zeichen_original, collapse = "|")

    registerzeichen.regex <- gsub("\\(",
                                  " \\*\\\\\\(",
                                  registerzeichen.bgh)

    registerzeichen.regex.raw <- gsub("\\)",
                                  "\\\\\\)",
                                  registerzeichen.regex)

    registerzeichen.regex <- paste0("(", registerzeichen.regex.raw, ")")



    ## Parallel Settings

    if(multicore == TRUE){

        plan("multicore",
             workers = cores)
        
    }else{

        plan("sequential")

    }

    
    
    ## Extract Citations: Future
    
    ##    begin <- Sys.time()

    
    target <- future.apply::future_lapply(dt.bgh.final$text,
                                          f.extract_aktenzeichen,
                                          future.seed = TRUE)



    ##   end <- Sys.time()
    ##  end-begin


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


    ## Convert Parallel Edges to Weights
    
    igraph::E(g)$weight <- 1
    g <- igraph::simplify(g, edge.attr.comb = list(weight = "sum"))


    ## Extract Senate and Registerzeichen
    
    g.names <- attr(igraph::V(g), "names")
    g.regz <- gsub("[IVXa-d0-9 ]*([A-Za-z\\(\\)]+) *[0-9]+/[0-9]+", "\\1", g.names)
    g.senat <- gsub("([IVXa-d0-9]*) *([A-Za-z\\(\\)]+) *[0-9]+/[0-9]+", "\\1", g.names)

    ## Set Vertex Attributes
    g <- igraph::set_vertex_attr(g, "registerzeichen", index = igraph::V(g), g.regz)
    g <- igraph::set_vertex_attr(g, "senat", index = igraph::V(g), g.senat)

    
    
    return(g)


}






f.extract_aktenzeichen <- function(x){

    list <- stringi::stri_extract_all(x,
                                      regex = paste0("[0-9XIVa-z]{0,5}", # Spruchkörper
                                                     " *",
                                                     registerzeichen.regex, # Registerzeichen
                                                     " ",
                                                     "[0-9]+", # Eingangsnummer
                                                     "/",
                                                     "[0-9]{2}" # Eingangsjahr
                                                     ))

    vec <- list[[1]]
    vec <- trimws(vec)

    return(vec)
}





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




#' Debugging

## tar_load(dt.bgh.final)
## tar_load(az.brd)
        


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

