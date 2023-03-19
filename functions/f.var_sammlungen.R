#' f.var_sammlungen
#'
#' Extrahiert aus BGH-Entscheidungen Hinweise auf die Veröffentlichung der Entscheidung in einer Sammlung, aktuell nur für BGHSt, BGHZ, BGHR und Nachschlagewerk.
#'
#' @param text String. Ein Vektor aus Texten von BGH-Entscheidungen.
#'
#' @return Data.table. Eine Tabelle mit Variablen für BGHSt, BGHZ, BGHR und Nachschlagewerk. Falls enthalten, mit 1 codiert, sonst mit 0.
#'


 
##' Beispiel:
##' BGHSt: ja
##' BGHR: ja
##' Nachschlagewerk: ja
##' Veröffentlichung: ja
##'
##' Testing:
##' substr(dt.bgh.datecleaned[doc_id == "BGH_Strafsenat-1_LE_2018-10-23_1_StR_454_17_NA_NA_0.txt"]$text, 1, 1000)




f.var_sammlungen <- function(text){

    text.sub <- substr(text, 1, 1000)
    
    bghst <- grepl("BGHSt: *ja",
                   text.sub,
                   ignore.case = TRUE) * 1

    bghz <- grepl("BGHZ: *ja",
                   text.sub,
                   ignore.case = TRUE) * 1
        
    bghr <- grepl("BGHR: *ja",
                  text.sub,
                  ignore.case = TRUE) * 1

    nachschlagewerk <- grepl("Nachschlagewerk: *ja",
                             text.sub,
                             ignore.case = TRUE) * 1

    dt.return <- data.table(bghst,
                            bghz,
                            bghr,
                            nachschlagewerk)

    return(dt.return)

}













