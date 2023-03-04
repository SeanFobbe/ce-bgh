#' Aktenzeichen für deutsche Bundesgerichte erstellen
#'
#' Erstellt ein Aktenzeichen aus den üblichen Bestandteilen für deutsche Bundesgerichte (Spruchkörper, Registerzeichen, Eingangsnummer und zweistelliges Eingangsjahr). Nicht anwendbar in Sonderfällen wie dem Bundespatentgericht.

#' @param x Ein juristischer Datensatz als data.table mit den Variablen "spruchkoerper_az", "registerzeichen", "eingangsnummer", "eingangsjahr_az".

#' @param az.brd Ein data.frame oder data.table mit dem Datensatz "Seán Fobbe (2021). Aktenzeichen der Bundesrepublik Deutschland (AZ-BRD). Version 1.0.1. Zenodo. DOI: 10.5281/zenodo.4569564."

#' @param gericht Das Gericht, dessen Aktenzeichen zu erstellen sind.
#'
#' @param remove.na Ob "NA"-Werte entfernt werden sollen. In der Regel unproblematisch, kann aber deaktiviert werden, falls dabei Registerzeichen zerstört werden.


#' @param return Ein Vektor mit Aktenzeichen.




f.var_aktenzeichen <- function(x,
                               az.brd,
                               gericht,
                               remove.na = TRUE){


    ## Unit Test
    test_that("Argumente entsprechen Erwartungen.", {
        expect_s3_class(x, "data.table")
        expect_s3_class(az.brd, "data.table")
        expect_type(gericht, "character")
    })
    

    ## Datensatz auf relevante Daten reduzieren
    az.gericht <- az.brd[stelle == gericht & position == "hauptzeichen"]

    
    ## Variable "aktenzeichen" erstellen

    aktenzeichen <- paste0(x$spruchkoerper_az,
                           " ",
                           mgsub::mgsub(x$registerzeichen,
                                        az.gericht$zeichen_code,
                                        az.gericht$zeichen_original),
                           " ",
                           x$eingangsnummer,
                           "/",
                           formatC(x$eingangsjahr_az, flag = "0", width = 2))

    
    ## NA entfernen

    if(remove.na == TRUE){
        
        aktenzeichen <- gsub("NA ",
                             "",
                             aktenzeichen)


    }
    

    ## REGEX-Validierung: Aktenzeichen

    if(gericht == "BGH"){
        
        regex.test <- grep(paste0("[0-9XIVNAa-z]*", # Spruchkörper
                                  " *",
                                  "[\\(\\)ÜA-Za-z-]+", # Registerzeichen
                                  " ",
                                  "[0-9]+", # Eingangsnummer
                                  "/",
                                  "[0-9]{2}" # Eingangsjahr
                                  ),
                           aktenzeichen,
                           value = TRUE,
                           invert = TRUE)

    }else if (gericht == "BVerfG"){
        
        regex.test <- grep(paste0("[0-9NA]*", # Spruchkörper (fehlt bei Vz-Entscheidungen)
                                  " *",
                                  "[A-Za-z-]+", # Registerzeichen
                                  " ",
                                  "[0-9]+", # Eingangsnummer
                                  "/",
                                  "[0-9]{2}" # Eingangsjahr
                                  ),
                           aktenzeichen,
                           value = TRUE,
                           invert = TRUE)

    }else{
        
        regex.test <- grep(paste0("[0-9NA]+", # Spruchkörper
                                  " ",
                                  "[A-Za-z-]+", # Registerzeichen
                                  " ",
                                  "[0-9]+", # Eingangsnummer
                                  "/",
                                  "[0-9]{2}" # Eingangsjahr
                                  ),
                           aktenzeichen,
                           value = TRUE,
                           invert = TRUE)

    }

    ## Fehlerhafte Aktenzeichen

    if(length(regex.test) != 0){
        warning("Fehlerhafte Aktenzeichen:")
        warning(regex.test)
    }

    ## Unit Test
    test_that("Aktenzeichen entsprechen Erwartungen.", {
        expect_type(aktenzeichen, "character")
        expect_length(regex.test,  0)
        expect_length(aktenzeichen, nrow(x))
    })
    
    return(aktenzeichen)
    
}
