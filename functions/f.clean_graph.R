#' f.clean_graph  - EXPERIMENTELL!
#'
#' Zitationsnetzwerk für den BGH bereinigen.
#'
#' @param g Data.table. Der rohe Graph aus BGH-Zitationen.
#' @param az.brd Ein data.frame oder data.table mit dem Datensatz "Seán Fobbe (2021). Aktenzeichen der Bundesrepublik Deutschland (AZ-BRD). Version 1.0.1. Zenodo. DOI: 10.5281/zenodo.4569564."


## DEBUGGING
#g <- tar_read(igraph.citations.az)


f.clean_graph <- function(g,
                          az.brd){


    ## Convert Parallel Edges to Weights
    
    igraph::E(g)$weight <- 1
    g <- igraph::simplify(g, edge.attr.comb = list(weight = "sum"))


    ## Clean Nodes
    
    g.names <- igraph::vertex_attr(g, "name")

    g.names <- sub("^(und)|(a?hrens?)|(sowie)|(als)|(ache)|(age)|(idum)|(enat)|(ichen)|(tlich)|(in)|(tober)|(unter)|(h?ierzu)|(ummer)|(sse)|(idung)|(uhl)|(all)|(hrers?) +", "", g.names)

    g.names <- sub("^s|n|ur|la +", "", g.names)

    g.names <- gsub("^lll +", "III ", g.names)
    g.names <- gsub("^ll +", "II ", g.names)
    g.names <- gsub("^l +", "I ", g.names)

    g.names <- trimws(g.names)

    
    ## Extract Senate and Registerzeichen
    g.regz <- gsub("[IVXa-d0-9 ]*([A-Za-z\\(\\)]+) *[0-9]+/[0-9]+", "\\1", g.names)
    g.senat <- gsub("([IVXa-d0-9]*) *([A-Za-z\\(\\)]+) *[0-9]+/[0-9]+", "\\1", g.names)

    ## Set Vertex Attributes
    g <- igraph::set_vertex_attr(g, "registerzeichen", index = igraph::V(g), g.regz)
    g <- igraph::set_vertex_attr(g, "senat", index = igraph::V(g), g.senat)


    regz.final <- igraph::vertex_attr(g, "registerzeichen")

    regz.correct <- regz.final %in% az.brd$zeichen_original

    g <- igraph::delete_vertices(g, !regz.correct)


    warning(paste("Warnung:", sum(!regz.correct), "nodes entfernt, weil Registerzeichen fehlerhaft."))
    
    
    return(g)

    
}
