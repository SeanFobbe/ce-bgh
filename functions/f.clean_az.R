#' Aktenzeichen säubern (BGH)
#'
#' Ein Vektor von BGH-Aktenzeichen aus der amtlichen Datenbank wird gesäubert und als Vektor wieder ausgegeben.

#' @param x Character. Rohe Aktenzeichen aus der BGH-Datenbank.

#' @return Character. Korrigierte Aktenzeichen im Format [Senat]_[Registerzeichen]_[Eingangsnummer]_[Eingangsjahr]



f.clean_az_bgh <- function(x){

    ## Unit Test: Argumente
    test_that("Argumente entsprechen Erwartungen.", {
        expect_type(x, "character")

    })
    

    ## An dieser Stelle wird eine mysteriöse Unterstrich-Variante mit einem regulären Unterstrich ersetzt. Es ist mir aktuell unklar um was für eine Art von Zeichen es sich handelt und wieso es in den Daten des Bundespatentgerichts auftaucht. Vermutlich handelt es sich um non-breaking spaces.

    az <- gsub(" ", "_", x)



    az <- gsub("AK_34_und_35/21", "AK_34/21", az)
    az <- gsub("StB_25_und_26/21", "StB_25/21", az)


    az <- gsub("\\/", "_", az)

    az <- gsub("_und.*$", "", az)

    az <- gsub("StB_", "NA_StB_", az)
    az <- gsub("StbSt_\\(R\\)", "NA_StbStR", az)
    az <- gsub("StbSt_\\(B\\)", "NA_StbStB", az)

    az <- gsub("PatAnwZ_", "NA_PatAnwZ_", az)

    az <- gsub("AnwZ_?\\(Brf[gG]\\)", "NA_AnwZBrfg", az)

    az <- gsub("AK", "NA_AK", az)
    az <- gsub("ARAnw_", "NA_ARAnw_", az)
    az <- gsub("ARs_\\(Voll[zZ]\\)_", "ARsVollz_", az)
    az <- gsub("AR_\\(VZ\\)", "ARVZ", az)
    az <- gsub("AR_\\(VS\\)", "ARVS", az)
    az <- gsub("AR_\\(Ri\\)", "NA_ARRi", az)
    az <- gsub("^AnwSt_\\(B\\)", "NA_AnwStB", az)
    az <- gsub("^AnwSt_\\(R\\)", "NA_AnwStR", az)
    az <- gsub("^PatAnwSt_\\(B\\)", "NA_PatAnwStB", az)
    az <- gsub("^PatAnwSt_\\(R\\)", "NA_PatAnwStR", az)
    az <- gsub("AnwZ_\\(B\\)", "NA_AnwZB", az)
    az <- gsub("AnwZ_\\(P\\)_", "NA_AnwZP_", az)
    az <- gsub("^AnwZ_", "NA_AnwZ_", az)
    az <- gsub("ARNot_", "NA_ARNot_", az)

    az <- gsub("BLw", "NA_BLw", az)

    az <- gsub("En[vV]R_", "NA_EnVR_", az)
    az <- gsub("EnZR_", "NA_EnZR_", az)
    az <- gsub("EnVZ_", "NA_EnVZ_", az)
    az <- gsub("EnZB_", "NA_EnZB_", az)

    az <- gsub("GmS-OGB_", "NA_GMSOGB_", az)
    az <- gsub("GSSt_", "NA_GSSt_", az)
    az <- gsub("GSZ_", "NA_GSZ_", az)

    az <- gsub("KZR_", "NA_KZR_", az)
    az <- gsub("KVZ_", "NA_KVZ_", az)
    az <- gsub("KRB_", "NA_KRB_", az)
    az <- gsub("KZB_", "NA_KZB_", az)
    az <- gsub("KVR_", "NA_KVR_", az)

    az <- gsub("LwZA_", "NA_LwZA_", az)
    az <- gsub("LwZR_", "NA_LwZR_", az)
    az <- gsub("LwZB", "NA_LwZB", az)

    az <- gsub("NotSt_\\(B\\)", "NA_NotStB", az)
    az <- gsub("NotSt_\\(Brfg\\)", "NA_NotStBrfg", az)
    az <- gsub("NotZ_\\(Brfg\\)", "NA_NotZBrfg", az)
    az <- gsub("NotZ_", "NA_NotZ_", az)

    az <- gsub("RiZ_?\\(R\\)", "NA_RiZR", az)
    az <- gsub("RiZ_?\\(B\\)", "NA_RiZB", az)
    az <- gsub("RiZ_", "NA_RiZ_", az)
    az <- gsub("RiSt_\\(R\\)_", "NA_RiStR_", az)
    az <- gsub("RiSt_\\(B\\)_", "NA_RiStB_", az)
    az <- gsub("^RiSt_", "NA_RiSt_", az)

    az <- gsub("WpSt_\\(R\\)_", "NA_WpStR_", az)
    az <- gsub("WpSt_\\(B\\)_", "NA_WpStB_", az)

    az <- gsub("VGS_", "NA_VGS_", az)

    az <- gsub("V_I_", "VI_", az)
    az <- gsub("XA", "Xa", az)


    ## Einzelne Fehler bereinigen

    az <- gsub("_ZR_\\(Ü\\)_", "_ZRÜ_", az)
    az <- gsub("_\\+_48", "", az)
    az <- gsub("u\\._25_", "", az)
    az <- gsub("_-_28_07", "", az)

    az <- gsub("-[0-9]*_", "_", az)

    az <- gsub("_\\(a\\)", "_a", az)





    ## Variable "zusatz_az" einfügen

    indices <- grep("[0-9]*_[A-Za-zÜ]*_[0-9]*_[0-9]*_[a-z]*",
                    az,
                    invert = TRUE)

    values <- grep("[0-9]*_[A-Za-zÜ]*_[0-9]*_[0-9]*_[a-z]*",
                   az,
                   invert = TRUE,
                   value = TRUE)

    az[indices] <- paste0(values,
                          "_NA")


    ## Finale Korrekturen
    ## Bei der Entscheidung 1 BGs 29/2009 ist als einzige unter allen Entscheidungen das Eingangsjahr vierstellig und nicht zweistellig, auch im Text der Entscheidung selber. Ich gehe dennoch davon aus, das es sich hier um einen Schreibfehler handelt und nehme eine Korrektur vor.

    az <- gsub("1_BGs_29_2009_NA",
               "1_BGs_29_09_NA",
               az)



    ## Strenge REGEX-Validierung des Aktenzeichens

    regex.test <- grep(paste0("[0-9A-Za]+", # Senatsnummer
                              "_",
                              "[A-Za-zÜ]+", # Registerzeichen
                              "_",
                              "[0-9]+", # Eingangsnummer
                              "_",
                              "[0-9]{2}", # Eingangsjahr
                              "_",
                              "[A-Za-z]+"), # Kollision
                       az,
                       invert = TRUE,
                       value = TRUE)


    if (length(regex.test) != 0){

        warning("Folgende Aktenzeichen sind fehlerhaft:")
        warning(regex.test)
    }

    

    ## Unit Test: Ergebnis
    test_that("Ergebnis entspricht Erwartungen.", {
        expect_length(regex.test, 0)
        expect_type(az, "character")
        expect_length(az, length(x))

    })

    return(az)

}
