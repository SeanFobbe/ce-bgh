

#' Maximalen Umfang der Datenbankabfrage für BGH bestimmen.
#'
#' @return Data.table. Enthält das jeweilige Jahr und den maximalen Seitenumfang.



f.scope  <- function(debug.toggle = FALSE,
                     debug.pages = 50){


    year <- 2000:format(Sys.Date(), "%Y")

    url.year <- paste0("https://juris.bundesgerichtshof.de/cgi-bin/rechtsprechung/list.py?Gericht=bgh&Art=en&Datum=",
                       year)



    url.all <- lapply(url.year, f.linkextract)

    pagemax0 <- unlist(lapply(url.all, f.findmax))
    
#    dt <- data.table(year,
#                     pagemax0)


    scope <- f.extend(year, pagemax0)
    scope <- rbindlist(scope)
    
    setnames(scope,
             c("year",
               "page"))


    
    ## [Debugging Modus] Reduzierung des Such-Umfangs

    if (debug.toggle == TRUE){
        scope <- scope[sample(scope[,.N], debug.pages)][order(year, page)]
    }




    url  <- paste0("https://juris.bundesgerichtshof.de/cgi-bin/rechtsprechung/list.py?Gericht=bgh&Art=en&Datum=",
                   scope$year,
                   "&Seite=",
                   scope$page,
                   "&Sort=1")


    filename <- paste0(scope$year,
                       "-",
                       formatC(scope$page,
                               width = 4,
                               flag = 0),
                       ".html")
    



    dt.return <- data.table(url,
                            filename)


    
    return(dt)
    

}






#' @param x Character. Ein Vektor aus URLs der BGH-Datenbank für ein bestimmtes Jahr.

#' @return Die maximale Datenbankseite für ein bestimmtes Jahr.



f.findmax <- function(x){

    url.relevant <- grep("Seite=[0-9]+", x, value = TRUE)
    max <- max(as.integer(gsub(".*Seite\\=([0-9]+).*", "\\1", url.relevant)))
    
    return(max)

    
}




    



#' Diese Funktion nimmt eine ganzzahlige y-Variable als Maximum einer Sequenz von 1 bis y und weist ihr in einer data.table jeweils immer die gleiche x-Variable zu.

f.extend <- function(x, y, begin = 0){
    y.ext <- begin:y
    x.ext <- rep(x, length(y.ext))
    dt.out <- list(data.table(x.ext, y.ext))
    return(dt.out)
}

f.extend <- Vectorize(f.extend)


