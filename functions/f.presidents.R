
#' Diese Funktion dokumentiert für jede Entscheidung welche/r Präsident:in oder Vize-Präsident:in am Tag der Entscheidung im Amt war.


#' @param datum Das Datum der Entscheidungen.
#' @param gericht Das Gericht dessen Führungsriege dokumentiert werden soll.
#' @param pvp.fcg Eine Ausgabe des Datensatzes: \enquote{Seán Fobbe and Tilko Swalve (2021). Presidents and Vice-Presidents of the Federal Courts of Germany (PVP-FCG). Version 2021-04-08. Zenodo. DOI: 10.5281/zenodo.4568682}. Entweder die Variante für Präsident:innen oder Vize-Präsident:innen.




f.presidents <- function(datum,
                         gericht,
                         pvp.fcg){

    
    ## Auf relevantes Gericht reduzieren
    
    setDT(pvp.fcg)
    
    dt <- pvp.fcg[court == gericht, .(court,
                                      name_last,
                                      name_first,
                                      term_begin_date,
                                      term_end_date)]
    
    ## Hypothethisches Amtsende
    ## Weil der/die aktuelle (Vize-)Präsident:in noch im Amt ist, ist der Wert für das Amtsende "NA". Dieser ist aber für die verwendete Logik nicht greifbar, weshalb an dieser Stelle ein hypothetisches Amtsende in einem Jahr ab dem Tag der Datensatzerstellung fingiert wird. Es wird nur an dieser Stelle verwendet und danach verworfen.

    dt[is.na(term_end_date)]$term_end_date <- Sys.Date() + 365

    ## Namen initialisieren
    names <- as.character(datum)

    ## Daten mit Namen ersetzen
    for (i in 1:dt[,.N]){

        logical <- dt$term_begin_date[i] <= as.IDate(datum) &  as.IDate(datum) <= dt$term_end_date[i]
        indices <- which(logical, datum)
        names[indices] <- dt$name_last[i]
        
    }


    ## Unit Test
    test_that("(Vize-)Präsident:innen-Vektor entspricht Erwartungen.", {
        expect_type(names, "character")
        expect_length(setdiff(names, pvp.fcg[court == gericht]$name_last),  0)
        expect_length(names, length(datum))
    })
    
    

    return(names)

}




