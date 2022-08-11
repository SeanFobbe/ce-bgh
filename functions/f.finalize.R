#' Datensatz finalisieren
#'
#' Der Datensatz wird mit dieser Funktion um bereits berechnete Variablen angereichert und in Reihenfolge der Variablen-Dokumentation des Codebooks sortiert..

#' @param x Data.table. Der nach Datum sortierte und im Text bereinigte Datensatz.
#' @param downlod.table Data.table. Die Tabelle mit den Informationen zum Download. Wird mit dem Hauptdatensatz vereinigt.
#' @param vars.additional Data.table. Zusätzliche Variablen, die zuvor extrahiert wurden und nun mit cbind eingehängt werden. Vektoren müssen so geordnet sein wie 'x'.
#' @param varnames Character. Die im Datensatz erlaubten Variablen, in der im Codebook vorgegebenen Reihenfolge.




f.finalize <- function(x,
                       download.table,
                       vars.additional,
                       varnames){


    ## Bind additional vars
    dt.main <- cbind(x,
                     vars.additional)


    ## Merge Download Table

    dt.download.reduced <- download.table[,.(doc_id,
                                             url,
                                             bemerkung)]


    
    dt.download.reduced$doc_id <- gsub("\\.pdf",
                                       "\\.txt",
                                       dt.download.reduced$doc_id)

    dt.final <- merge(dt.main,
                      dt.download.reduced,
                      by = "doc_id")



    ## Variable "berichtigung" hinzufügen

    dt.final$berichtigung <- grepl("Berichtigung",
                                   dt.final$bemerkung,
                                   ignore.case = TRUE)
    

    ## Remove LaTeX escape characters
    varnames <- gsub("\\\\", "", varnames)

    ## Unit Test: Check variables and set column order
    data.table::setcolorder(dt.final, varnames)




    
    return(dt.final)
    
}
