#' Entscheidungstyp extrahieren
#'
#' Durchsucht den Volltext einer Gerichtsentscheidung auf das Vorhandensein der Wörter "Beschluss", "Urteil" oder "Verfügung". Der erste Treffer stellt den Typ der Entscheidung dar.


#' @param x Character. Ein Vektor, die den Volltext von Gerichtsentscheidungen enthalten.
#'
#' @param return Character. Ein Vektor aller Entscheidungstypen. Entweder "B" für Beschluss, "U" für Urteil oder "V" für Verfügung". 


f.var_entscheidung_typ <- function(x){

    ## Entscheidungstyp extrahieren
    entscheidung_typ <- stringi::stri_extract_first(str = x,
                                                    regex = paste0(gsub(" ", " *", "B E S C H L U S S"),
                                                                   "|",
                                                                   gsub(" ", " *", "B E S C H L U ß"),
                                                                   "|",
                                                                   gsub(" ", " *", "U R T E I L"),
                                                                   "|",
                                                                   gsub(" ", " *", "V E R F Ü G U N G")),
                                                    case_insensitive = TRUE)

    ## Auf einzelnen Buchstaben reduzieren
    entscheidung_typ <- gsub("([BUV]).+",
                             "\\1",
                             toupper(entscheidung_typ))

    ## Unit Test: Vollständigkeit der Extraktion
    if (!length(x) == length(entscheidung_typ)){

        stop("Extraktion nicht vollständig.")
        
    }
    
    ## Unit Test: Begrenzung auf bestimmte Entscheidungstypen
    if (any(!entscheidung_typ %in% c("B", "U", "V", NA))){

        stop("Entscheidungstypen entsprechen nicht der Definition.")
        
    }

    
    return(entscheidung_typ)
    
    
}
