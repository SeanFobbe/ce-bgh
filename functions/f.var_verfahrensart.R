#' Verfahrensart bestimmen
#'
#' Bestimmt die Verfahrensart (Langform), die durch das Registerzeichen einer Entscheidung angegeben wird. Der Datensatz "Seán Fobbe (2021). Aktenzeichen der Bundesrepublik Deutschland (AZ-BRD). Version 1.0.1. Zenodo. DOI: 10.5281/zenodo.4569564." ist notwendige Grundlage.


#' @param x Ein Vektor mit Registerzeichen, die im Datensatz "AZ-BRD" dokumentiert sind.
#' @param az.brd Ein data.frame oder data.table mit dem Datensatz "Seán Fobbe (2021). Aktenzeichen der Bundesrepublik Deutschland (AZ-BRD). Version 1.0.1. Zenodo. DOI: 10.5281/zenodo.4569564."
#' @param gericht Das Gericht, dessen Registerzeichen mit Bedeutung zu versehen sind.


#' @param return Ein Vektor mit den Bedeutungen der jeweiligen Registerzeichen.





f.var_verfahrensart <- function(x,
                                az.brd,
                                gericht){

    ## Datensatz auf relevante Daten reduzieren
    az.gericht <- az.brd[stelle == gericht & position == "hauptzeichen"]
    
    
    ## Indizes bestimmen
    targetindices <- match(x,
                           az.gericht$zeichen_code)
    
    ## Vektor der Verfahrensarten erstellen und einfügen
    verfahrensart <- az.gericht$bedeutung[targetindices]
    
    
    return(verfahrensart)
    
}
