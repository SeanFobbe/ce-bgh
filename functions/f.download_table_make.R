#' Vorläufige Download-Tabelle erstellen

#' Diese Funktion wertet die Entscheidungsdatenbank des Bundespatentgerichts aus und sammelt Links zu den Entscheidungsvolltexten und verbindet sie mit den in der Datenbank angegebenen Metadaten.

#' @param x Data.table. Der Umfang der Datenbankseiten, der berücksichtigt werden soll. Ist im Datensatz im Ordner data/ dokumentiert.
#' @param debug.toggle Logical. Ob der Debugging-Modus aktiviert werden soll. Im Debugging-Modus wird nur eine reduzierte Anzahl Datenbankseiten ausgewertet. Jede Seite enthält idR 30 Entscheidungen.
#' @param debug.pages Integer. Anzahl der auszuwertenden Datenbankseiten.


#' @return Data.table. Eine Tabelle mit allen URLs und in der Datenbank verfügbaren Metadaten.




f.download_table_make <- function(x,
                                  debug.toggle = FALSE,
                                  debug.pages = 50){


    ## Genauen Such-Umfang berechnen

    scope <- f.extend(x$year,
                      x$pagemax0)


    scope <- rbindlist(scope)

    setnames(scope,
             c("year",
               "page"))


    
    ## [Debugging Modus] Reduzierung des Such-Umfangs

    if (debug.toggle == TRUE){
        scope <- scope[sample(scope[,.N], debug.pages)][order(year, page)]
    }



    ## Metadaten extrahieren
    
    meta.all.list <- vector("list",
                            scope[,.N])

    scope.random <- sample(scope[,.N])

    for (i in seq_along(scope.random)){
        
        year <- scope$year[scope.random[i]]
        page <- scope$page[scope.random[i]]

        URL  <- paste0("https://juris.bundesgerichtshof.de/cgi-bin/rechtsprechung/list.py?Gericht=bgh&Art=en&Datum=",
                       year,
                       "&Seite=",
                       page)
        
        html <- read_html(URL)
        
        url <-  html_nodes(html, "a" )%>% html_attr('href')
        
        url <- grep ("Blank=1.pdf",
                      url,
                      ignore.case = TRUE,
                      value = TRUE)
        
        url <- sprintf("https://juris.bundespatentgericht.de/cgi-bin/rechtsprechung/%s",
                        url)
        

        datum <- html_nodes(html, "[class='EDatum']") %>% html_text(trim = TRUE)

        senatsgruppe <- html_nodes(html, "[class='ESpruchk']") %>% html_text(trim = TRUE)
        
        az <- html_nodes(html, "[class='doklink']") %>% html_text(trim = TRUE)

        bemerkung <- html_nodes(html, "[class='ETitel']") %>% html_text(trim = TRUE)

        meta.all.list[[scope.random[i]]] <- data.table(year,
                                                       page,
                                                       url,
                                                       datum,
                                                       spruch,
                                                       az,
                                                       bemerkung)

        remaining <- length(scope.random) - i
        
        if ((remaining %% 100) == 0){
            message(paste(Sys.time(),
                          "| Noch",
                          remaining,
                          "verbleibend."))
        }

        if((i %% 100) == 0){
            Sys.sleep(runif(1, 5, 15))
        }else{
            Sys.sleep(runif(1, 1.5, 2.5))
        }    
    }

    
    ## Zusammenfügen
    dt.download <- rbindlist(meta.all.list)

    
    ## Datum bereinigen
    dt.download[, datum := {
        datum <- as.character(datum)
        datum <- as.IDate(datum, "%d.%m.%Y")
        list(datum)}]
    

    return(dt.download)

}






#' Diese Funktion nimmt eine ganzzahlige y-Variable als Maximum einer Sequenz von 1 bis y und weist ihr in einer data.table jeweils immer die gleiche x-Variable zu.

f.extend <- function(x, y, begin = 0){
    y.ext <- begin:y
    x.ext <- rep(x, length(y.ext))
    dt.out <- list(data.table(x.ext, y.ext))
    return(dt.out)
}

f.extend <- Vectorize(f.extend)

