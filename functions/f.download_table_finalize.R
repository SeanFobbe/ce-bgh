#' Download-Tabelle finalisieren
#'
#' Stellt die finale Download-Tabelle für den BGH her. Die ursprüngliche aus der Datenbank extrahierte Tabelle wird mit korrigierten Aktenzeichen und Spruchkörpern angereichert. Zusätzliche Variablen werden aus der Variable "bemerkung" extrahiert. Ein Dateiname wird erstellt und auf Konformität mit dem Codebook geprüft, ansonsten bricht die Funktion mit einer Fehlermeldung ab. 


#' @param x Data.table. Download-Tabelle für das BGH.
#' @param az Character. Korrigierte Aktenzeichen.
#' @param spruch Character. Korrigierte Spruchkörper.


f.download_table_finalize <- function(x,
                                      az,
                                      spruch){


    ## Unit Test: Argumente
    test_that("Argumente entsprechen Erwartungen.", {
        expect_type(az, "character")
        expect_type(spruch, "character")
        expect_equal(nrow(x), length(az))
        expect_equal(nrow(x), length(spruch))
    })
    

    ## Korrigierte Variablen einfügen

    x$az <- az
    x$spruchkoerper_db <- spruch

    
    ## Variable "leitsatz" erstellen

    x$leitsatz <- ifelse(grepl("Leitsatz",
                               x$bemerkung,
                               ignore.case = TRUE),
                         "LE",
                         "NA")

    

    ## Variable "name" erstellen


    name <- sub("(.*)\r\n.*",
                "\\1",
                x$comment)

    name[grepl("Leitsatz|Pressemitteilung|Berichtigung",
               name,
               ignore.case = TRUE)] <- NA

    name[grepl("^$", name)] <- NA

    x$name <- name


    ## Variable "name_datei" erstellen

    name_datei <- name

    name_datei <- trimws(name_datei)

    name_datei <- path_sanitize(name_datei,
                                "")

    name_datei <- gsub(" +",
                       "-",
                       name_datei)

    name_datei <- gsub("'",
                       "",
                       name_datei)

    name_datei <- gsub(",",
                       "",
                       name_datei)

    x$name_datei <- name_datei



    ## Dateinamen erstellen

    filename <- paste("BGH",
                    x$spruchkoerper_db,
                    x$leitsatz,
                    x$datum,
                    x$az,
                    x$name_datei,
                    sep = "_")



    ## Einzelkorrektur vornehmen

    filename <- gsub("BGH_Strafsenat-3_([NALE]{2})_NA_NA_AK_13_19_NA",
                     "BGH_Strafsenat-3_\\1_2019-05-07_NA_AK_13_19_NA",
                     filename)




    ## Kollisions-IDs vergeben
    filenames1 <- make.unique(filename, sep = "-----")


    indices <- grep("-----",
                    filenames1,
                    invert = TRUE)

    values <- grep("-----",
                   filenames1,
                   invert = TRUE,
                   value = TRUE)

    filenames1[indices] <- paste0(values,
                                  "_0")

    filenames1 <- gsub("-----",
                       "_",
                       filenames1)



    ## PDF-Endung anfügen
    filenames2 <- paste0(filenames1,
                         ".pdf")

    ## Vollen Dateinamen in Download Table einfügen
    x$doc_id <- filenames2


    
    ## REGEX-Validierung: Gesamter Dateiname

    regex.test <- grep(paste0("BGH", # gericht
                              "_",
                              ".*", # spruchkoerper_db
                              "_",
                              "[NALE]{2}", # leitsatz
                              "_",
                              "[0-9]{4}-[0-9]{2}-[0-9]{2}", # datum
                              "_",
                              "[A-Za-z0-9]*",# spruchkoerper_az
                              "_",
                              "[A-Za-zÜ]*", # registerzeichen
                              "_",
                              "[0-9-]*", # eingangsnummer
                              "_",
                              "[0-9]{2}", # eingangsjahr_az
                              "_",
                              "[A-Za-z]*", # zusatz_az
                              "_",
                              ".*", # name 
                              "_",
                              "[NA0-9]*", # kollision
                              "\\.pdf"), # Dateiendung
                       filenames2,
                       value = TRUE,
                       invert = TRUE)




    if (length(regex.test) != 0){

        warning("Folgende Dateinamen sind fehlerhaft:")
        warning(regex.test)
    }

    

    ## Unit Test: Ergebnis
    test_that("Ergebnis entspricht Erwartungen.", {
        expect_length(regex.test, 0)
        expect_s3_class(x, "data.table")
        expect_length(x, 12)
    })



    return(x)
    
    
}
