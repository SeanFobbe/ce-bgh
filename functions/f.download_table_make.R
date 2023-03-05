#' Vorläufige Download-Tabelle erstellen

#' Diese Funktion wertet die Entscheidungsdatenbank des Bundespatentgerichts aus und sammelt Links zu den Entscheidungsvolltexten und verbindet sie mit den in der Datenbank angegebenen Metadaten.

#' @param x Data.table. Der Umfang der Datenbankseiten, der berücksichtigt werden soll. Ist im Datensatz im Ordner data/ dokumentiert.



#' @return Data.table. Eine Tabelle mit allen URLs und in der Datenbank verfügbaren Metadaten.




f.download_table_make <- function(files.html){



#    files.html <- list.files("files/html", full.names =T)

    


    ## Metadaten extrahieren





        
        
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

}





f.parse_html_bgh <- function(file){


    ## Extract year and page from filename

    year <- gsub("([0-9]{4})-[0-9]{4}\\.html", "\\1", basename(file))
    year <- rep(year, length(url))
    page <- gsub("[0-9]{4}-([0-9]{4})\\.html", "\\1", basename(file))
    page <- rep(page, length(url))

    
    ## Read HTML
    html <- rvest::read_html(file)


    ## Extract PDF link
    url <- rvest::html_nodes(html, "a" )
    url <- rvest::html_attr(url, 'href')
    
    url <- grep ("Blank=1.pdf",
                 url,
                 ignore.case = TRUE,
                 value = TRUE)
    
    url <- sprintf("https://juris.bundesgerichtshof.de/cgi-bin/rechtsprechung/%s",
                   url)


    
    ## Extract Metadata
    
    datum <- rvest::html_nodes(html, "[class='EDatum']")
    datum <- rvest::html_text(datum, trim = TRUE)

    spruch <- rvest::html_nodes(html, "[class='ESpruchk']")
    spruch <- rvest::html_text(spruch, trim = TRUE)
    
    az <- rvest::html_nodes(html, "[class='doklink']")
    az <- rvest::html_text(az, trim = TRUE)

    bemerkung <- rvest::html_nodes(html, "[class='ETitel']")
    bemerkung <- rvest::html_text(bemerkung, trim = TRUE)


    



    ## Return Data Table
    dt.return <- data.table(year,
                            page,
                            url,
                            datum,
                            spruch,
                            az,
                            bemerkung)

    return(dt.return)
    
    
}




    
    ## meta.all.list <- vector("list",
    ##                         scope[,.N])

    ## scope.random <- sample(scope[,.N])
    

    ## for (i in seq_along(scope.random)){
        
    ## year <- scope$year[scope.random[i]]
    ## page <- scope$page[scope.random[i]]

    ##     URL  <- paste0("https://juris.bundesgerichtshof.de/cgi-bin/rechtsprechung/list.py?Gericht=bgh&Art=en&Datum=",
    ##                    year,
    ##                    "&Seite=",
    ##                    page)
        
    ##     html <- rvest::read_html(URL)
        
    ##     url <- rvest::html_nodes(html, "a" )
    ##     url <- rvest::html_attr(url, 'href')
        
    ##     url <- grep ("Blank=1.pdf",
    ##                  url,
    ##                  ignore.case = TRUE,
    ##                  value = TRUE)
        
    ##     url <- sprintf("https://juris.bundesgerichtshof.de/cgi-bin/rechtsprechung/%s",
    ##                    url)
        

    ##     datum <- rvest::html_nodes(html, "[class='EDatum']") %>%
    ##         rvest::html_text(trim = TRUE)

    ##     spruch <- rvest::html_nodes(html, "[class='ESpruchk']") %>%
    ##         rvest::html_text(trim = TRUE)
        
    ##     az <- rvest::html_nodes(html, "[class='doklink']") %>%
    ##         rvest::html_text(trim = TRUE)

    ##     bemerkung <- rvest::html_nodes(html, "[class='ETitel']") %>%
    ##         rvest::html_text(trim = TRUE)

    ##     meta.all.list[[scope.random[i]]] <- data.table(year,
    ##                                                    page,
    ##                                                    url,
    ##                                                    datum,
    ##                                                    spruch,
    ##                                                    az,
    ##                                                    bemerkung)
