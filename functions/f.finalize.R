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


    ## Unit Test
    test_that("Input is of correct type.", {
        expect_s3_class(x, "data.table")
        expect_s3_class(download.table, "data.table")
        expect_s3_class(vars.additional, "data.table")
        expect_type(varnames, "character")
    })
    
    

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
    




    ## Platzhalter-Dokumente
    ## Dokumente ohne Typ, Name und Berichtigung sind fast immer Platzhalter-Dokumente, die keine Begründung enthalten und/oder auf den Push-Service der Universität des Saarlandes hinweisen. Diese werden am Ende dieses Abschnitts entfernt.

    placeholder.txt <- dt.final[is.na(entscheidung_typ) == TRUE &
                                is.na(name) == TRUE &
                                berichtigung == FALSE]$doc_id


    ## Falsch-positive Dokumente behalten

    falsepositives <- c("BGH_Zivilsenat-9_NA_2002-03-21_IX_ZB_57_02_NA_NA_0.txt",
                        "BGH_Zivilsenat-10_LE_2006-11-23_X_ZR_16_05_NA_NA_0.txt",
                        "BGH_Zivilsenat-10_LE_2008-04-22_X_ZR_76_07_NA_NA_0.txt")

    placeholder.txt <- setdiff(placeholder.txt, falsepositives)
    

    ## Einzelkorrektur
    
    ## Das folgende Dokument ist nach Extraktion ein leeres Text-Dokument, im originalen PDF aber ein funktionaler Scan. Es wird temporär vom Datensatz ausgeschlossen damit keine Fehler in der Zählung linguistischer Kennzahlen auftreten. In Zukunft wird ein OCR-Modul hierfür eingerichtet.


    if (file.exists("txt/BGH_Zivilsenat-1_LE_2006-07-13_I_ZR_241_03_NA_Kontaktanzeigen_0.txt") == TRUE){

        placeholder.txt <- c(placeholder.txt,
                             "BGH_Zivilsenat-1_LE_2006-07-13_I_ZR_241_03_NA_Kontaktanzeigen_0.txt")

    }



    ## Platzhalter aus Datensatz entfernen
    dt.final <- dt.final[!(doc_id %in% placeholder.txt)]




    ## Unit Test: Check if all variables are documented
    varnames <- gsub("\\\\", "", varnames) # Remove LaTeX escape characters
    stopifnot(length(setdiff(names(dt.final), varnames)) == 0)
    
    ## Order variables as in Codebook
    data.table::setcolorder(dt.final, varnames)


    ## Unit Tests

    test_that("Output is of correct type", {
        expect_s3_class(dt.final, "data.table")
    })

    test_that("Number of output docs are equal to input rows minus placeholders.", {
        expect_equal(dt.final[,.N],  x[,.N] - length(placeholder.txt))
    })

    ## test_that("Number of output docs are equal to downloaded docs minus placeholders.", {
    ##     expect_equal(dt.final[,.N],  download.table[,.N]  - length(placeholder.txt))
    ## }) ## DEACTIVATED, fails if TXT conversion is not perfect

    
    return(dt.final)
    
}



## DEBUGGING CODE


## library(testthat)
## library(data.table)
## x <- tar_read(dt.bgh.datecleaned)
## download.table <- tar_read(dt.download.final)
## vars.additional <- tar_read(vars_additional)
## varnames <- tar_read(variables.codebook)$varname
