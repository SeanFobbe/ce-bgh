#' Vorläufige Download-Tabelle erstellen

#' Diese Funktion wertet die Entscheidungsdatenbank des Bundespatentgerichts aus und sammelt Links zu den Entscheidungsvolltexten und verbindet sie mit den in der Datenbank angegebenen Metadaten.

#' @param x Data.table. Der Umfang der Datenbankseiten, der berücksichtigt werden soll. Ist im Datensatz im Ordner data/ dokumentiert.
#' @param debug.toggle Logical. Ob der Debugging-Modus aktiviert werden soll. Im Debugging-Modus wird nur eine reduzierte Anzahl Datenbankseiten ausgewertet. Jede Seite enthält idR 30 Entscheidungen.
#' @param debug.pages Integer. Anzahl der auszuwertenden Datenbankseiten.
#' @param progresscount Integer. Die Anzahl Seiten nach denen der Progress Count eine Meldung ausgibt.


#' @return Data.table. Eine Tabelle mit allen URLs und in der Datenbank verfügbaren Metadaten.




f.download_table_make <- function(x,
                                  debug.toggle = FALSE,
                                  debug.pages = 50,
                                  progresscount = 100){


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

    for (i in 1:scope[,.N]){
        
        year <- scope$year[i]
        page <- scope$page[i]

        URL  <- paste0("https://juris.bundesgerichtshof.de/cgi-bin/rechtsprechung/list.py?Gericht=bgh&Art=en&Datum=",
                       year,
                       "&Seite=",
                       page)
        
        html <- rvest::read_html(URL)
        
        url <- rvest::html_nodes(html, "a" )
        url <- rvest::html_attr(url, 'href')
        
        url <- grep ("Blank=1.pdf",
                     url,
                     ignore.case = TRUE,
                     value = TRUE)
        
        url <- sprintf("https://juris.bundesgerichtshof.de/cgi-bin/rechtsprechung/%s",
                       url)
        

        datum <- rvest::html_nodes(html, "[class='EDatum']") %>%
            rvest::html_text(trim = TRUE)

        spruch <- rvest::html_nodes(html, "[class='ESpruchk']") %>%
            rvest::html_text(trim = TRUE)
        
        az <- rvest::html_nodes(html, "[class='doklink']") %>%
            rvest::html_text(trim = TRUE)

        bemerkung <- rvest::html_nodes(html, "[class='ETitel']") %>%
            rvest::html_text(trim = TRUE)

        meta.all.list[[i]] <- data.table(year,
                                         page,
                                         url,
                                         datum,
                                         spruch,
                                         az,
                                         bemerkung)

        remaining <- nrow(scope) - i

        ## For debugging
        #message(i)

        ## Progress Count
        if ((remaining %% progresscount) == 0){
            message(paste(Sys.time(),
                          "| Noch",
                          remaining,
                          "verbleibend."))

        }

        ## Sleep
        if((i %% 100) == 0){
            Sys.sleep(runif(1, 5, 15))
        }else{
            Sys.sleep(runif(1, 1, 2))
        }    
    }

    
    ## Zusammenfügen
    dt.download <- rbindlist(meta.all.list)

    
    ## Datum bereinigen
    dt.download[, datum := {
        datum <- as.character(datum)
        datum <- as.IDate(datum, "%d.%m.%Y")
        list(datum)}]

    ## Bemerkungen bereinigen
    
    dt.download$bemerkung <- gsub("Leitsaetz|Leitsaz|Leitsazt",
                                  "Leitsatz",
                                  dt.download$bemerkung)

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


