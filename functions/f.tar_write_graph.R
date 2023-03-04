#' f.tar_write_graph
#'
#' Write graph to file, compatible with {targets}





f.tar_write_graph <- function(graph,
                              filename,
                              format = "graphml"){

    igraph::write_graph(graph = graph,
                        file = filename,
                        format = format)


    return(filename)
    


}
