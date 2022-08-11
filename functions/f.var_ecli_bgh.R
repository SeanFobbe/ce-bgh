#' Experimentelle Erstellung von ECLIs für Entscheidungen des Bundesgerichtshofs.


#' Struktur und Inhalt der ECLI für deutsche Gerichte sind auf dem Europäischen Justizportal näher erläutert: https://e-justice.europa.eu/content_european_case_law_identifier_ecli-175-de-de.do?member=1
#'
#' ACHTUNG: diese ECLIs sind experimentell. Der BGH vergibt offiziell ECLI-Identifikatoren nur für Entscheidungen ab 2016. Ausserdem steht die originale Kollisions-ID nicht zur Verfügung. Alle Entscheidungen mit einer Kollisions-ID größer 0 und ihre korrespondierenden Entscheidungen mit der ID 0 haben potenziell syntaktisch korrekte, aber semantisch fehlerhafte ECLIs.


#' @param x Data.table. Ein BGH-Datensatz mit den Variablen "datum", "entscheidung_typ", "spruchkoerper_az", "registerzeichen", "eingangsnummer", "eingangsjahr_az", "verzoegerung" und "kollision".
#' @param dt.download Data.table. Eine Download-Tabelle mit den Variablen "url" und "doc_id".


#' @param return Ein Vektor mit ECLIs für den Bundesgerichtshof.






f.var_ecli_BGH <- function(x,
                           az.brd){




    ## Originale Registerzeichen wiederherstellen

    ecli.registerzeichen <- mgsub::mgsub(x$registerzeichen,
                                         az.brd$zeichen_code,
                                         az.brd$zeichen_original)
    
    ## Formatieren der Registerzeichen für ECLI
    
    ecli.registerzeichen <- gsub("\\(|\\)",
                                 "\\.",
                                 ecli.registerzeichen)
    
    ecli.registerzeichen <- toupper(ecli.registerzeichen)
    
    



    ## Erstellen der ECLI-Ordinalzahl

    ecli.ordinalzahl <- paste0(format(x$datum,
                                      "%d%m%y"),
                               x$entscheidung_typ,
                               ifelse(is.na(x$spruchkoerper_az),
                                      "",
                                      x$spruchkoerper_az),
                               ecli.registerzeichen,
                               x$eingangsnummer,
                               ".",
                               formatC(x$eingangsjahr_az,
                                       width = 2,
                                       flag = "0"),
                               ".",
                               x$kollision)





    ecli.ordinalzahl <- gsub("NA",
                             "",
                             ecli.ordinalzahl)


    ## Vollständige ECLI erstellen
    
    ecli <- paste0("ECLI:DE:BGH:",
                   x$entscheidungsjahr,
                   ":",
                   ecli.ordinalzahl)


    
    ## REGEX-Validierung: Gesamte ECLI

    regex.test <- grep(paste0("ECLI:DE:BGH", # Präamel
                              ":[0-9]{4}:", # Entscheidungsjahr
                              "[0-9]{6}", # Datum
                              "[IVX0-9a-z]*", # Senatsnummer
                              "[A-Z.]+", # Registerzeichen
                              "[0-9]+", # Eingangsnummer
                              "\\.[0-9]{2}", # Eingangsjahr
                              "\\.[0-9]"), # Kollisionsziffer
                              
                       ecli,
                       value = TRUE,
                       invert = TRUE)


    ## Fehlerhafte ECLI

    if(length(regex.test) != 0){
        warning("Fehlerhafte ECLI:")
        warning(regex.test)
    }

    ## Unit Test
    test_that("ECLI entsprechen Erwartungen.", {
        expect_type(ecli, "character")
        expect_length(regex.test,  0)
        expect_length(ecli, nrow(x))
    })
    

    
    return(ecli)


}

