#' Senatsgruppen säubern (BGH)
#'
#' Ein Vektor an Spruchkörpern aus der BGH-Datenbank wird gesäubert, validiert und danach wieder ausgegeben.


#' @param x Character. Rohe Spruchkörper aus der BGH-Datenbank.

#' @return Character. Standardisierte Spruchkörper.



f.clean_spruch_bgh <- function(x){

    ## Unit Test: Argumente
    test_that("Argumente entsprechen Erwartungen.", {
        expect_type(x, "character")

    })
    

    ## **Hinweis**: An dieser Stelle wird eine mysteriöse Unterstrich-Variante mit einem regulären Unterstrich ersetzt. Es ist mir aktuell unklar um was für eine Art von Zeichen es sich handelt und wieso es in den Daten des Bundesgerichtshofs auftaucht. Weil die Code-Zeile zu einem Anzeigefehler in der LaTeX-Kompilierung führt, ist sie im Compilation Report nicht abgedruckt. Sie finden die Zeile im eigentlichen Source Code. Ich arbeite daran, die Anzeige zu vervollständigen.


    spruch <- gsub(" ",
                    "_",
                    x)


    spruch <- gsub("(.*)\\._Zivilsenat",
                    "Zivilsenat-\\1",
                    spruch)

    spruch <- gsub("(I?Xa)",
                    "Zivilsenat-\\1",
                    spruch)

    spruch <- gsub("(.*)\\._Strafsenat",
                    "Strafsenat-\\1",
                    spruch)

    spruch <- gsub("Senat_für Anwaltssachen",
                    "Anwaltsenat",
                    spruch)

    spruch <- gsub("Senat_für Landwirtschaftssachen",
                    "Landwirtschaftsenat",
                    spruch)

    spruch <- gsub("Senat_für Notarsachen",
                    "Notarsenat",
                    spruch)

    spruch <- gsub("Dienstgericht des_Bundes",
                    "DienstgerichtBund",
                    spruch)

    spruch <- gsub("Senat_für Wirtschaftsprüfersachen",
                    "Wirtschaftsprüfersenat",
                    spruch)

    spruch <- gsub("Senat_für Steuerberater-_und Steuerbevollmächtigtensachen",
                    "Steuerberatersenat",
                    spruch)

    spruch <- gsub("Gemeinsamer Senat der obersten Gerichtshöfe des Bundes",
                    "GemSenatOGBund",
                    spruch)

    spruch <- gsub("Senat_für Patentanwaltssachen",
                    "Patentanwaltsenat",
                    spruch)

    spruch <- gsub("Großer_Senat für_Strafsachen",
                    "GrosserStrafsenat",
                    spruch)

    spruch <- gsub("Großer_Senat für_Zivilsachen",
                    "GrosserZivilsenat",
                    spruch)

    spruch <- gsub("-_Zivilsenat",
                    "",
                    spruch)

    spruch <- gsub("Vereinigte Große_Senate",
                    "VereinigteGrosseSenate",
                    spruch)



    ## REGEX-Validierung des Spruchkörpers

    regex.test <- grep("[A-Za-z-]+",
                       spruch,
                       invert = TRUE,
                       value = TRUE)



    if (length(regex.test) != 0){

        warning("Folgende Spruchkörper sind fehlerhaft:")
        warning(regex.test)
    }

    

    ## Unit Test: Ergebnis
    test_that("Ergebnis entspricht Erwartungen.", {
        expect_length(regex.test, 0)
        expect_type(spruch, "character")
        expect_length(spruch, length(x))

    })

    

    return(spruch)
    
}
