#' Vorläufige Download-Tabelle erstellen

#' Diese Funktion wertet die Entscheidungsdatenbank des Bundesgerichtshofs aus und sammelt Links zu den Entscheidungsvolltexten und verbindet sie mit den in der Datenbank angegebenen Metadaten.

#' @param files.html String. Pfade zu den HTML-Dateien der Datenbankseiten des BGH.

#' @return Data.table. Eine Tabelle mit allen URLs zu PDFs und in der Datenbank verfügbaren Metadaten.



## DEBUGGING

## files.html <- list.files("files/html", full.names = TRUE)




f.download_table_make <- function(files.html){


    ## Metadaten extrahieren

    list <- lapply(files.html,
                   f.parse_html_bgh)

    dt <- rbindlist(list)

    
    ## Datum bereinigen
    dt[, datum := {
        datum <- as.character(datum)
        datum <- as.IDate(datum, "%d.%m.%Y")
        list(datum)}]

    
    ## Bemerkungen bereinigen
    
    dt$bemerkung <- gsub("Leitsaetz|Leitsaz|Leitsazt",
                                  "Leitsatz",
                                  dt$bemerkung)

    return(dt)
    
}




f.parse_html_bgh <- function(file){

    
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


    ## Extract year and page from filename

    year <- gsub("([0-9]{4})-[0-9]{4}\\.html", "\\1", basename(file))
    year <- rep(year, length(url))
    page <- gsub("[0-9]{4}-([0-9]{4})\\.html", "\\1", basename(file))
    page <- rep(page, length(url))



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
