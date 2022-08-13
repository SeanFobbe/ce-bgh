

#' Maximalen Umfang der Datenbankabfrage für BGH bestimmen.
#'
#' @return Data.table. Enthält das jeweilige Jahr und den maximalen Seitenumfang.



f.scope  <- function(){


    year <- 2000:format(Sys.Date(), "%Y")

    url.year <- paste0("https://juris.bundesgerichtshof.de/cgi-bin/rechtsprechung/list.py?Gericht=bgh&Art=en&Datum=",
                       year)



    url.all <- lapply(url.year, f.linkextract)

    pagemax0 <- unlist(lapply(url.all, f.findmax))
    
    dt <- data.table(year,
                     pagemax0)

    return(dt)
    

}






#' @param x Character. Ein Vektor aus URLs der BGH-Datenbank für ein bestimmtes Jahr.

#' @return Die maximale Datenbankseite für ein bestimmtes Jahr.



f.findmax <- function(x){

    url.relevant <- grep("Seite=[0-9]+", x, value = TRUE)
    max <- max(as.integer(gsub(".*Seite\\=([0-9]+).*", "\\1", url.relevant)))
    
    return(max)

    
}
