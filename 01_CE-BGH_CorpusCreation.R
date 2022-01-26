#'---
#'title: "Source Code des Corpus der Entscheidungen des Bundesgerichtshofs (CE-BGH-Source)"
#'author: Seán Fobbe
#'geometry: margin=3cm
#'fontsize: 11pt
#'output:
#'  pdf_document:
#'    toc: true
#'    toc_depth: 3
#'    number_sections: true
#'    pandoc_args: --listings
#'    includes:
#'      in_header: General_Source_TEX_Preamble_DE.tex
#'      before_body: [CE-BGH_Source_TEX_Definitions.tex,CE-BGH_Source_TEX_CompilationTitle.tex]
#'papersize: a4
#'bibliography: packages.bib
#'nocite: '@*'
#' ---


#+ echo = FALSE 
knitr::opts_chunk$set(echo = TRUE,
                      warning = TRUE,
                      message = TRUE)


#'\newpage
#+
#'# Einleitung
#'
#+
#'## Überblick
#' Dieses R-Skript lädt alle in der amtlichen Datenbank des Bundesgerichtshofs\footnote{\url{https://www.bundesgerichtshof.de}} veröffentlichten Entscheidungen des Bundesgerichtshofs (BGH) herunter und kompiliert sie in einen reichhaltigen menschen- und maschinenlesbaren Korpus. Es ist die Basis für den \textbf{\datatitle\ (\datashort )}.
#'
#' Alle mit diesem Skript erstellten Datensätze werden dauerhaft kostenlos und urheberrechtsfrei auf Zenodo, dem wissenschaftlichen Archiv des CERN, veröffentlicht. Alle Versionen sind mit einem persistenten Digital Object Identifier (DOI) versehen. Die neueste Version des Datensatzes ist immer über diesen Link erreichbar: \dataconcepturldoi

#+
#'## Funktionsweise

#' Primäre Endprodukte des Skripts sind folgende ZIP-Archive:
#' \begin{enumerate}
#' \item Der volle Datensatz im CSV-Format (mit zusätzlichen Metadaten)
#' \item Die reinen Metadaten im CSV-Format (wie unter 1, nur ohne Entscheidungsinhalte)
#' \item Alle Entscheidungen im TXT-Format
#' \item Alle Entscheidungen im PDF-Format
#' \item Nur Leitsatz-Entscheidungen im PDF-Format
#' \item Nur benannte Entscheidungen im PDF-Format
#' \item Alle Analyse-Ergebnisse (Tabellen als CSV, Grafiken als PDF und PNG)
#' \end{enumerate}
#'
#' Zusätzlich werden für alle ZIP-Archive kryptographische Signaturen (SHA2-256 und SHA3-512) berechnet und in einer CSV-Datei hinterlegt. Weiterhin kann optional ein PDF-Bericht erstellt werden (siehe unter "Kompilierung").


#+
#'## Systemanforderungen
#' Das Skript in seiner veröffentlichten Form kann nur unter Linux ausgeführt werden, da es Linux-spezifische Optimierungen (z.B. Fork Cluster) und Shell-Kommandos (z.B. OpenSSL) nutzt. Das Skript wurde unter Fedora Linux entwickelt und getestet. Die zur Kompilierung benutzte Version entnehmen Sie bitte dem **sessionInfo()**-Ausdruck am Ende dieses Berichts.
#'
#' In der Standard-Einstellung wird das Skript vollautomatisch versuchen die maximale Anzahl an Rechenkernen/Threads auf dem System zu nutzen. Wenn die Anzahl Threads (Variable "fullCores") auf 1 gesetzt wird, ist die Parallelisierung deaktiviert.
#'
#' Auf der Festplatte sollten 20 GB Speicherplatz vorhanden sein.
#' 
#' Um die PDF-Berichte kompilieren zu können benötigen Sie das R package **rmarkdown**, eine vollständige Installation von \LaTeX\ und alle in der Präambel-TEX-Datei angegebenen \LaTeX\ Packages.


#+
#'## Kompilierung
#' Mit der Funktion **render()** von **rmarkdown** können der **vollständige Datensatz** und das **Codebook** kompiliert und die Skripte mitsamt ihrer Rechenergebnisse in ein gut lesbares PDF-Format überführt werden.
#'
#' Alle Kommentare sind im roxygen2-Stil gehalten. Die beiden Skripte können daher auch **ohne render()** regulär als R-Skripte ausgeführt werden. Es wird in diesem Fall kein PDF-Bericht erstellt und Diagramme werden nicht abgespeichert.

#+
#'### Datensatz 
#' 
#' Um den **vollständigen Datensatz** zu kompilieren und einen PDF-Bericht zu erstellen, kopieren Sie bitte alle im Source-Archiv bereitgestellten Dateien in einen leeren Ordner und führen mit R diesen Befehl aus:

#+ eval = FALSE

rmarkdown::render(input = "CE-BGH_Source_CorpusCreation.R",
                  output_file = paste0("CE-BGH_",
                                       Sys.Date(),
                                       "_CompilationReport.pdf"),
                  envir = new.env())


#'### Codebook
#' Um das **Codebook** zu kompilieren und einen PDF-Bericht zu erstellen führen Sie bitte im Anschluss an die Kompilierung des Datensatzes untenstehenden Befehl mit R aus.
#'
#' Bei der Prüfung der GPG-Signatur wird ein Fehler auftreten und im Codebook dokumentiert, weil die Daten nicht mit meiner Original-Signatur versehen sind. Dieser Fehler hat jedoch keine Auswirkungen auf die Funktionalität und hindert die Kompilierung nicht.

#+ eval = FALSE

rmarkdown::render(input = "CE-BGH_Source_CodebookCreation.R",
                  output_file = paste0("CE-BGH_",
                                       Sys.Date(),
                                       "_Codebook.pdf"),
                  envir = new.env())






#'\newpage
#+
#'# Parameter

#+
#'## Name des Datensatzes
datasetname <- "CE-BGH"

#'## DOI des Datensatz-Konzeptes
doi.concept <- "10.5281/zenodo.3942742" # checked

#'## DOI der konkreten Version
doi.version <- "10.5281/zenodo.4705855" # checked

#'## Lizenz
license <- "Creative Commons Zero 1.0 Universal"


#'## Verzeichnis für Analyse-Ergebnisse
#' Muss mit einem Schrägstrich enden!

outputdir <- paste0(getwd(),
                    "/ANALYSE/") 



#'## Debugging-Modus
#' Der Debugging-Modus reduziert den Such-Umfang auf den in der Variable "debug.scope" angegebenen Umfang Seiten (jede Seite enthält idR 30 Entscheidungen), den Download-Umfang auf den in der Variable "debug.sample" definierten Umfang zufällig ausgewählter Entscheidungen und löscht im Anschluss fünf zufällig ausgewählte Entscheidungen um den Wiederholungsversuch zu testen. Nur für Test- und Demonstrationszwecke. 

mode.debug <- FALSE
debug.scope <- 50
debug.sample <- 500





#'## Optionen: Quanteda
tokens_locale <- "de_DE"



#'## Optionen: Knitr

#+
#'### Ausgabe-Format
dev <- c("pdf",
         "png")


#'### DPI für Raster-Grafiken
dpi <- 300


#'### Ausrichtung von Grafiken im Compilation Report
fig.align <- "center"





#'## Frequenztabellen: Ignorierte Variablen

#' Diese Variablen werden bei der Erstellung der Frequenztabellen nicht berücksichtigt.

varremove <- c("text",
               "eingangsnummer",
               "datum",
               "doc_id",
               "ecli",
               "aktenzeichen",
               "name",
               "bemerkung")





#'# Vorbereitung

#'## Datumsstempel
#' Dieser Datumsstempel wird in alle Dateinamen eingefügt. Er wird am Anfang des Skripts gesetzt, für den Fall, dass die Laufzeit die Datumsbarriere durchbricht.
datestamp <- Sys.Date()
print(datestamp)

#'## Datum und Uhrzeit (Beginn)
begin.script <- Sys.time()
print(begin.script)

#'## Ordner für Analyse-Ergebnisse erstellen
dir.create(outputdir)


#+
#'## Packages Laden

library(fs)           # Verbessertes File Handling
library(mgsub)        # Vektorisiertes Gsub
library(httr)         # HTTP-Werkzeuge
library(rvest)        # HTML/XML-Extraktion
library(knitr)        # Professionelles Reporting
library(kableExtra)   # Verbesserte Kable Tabellen
library(pdftools)     # Verarbeitung von PDF-Dateien
library(doParallel)   # Parallelisierung
library(ggplot2)      # Fortgeschrittene Datenvisualisierung
library(scales)       # Skalierung von Diagrammen
library(data.table)   # Fortgeschrittene Datenverarbeitung
library(readtext)     # TXT-Dateien einlesen
library(quanteda)     # Fortgeschrittene Computerlinguistik



#'## Zusätzliche Funktionen einlesen
#' **Hinweis:** Die hieraus verwendeten Funktionen werden jeweils vor der ersten Benutzung in vollem Umfang angezeigt um den Lesefluss zu verbessern.

source("General_Source_Functions.R")


#'## Quanteda-Optionen setzen
quanteda_options(tokens_locale = tokens_locale)


#'## Knitr Optionen setzen
knitr::opts_chunk$set(fig.path = outputdir,
                      dev = dev,
                      dpi = dpi,
                      fig.align = fig.align)



#'## Vollzitate statistischer Software
knitr::write_bib(c(.packages()),
                 "packages.bib")


#'## Parallelisierung aktivieren
#' Parallelisierung wird zur Beschleunigung der Konvertierung von PDF zu TXT und der Datenanalyse mittels **quanteda** und **data.table** verwendet. Die Anzahl threads wird automatisch auf das verfügbare Maximum des Systems gesetzt, kann aber auch nach Belieben auf das eigene System angepasst werden. Die Parallelisierung kann deaktiviert werden, indem die Variable **fullCores** auf 1 gesetzt wird.
#'
#' Der Download der Daten ist bewusst nicht parallelisiert, damit das Skript nicht versehentlich als DoS-Tool verwendet wird.
#'
#' Die hier verwendete Funktion **makeForkCluster()** ist viel schneller als die Alternativen, funktioniert aber nur auf Unix-basierten Systemen (Linux, MacOS).

#+
#'### Logische Kerne (Anzahl)

fullCores <- detectCores()
print(fullCores)

#'### Quanteda
quanteda_options(threads = fullCores) 

#+
#'### Data.table
setDTthreads(threads = fullCores)  













#'# Download: Weitere Datensätze

#+
#'## Registerzeichen und Verfahrensarten
#'Die Registerzeichen werden im Laufe des Skripts mit ihren detaillierten Bedeutungen aus dem folgenden Datensatz abgeglichen: "Seán Fobbe (2021). Aktenzeichen der Bundesrepublik Deutschland (AZ-BRD). Version 1.0.1. Zenodo. DOI: 10.5281/zenodo.4569564." Das Ergebnis des Abgleichs wird in der Variable "verfahrensart" in den Datensatz eingefügt.


if (file.exists("AZ-BRD_1-0-1_DE_Registerzeichen_Datensatz.csv") == FALSE){
    download.file("https://zenodo.org/record/4569564/files/AZ-BRD_1-0-1_DE_Registerzeichen_Datensatz.csv?download=1",
 "AZ-BRD_1-0-1_DE_Registerzeichen_Datensatz.csv")
    }



#'## Personendaten zu Präsident:innen
#' Die Personendaten stammen aus folgendem Datensatz: \enquote{Seán Fobbe and Tilko Swalve (2021). Presidents and Vice-Presidents of the Federal Courts of Germany (PVP-FCG). Version 2021-04-08. Zenodo. DOI: 10.5281/zenodo.4568682}.


if (file.exists("PVP-FCG_2021-04-08_GermanFederalCourts_Presidents.csv") == FALSE){
    download.file("https://zenodo.org/record/4568682/files/PVP-FCG_2021-04-08_GermanFederalCourts_Presidents.csv?download=1",
                  "PVP-FCG_2021-04-08_GermanFederalCourts_Presidents.csv")
}




#'## Personendaten zu Vize-Präsident:innen
#' Die Personendaten stammen aus folgendem Datensatz: \enquote{Seán Fobbe and Tilko Swalve (2021). Presidents and Vice-Presidents of the Federal Courts of Germany (PVP-FCG). Version 2021-04-08. Zenodo. DOI: 10.5281/zenodo.4568682}.


if (file.exists("PVP-FCG_2021-04-08_GermanFederalCourts_VicePresidents.csv") == FALSE){
    download.file("https://zenodo.org/record/4568682/files/PVP-FCG_2021-04-08_GermanFederalCourts_VicePresidents.csv?download=1",
                  "PVP-FCG_2021-04-08_GermanFederalCourts_VicePresidents.csv")
}








#'# Links suchen

#'## Maximalen Such-Umfang einlesen
scope.source <- fread("CE-BGH_Source_Scope.csv")



#'## Maximalen Such-Umfang anzeigen
#' Die Variable "pagemax1" ist die maximale Anzahl Seiten wenn der Index mit 1 beginnt. Die Variable "pagemax0" ist die maximale Anzahl Seiten wenn der Index mit 0 beginnt. Die URL beginn mit dem Index 0.

print(scope.source)



#'## Funktion definieren
#' Diese Funktion nimmt eine ganzzahlige y-Variable als Maximum einer Sequenz von 1 bis y und weist ihr in einer data.table jeweils immer die gleiche x-Variable zu.

f.extend <- function(x, y, begin = 0){
    y.ext <- begin:y
    x.ext <- rep(x, length(y.ext))
    dt.out <- list(data.table(x.ext, y.ext))
    return(dt.out)
}

f.extend <- Vectorize(f.extend)





#'## Genauen Such-Umfang berechnen

scope <- f.extend(scope.source$year,
                scope.source$pagemax0)


scope <- rbindlist(scope)

setnames(scope,
         c("year",
           "page"))


#'## Locator einfügen

scope[, loc := {
    loc <- paste0(year, "-", page)
    list(loc)
    }]


#'## [Debugging Modus] Reduzierung des Such-Umfangs

if (mode.debug == TRUE){
    scope <- scope[sample(scope[,.N], debug.scope)][order(year, page)]
    }



#'## Geschätzte Such-Dauer in Minuten
(scope[,.N]* 2.5) / 60





#'## Zeitstempel: Linksammlung Beginn
begin.linkcollect <- Sys.time()
print(begin.linkcollect)



#'## Metadaten extrahieren

meta.all.list <- vector("list",
                        scope[,.N])

scope.random <- sample(scope[,.N])

for (i in seq_along(scope.random)){
 
    year <- scope$year[scope.random[i]]
    page <- scope$page[scope.random[i]]

    URL  <- paste0("https://juris.bundesgerichtshof.de/cgi-bin/rechtsprechung/list.py?Gericht=bgh&Art=en&Datum=",
                   year,
                   "&Seite=",
                   page)
    
    html <- read_html(URL)
        
    link <-  html_nodes(html, "a" )%>% html_attr('href')
        
    link <- grep ("Blank=1.pdf",
                   link,
                   ignore.case = TRUE,
                   value = TRUE)
        
    link <- sprintf("https://juris.bundesgerichtshof.de/cgi-bin/rechtsprechung/%s",
                     link)
        

    datum <- html_nodes(html, "[class='EDatum']") %>% html_text(trim = TRUE)

    spruch <- html_nodes(html, "[class='ESpruchk']") %>% html_text(trim = TRUE)
    
    az <- html_nodes(html, "[class='doklink']") %>% html_text(trim = TRUE)

    comment <- html_nodes(html, "[class='ETitel']") %>% html_text(trim = TRUE)

    meta.all.list[[scope.random[i]]] <- data.table(year,
                                     page,
                                     link,
                                     datum,
                                     spruch,
                                     az,
                                     comment)

    remaining <- length(scope.random) - i
    
    if ((remaining %% 10^2) == 0){
        print(paste(Sys.time(), "| Noch", remaining , "verbleibend."))
    }

    if((i %% 100) == 0){
        Sys.sleep(runif(1, 5, 15))
    }else{
        Sys.sleep(runif(1, 1.5, 2.5))
        }    
}


#'## Zeitstempel: Linksammlung Ende
end.linkcollect <- Sys.time()
print(end.linkcollect)

#'## Dauer Linksammlung
end.linkcollect - begin.linkcollect



#'## Zusammenfügen
dt.download <- rbindlist(meta.all.list)





#'# Test-Reihe: Vollständigkeit der Auswertung

#'## Locator einfügen

dt.download[, loc := {
    loc <- paste0(year,
                  "-",
                  page)
    list(loc)
    }]



#'## Theoretischer Fehlbetrag

SOLL <- scope[,.N] * 30 
IST <- dt.download[,.N]

missing.N <- SOLL - IST

print(missing.N)


#'## Seiten mit weniger als 30 Entscheidungen anzeigen

less30 <- dt.download[, .N,  keyby = "loc"][N < 30]

print(less30)


#'## Fehlbetrag durch Seiten mit weniger als 30 Entscheidungen

less30.N <- (length(less30$N) * 30) - sum(less30$N)
print(less30.N)


#'## Tatsächlicher Fehlbetrag
#' **Test:** Ist der Fehlbetrag vollständig durch Seiten mit weniger als 30 Entscheidungen zu erklären? Falls ja, weisen beide sub-Tests maximal ein Ergebnis von 0 auf.


#+
#'### Fehlbetrag der NICHT durch Seiten mit weniger als 30 Entscheidungen erklärbar ist
print(missing.N - less30.N)


#'### Gegenüberstellung: Anzahl Jahre und Anzahl Seiten mit weniger als 30 Entscheidungen
#' Für jedes Jahr sollte es eine letzte Seite mit weniger als 30 Entscheidungen geben. Falls zufällig die letzte Seite exakt 30 Entscheidungen hat, wäre das Ergebnis negativ. Ein Ergebnis von 0 oder kleiner bedeutet, dass der Test bestanden wurde. Der Test ist nur aussagekräftig wenn der gesamte Such-Umfang abgefragt wurde.

if (mode.debug == FALSE){
    less30[,.N] - uniqueN(scope$year)
    }


#'## Vorhandensein aller Jahr/Seiten-Kombinationen
#' Dieser Test zeigt an, ob alle Jahr/Seiten-Kombinationen auch in den Daten vorhanden sind. Falls nicht, zeigt er die fehlenden Kombinationen an.

setdiff(scope$loc,
        dt.download$loc)





#'# Bereinigung der Metadaten

#+
#'## Datum bereinigen

dt.download[, datum := {
    datum <- as.character(datum)
    datum <- as.IDate(datum, "%d.%m.%Y")
    list(datum)}]




#'## Aktenzeichen bereinigen

#+
#'### Reguläre Substitutionen

az.out <- dt.download$az


#'**Hinweis**: An dieser Stelle wird eine mysteriöse Unterstrich-Variante mit einem regulären Unterstrich ersetzt. Es ist mir aktuell unklar um was für eine Art von Zeichen es sich handelt und wieso es in den Daten des Bundesgerichtshofs auftaucht. Weil die Code-Zeile zu einem Anzeigefehler in der LaTeX-Kompilierung führt, ist sie im Compilation Report nicht abgedruckt. Sie finden die Zeile im eigentlichen Source Code. Ich arbeite daran, die Anzeige zu vervollständigen.

#+ echo = FALSE
az.out1 <- gsub(" ", "_", az.out)


#+ echo = TRUE
az.out1 <- gsub("\\/", "_", az.out1)

az.out1 <- gsub("_und.*$", "", az.out1)

az.out1 <- gsub("StB_", "NA_StB_", az.out1)
az.out1 <- gsub("StbSt_\\(R\\)", "NA_StbStR", az.out1)
az.out1 <- gsub("StbSt_\\(B\\)", "NA_StbStB", az.out1)

az.out1 <- gsub("PatAnwZ_", "NA_PatAnwZ_", az.out1)

az.out1 <- gsub("AnwZ_\\(Brf[gG]\\)", "NA_AnwZBrfg", az.out1)
az.out1 <- gsub("AK", "NA_AK", az.out1)
az.out1 <- gsub("ARAnw_", "NA_ARAnw_", az.out1)
az.out1 <- gsub("ARs_\\(Voll[zZ]\\)_", "ARsVollz_", az.out1)
az.out1 <- gsub("AR_\\(VZ\\)", "ARVZ", az.out1)
az.out1 <- gsub("AR_\\(VS\\)", "ARVS", az.out1)
az.out1 <- gsub("AR_\\(Ri\\)", "NA_ARRi", az.out1)
az.out1 <- gsub("^AnwSt_\\(B\\)", "NA_AnwStB", az.out1)
az.out1 <- gsub("^AnwSt_\\(R\\)", "NA_AnwStR", az.out1)
az.out1 <- gsub("^PatAnwSt_\\(B\\)", "NA_PatAnwStB", az.out1)
az.out1 <- gsub("^PatAnwSt_\\(R\\)", "NA_PatAnwStR", az.out1)
az.out1 <- gsub("AnwZ_\\(B\\)", "NA_AnwZB", az.out1)
az.out1 <- gsub("AnwZ_\\(P\\)_", "NA_AnwZP_", az.out1)
az.out1 <- gsub("^AnwZ_", "NA_AnwZ_", az.out1)
az.out1 <- gsub("ARNot_", "NA_ARNot_", az.out1)

az.out1 <- gsub("BLw", "NA_BLw", az.out1)

az.out1 <- gsub("En[vV]R_", "NA_EnVR_", az.out1)
az.out1 <- gsub("EnZR_", "NA_EnZR_", az.out1)
az.out1 <- gsub("EnVZ_", "NA_EnVZ_", az.out1)
az.out1 <- gsub("EnZB_", "NA_EnZB_", az.out1)

az.out1 <- gsub("GmS-OGB_", "NA_GMSOGB_", az.out1)
az.out1 <- gsub("GSSt_", "NA_GSSt_", az.out1)
az.out1 <- gsub("GSZ_", "NA_GSZ_", az.out1)

az.out1 <- gsub("KZR_", "NA_KZR_", az.out1)
az.out1 <- gsub("KVZ_", "NA_KVZ_", az.out1)
az.out1 <- gsub("KRB_", "NA_KRB_", az.out1)
az.out1 <- gsub("KZB_", "NA_KZB_", az.out1)
az.out1 <- gsub("KVR_", "NA_KVR_", az.out1)

az.out1 <- gsub("LwZA_", "NA_LwZA_", az.out1)
az.out1 <- gsub("LwZR_", "NA_LwZR_", az.out1)
az.out1 <- gsub("LwZB", "NA_LwZB", az.out1)

az.out1 <- gsub("NotSt_\\(B\\)", "NA_NotStB", az.out1)
az.out1 <- gsub("NotSt_\\(Brfg\\)", "NA_NotStBrfg", az.out1)
az.out1 <- gsub("NotZ_\\(Brfg\\)", "NA_NotZBrfg", az.out1)
az.out1 <- gsub("NotZ_", "NA_NotZ_", az.out1)

az.out1 <- gsub("RiZ_\\(R\\)", "NA_RiZR", az.out1)
az.out1 <- gsub("RiZ\\(R\\)", "NA_RiZR", az.out1)
az.out1 <- gsub("RiZ_\\(B\\)", "NA_RiZB", az.out1)
az.out1 <- gsub("RiZ_", "NA_RiZ_", az.out1)
az.out1 <- gsub("RiSt_\\(R\\)_", "NA_RiStR_", az.out1)
az.out1 <- gsub("RiSt_\\(B\\)_", "NA_RiStB_", az.out1)


az.out1 <- gsub("WpSt_\\(R\\)_", "NA_WpStR_", az.out1)
az.out1 <- gsub("WpSt_\\(B\\)_", "NA_WpStB_", az.out1)

az.out1 <- gsub("VGS_", "NA_VGS_", az.out1)

az.out1 <- gsub("V_I_", "VI_", az.out1)


#'### Einzelne Fehler bereinigen

az.out1 <- gsub("_ZR_\\(Ü\\)_", "_ZRÜ_", az.out1)
az.out1 <- gsub("_\\+_48", "", az.out1)
az.out1 <- gsub("u\\._25_", "", az.out1)
az.out1 <- gsub("_-_28_07", "", az.out1)



az.out1 <- gsub("-[0-9]*_", "_", az.out1)

az.out1 <- gsub("_\\(a\\)", "_a", az.out1)



#'### Variable "zusatz_az" einfügen

indices <- grep("[0-9]*_[A-Za-zÜ]*_[0-9]*_[0-9]*_[a-z]*",
                az.out1,
                invert = TRUE)

values <- grep("[0-9]*_[A-Za-zÜ]*_[0-9]*_[0-9]*_[a-z]*",
               az.out1,
               invert = TRUE,
               value = TRUE)

az.out1[indices] <- paste0(values,
                  "_NA")


#'### Finale Korrekturen
#' Bei der Entscheidung 1 BGs 29/2009 ist als einzige unter allen Entscheidungen das Eingangsjahr vierstellig und nicht zweistellig, auch im Text der Entscheidung selber. Ich gehe dennoch davon aus, das es sich hier um einen Schreibfehler handelt und nehme eine Korrektur vor.

az.out1 <- gsub("1_BGs_29_2009_NA",
                "1_BGs_29_09_NA",
                az.out1)




#'### Strenge REGEX-Validierung des Aktenzeichens

regex.test1 <- grep("[0-9A-Za]+_[A-Za-zÜ]+_[0-9]+_[0-9]{2}_[A-Za-z]+",
                    az.out1,
                    invert = TRUE,
                    value = TRUE)


#'### Ergebnis der REGEX-Validierung
print(regex.test1)


#'### Skript stoppen falls REGEX-Validierung gescheitert

if (length(regex.test1) != 0){
    stop("REGEX VALIDIERUNG GESCHEITERT: AKTENZEICHEN ENTSPRECHEN NICHT DEM CODEBOOK-SCHEMA!")
    }




#'### Aktenzeichen-Vektor in Download Table einfügen
dt.download$az <- az.out1



#'## Spruchkörper bereinigen

#+
#'### Reguläre Substitutionen

#'**Hinweis**: An dieser Stelle wird eine mysteriöse Unterstrich-Variante mit einem regulären Unterstrich ersetzt. Es ist mir aktuell unklar um was für eine Art von Zeichen es sich handelt und wieso es in den Daten des Bundesgerichtshofs auftaucht. Weil die Code-Zeile zu einem Anzeigefehler in der LaTeX-Kompilierung führt, ist sie im Compilation Report nicht abgedruckt. Sie finden die Zeile im eigentlichen Source Code. Ich arbeite daran, die Anzeige zu vervollständigen.

#+ echo = FALSE
spruch1 <- gsub(" ",
                "_",
                dt.download$spruch)


#+ echo = TRUE
spruch1 <- gsub("\\._Zivilsenat",
                "",
                spruch1)

spruch1 <- gsub("\\._Strafsenat",
                "",
                spruch1)

spruch1 <- gsub("Senat_für Anwaltssachen",
                "Anwaltsenat",
                spruch1)

spruch1 <- gsub("Senat_für Landwirtschaftssachen",
                "Landwirtschaftsenat",
                spruch1)

spruch1 <- gsub("Senat_für Notarsachen",
                "Notarsenat",
                spruch1)

spruch1 <- gsub("Dienstgericht des_Bundes",
                "DienstgerichtBund",
                spruch1)

spruch1 <- gsub("Senat_für Wirtschaftsprüfersachen",
                "Wirtschaftsprüfersenat",
                spruch1)

spruch1 <- gsub("Senat_für Steuerberater-_und Steuerbevollmächtigtensachen",
                "Steuerberatersenat",
                spruch1)

spruch1 <- gsub("Gemeinsamer Senat der obersten Gerichtshöfe des Bundes",
                "GemeinsamerSenatObersteGerichtshöfeBund",
                spruch1)

spruch1 <- gsub("Senat_für Patentanwaltssachen",
                "Patentanwaltsenat",
                spruch1)

spruch1 <- gsub("Großer_Senat für_Strafsachen",
                "GrosserStrafsenat",
                spruch1)

spruch1 <- gsub("Großer_Senat für_Zivilsachen",
                "GrosserZivilsenat",
                spruch1)

spruch1 <- gsub("-_Zivilsenat",
                "",
                spruch1)

spruch1 <- gsub("Vereinigte Große_Senate",
                "VereinigteGrosseSenate",
                spruch1)


#'### Alle Spruchkörper anzeigen
print(unique(spruch1))


#'### Spruchkörper-Vektor in Download Table einfügen
dt.download$spruch <- spruch1




#'## Bemerkungen bereinigen

dt.download$comment <- gsub("Leitsaetz",
                            "Leitsatz",
                            dt.download$comment)

dt.download$comment <- gsub("Leitsaz",
                            "Leitsatz",
                            dt.download$comment)

dt.download$comment <- gsub("Leitsazt",
                            "Leitsatz",
                            dt.download$comment)


#'## Variable "leitsatz" erstellen

dt.download$leitsatz <- ifelse(grepl("Leitsatz",
                                     dt.download$comment),
                               "LE",
                               "NA")




#'## Variable "name" erstellen


name <- sub("(.*)\r\n.*",
            "\\1",
            dt.download$comment)

name[grepl("Leitsatz|Pressemitteilung|Berichtigung",
           name,
           ignore.case = TRUE)] <- NA

name[grepl("^$", name)] <- NA

dt.download$name <- name




#'## Variable "name_datei" erstellen

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

dt.download$name_datei <- name_datei







#'## Dateinamen erstellen

filename <- paste("BGH",
                  dt.download$spruch,
                  dt.download$leitsatz,
                  dt.download$datum,
                  dt.download$az,
                  dt.download$name_datei,
                  sep="_")



#'## Einzelkorrektur vornehmen

filename <- gsub("BGH_3_([NALE]{2})_NA_NA_AK_13_19_NA",
                  "BGH_3_\\1_2019-05-07_NA_AK_13_19_NA",
                  filename)






#'## KollisionsID einfügen

#'### Anzahl Duplikate
length(filename[duplicated(filename)])


#'### Kollisions-IDs vergeben
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

#'## Zufällige Auswahl zur Prüfung anzeigen
filenames1[sample(length(filenames1), 50)]


#'## PDF-Endung anfügen
filenames2 <- paste0(filenames1,
                    ".pdf")




#'## Strenge REGEX-Validierung: Gesamter Dateiname

regex.test2 <-grep("BGH_.*_[NALE]{2}_[0-9]{4}-[0-9]{2}-[0-9]{2}_[A-Za-z0-9]*_[A-Za-zÜ]*_[0-9-]*_[0-9]{2}_[A-Za-z]*_.*_[NA0-9]*.pdf",
     filenames2,
     value = TRUE,
     invert = TRUE)


#'## Ergebnis der REGEX-Validierung
print(regex.test2)


#'## Skript stoppen falls REGEX-Validierung gescheitert

if (length(regex.test2) != 0){
    stop("REGEX VALIDIERUNG GESCHEITERT: DATEINAMEN ENTSPRECHEN NICHT DEM CODEBOOK-SCHEMA!")
    }



#'## Vollen Dateinamen in Download Table einfügen
dt.download$filenames.final <- filenames2









#'# Download der Entscheidungen im PDF-Format

#+
#'## [Debugging Modus] Reduzierung des Download-Umfangs

if (mode.debug == TRUE){
    dt.download <- dt.download[sample(.N,
                                      debug.sample)]
    }



#'## Zeitstempel: Download Beginn

begin.download <- Sys.time()
print(begin.download)


#'## Download durchführen


for (i in sample(dt.download[,.N])){
        tryCatch({download.file(url = dt.download$link[i],
                                destfile = dt.download$filenames.final[i])
        },
        error = function(cond) {
            return(NA)}
        )
        Sys.sleep(runif(1, 0, 0.1))
}



#'## Zeitstempel: Download Ende

end.download <- Sys.time()
print(end.download)


#'## Dauer: Download 
end.download - begin.download





#'## [Debugging Modus] Löschen zufälliger Dateien
#' Dient dazu den Wiederholungsversuch zu testen.

if (mode.debug == TRUE){
    files.pdf <- list.files(pattern = "\\.pdf")
    unlink(sample(files.pdf, 5))
    }



#'## Download: Zwischenergebnis

#+
#'### Anzahl herunterzuladender Dateien
dt.download[,.N]

#'### Anzahl heruntergeladener Dateien
files.pdf <- list.files(pattern = "\\.pdf")
length(files.pdf)

#'### Fehlbetrag
N.missing <- dt.download[,.N] - length(files.pdf)
print(N.missing)

#'### Fehlende Dateien
missing <- setdiff(dt.download$filenames.final, files.pdf)
print(missing)








#'## Wiederholungsversuch: Download
#' Download für fehlende Dokumente wiederholen.

if(N.missing > 0){

    dt.retry <- dt.download[filenames.final %in% missing]
    
    for (i in 1:dt.retry[,.N]){
        response <- GET(dt.retry$link[i])
        Sys.sleep(runif(1, 0.25, 0.75))
        if (response$headers$"content-type" == "application/pdf" & response$status_code == 200){
            tryCatch({download.file(url = dt.retry$link[i],
                                    destfile = dt.retry$filenames.final[i])
            },
            error=function(cond) {
                return(NA)}
            )     
        }else{
            print(paste0(dt.retry$filenames.final[i], " : kein PDF vorhanden"))  
        }
        Sys.sleep(runif(1, 2, 5))
    } 
}






#'## Download: Gesamtergebnis

#+
#'### Anzahl herunterzuladender Dateien
dt.download[,.N]

#'### Anzahl heruntergeladener Dateien
files.pdf <- list.files(pattern = "\\.pdf")
length(files.pdf)

#'### Fehlbetrag
N.missing <- dt.download[,.N] - length(files.pdf)
print(N.missing)

#'### Fehlende Dateien
missing <- setdiff(dt.download$filenames.final, files.pdf)
print(missing)







#+
#'# Text-Extraktion

#+
#'## Vektor der zu extrahierenden Dateien erstellen

files.pdf <- list.files(pattern = "\\.pdf$",
                        ignore.case = TRUE)


#'## Anzahl zu extrahierender Dateien
length(files.pdf)


#'## Seiten zählen: Funktion anzeigen
#+ results = "asis"
print(f.dopar.pagenums)


#'## Anzahl zu extrahierender Seiten
f.dopar.pagenums(files.pdf,
                 sum = TRUE,
                 threads = fullCores)



#'## PDF extrahieren: Funktion anzeigen
#+ results = "asis"
print(f.dopar.pdfextract)


#'## Text Extrahieren
result <- f.dopar.pdfextract(files.pdf,
                             threads = fullCores)






#'# Korpus Erstellen

#+
#'## TXT-Dateien Einlesen


txt.bgh <- readtext("./*.txt",
                    docvarsfrom = "filenames", 
                    docvarnames = c("gericht",
                                    "spruchkoerper_db",
                                    "leitsatz",
                                    "datum",
                                    "spruchkoerper_az",
                                    "registerzeichen",
                                    "eingangsnummer",
                                    "eingangsjahr_az",
                                    "zusatz_az",
                                    "name",
                                    "kollision"),
                    dvsep = "_", 
                    encoding = "UTF-8")




#'## In Data Table umwandeln
setDT(txt.bgh)




#'## Durch Zeilenumbruch getrennte Wörter zusammenfügen
#' Durch Zeilenumbrüche getrennte Wörter stellen bei aus PDF-Dateien gewonnene Text-Korpora ein erhebliches Problem dar. Wörter werden dadurch in zwei sinnentleerte Tokens getrennt, statt ein einzelnes und sinnvolles Token zu bilden. Dieser Schritt entfernt die Bindestriche, den Zeilenumbruch und ggf. dazwischenliegende Leerzeichen.

#+
#'### Funktion anzeigen
print(f.hyphen.remove)

#'### Funktion ausführen
txt.bgh[, text := lapply(.(text), f.hyphen.remove)]


#'## Variable "datum" als Datentyp "IDate" kennzeichnen
txt.bgh$datum <- as.IDate(txt.bgh$datum)




#'## Variable "entscheidungsjahr" hinzufügen
txt.bgh$entscheidungsjahr <- year(txt.bgh$datum)


#'## Variable "eingangsjahr_iso" hinzufügen
txt.bgh$eingangsjahr_iso <- f.year.iso(txt.bgh$eingangsjahr_az)





#'## Datensatz nach Datum sortieren
#' Die Erstellung der Variablen für Präsident:innen und Vize-Präsident:innen trifft die starke Annahme, dass eine aufsteigende Sortierung nach Datum besteht. Wäre das nicht der Fall, würden dort Fehler auftreten.

setorder(txt.bgh,
         datum)




#'## Variable "praesi" hinzufügen
#' Diese Variable dokumentiert für jede Entscheidung welche/r Präsident:in am Tag der Entscheidung im Amt war.

#+
#'### Personaldaten einlesen

praesi <- fread("PVP-FCG_2021-04-08_GermanFederalCourts_Presidents.csv")
praesi <- praesi[court == "BGH", c(1:3, 5:6)]



#'### Personaldaten anzeigen

kable(praesi,
      format = "latex",
      align = "r",
      booktabs = TRUE,
      longtable = TRUE) %>% kable_styling(latex_options = "repeat_header")



#'### Hypothethisches Amtsende für Präsident:in
#' Weil der/die aktuelle Präsident:in noch im Amt ist, ist der Wert für das Amtsende "NA". Dieser ist aber für die verwendete Logik nicht greifbar, weshalb an dieser Stelle ein hypothetisches Amtsende in einem Jahr ab dem Tag der Datensatzerstellung fingiert wird. Es wird nur an dieser Stelle verwendet und danach verworfen.

praesi[is.na(term_end_date)]$term_end_date <- Sys.Date() + 365


#'### Schleife vorbereiten

N <- praesi[,.N]

praesi.list <- vector("list", N)


#'### Vektor erstellen

for (i in seq_len(N)){
    praesi.N <- txt.bgh[datum >= praesi$term_begin_date[i] & datum <= praesi$term_end_date[i], .N]
    praesi.list[[i]] <- rep(praesi$name_last[i],
                            praesi.N)
}



#'### Vektor einfügen

txt.bgh$praesi <- unlist(praesi.list)







#'## Variable "v_praesi" hinzufügen
#' Diese Variable dokumentiert für jede Entscheidung welche/r Vize-Präsident:in am Tag der Entscheidung im Amt war.


#+
#'### Personaldaten einlesen

vpraesi <- fread("PVP-FCG_2021-04-08_GermanFederalCourts_VicePresidents.csv")
vpraesi <- vpraesi[court == "BGH", c(1:3, 5:6)]



#'### Personaldaten anzeigen

kable(vpraesi,
      format = "latex",
      align = "r",
      booktabs = TRUE,
      longtable = TRUE) %>% kable_styling(latex_options = "repeat_header")




#'### Hypothethisches Amtsende für Vize-Präsident:in
#' Weil der/die aktuelle Vize-Präsident:in noch im Amt ist, ist der Wert für das Amtsende "NA". Dieser ist aber für die verwendete Logik nicht greifbar, weshalb an dieser Stelle ein hypothetisches Amtsende in einem Jahr ab dem Tag der Datensatzerstellung fingiert wird. Es wird nur an dieser Stelle verwendet und danach verworfen.

vpraesi[is.na(term_end_date)]$term_end_date <- Sys.Date() + 365


#'### Schleife vorbereiten

N <- vpraesi[,.N]

vpraesi.list <- vector("list", N)



#'### Vektor erstellen

for (i in seq_len(N)){
    vpraesi.N <- txt.bgh[datum >= vpraesi$term_begin_date[i] & datum <= vpraesi$term_end_date[i], .N]
    vpraesi.list[[i]] <- rep(vpraesi$name_last[i],
                            vpraesi.N)
}




#'### Vektor einfügen

txt.bgh$v_praesi <- unlist(vpraesi.list)










#'## Variable "verfahrensart" hinzufügen
#'Die Registerzeichen werden an dieser Stelle mit ihren detaillierten Bedeutungen aus dem folgenden Datensatz abgeglichen: "Seán Fobbe (2021). Aktenzeichen der Bundesrepublik Deutschland (AZ-BRD). Version 1.0.1. Zenodo. DOI: 10.5281/zenodo.4569564." Das Ergebnis des Abgleichs wird in der Variable "verfahrensart" in den Datensatz eingefügt.



#+
#'### Datensatz einlesen
az.source <- fread("AZ-BRD_1-0-1_DE_Registerzeichen_Datensatz.csv")




#'### Datensatz auf relevante Daten reduzieren
az.bgh <- az.source[stelle == "BGH" & position == "hauptzeichen"]


#'### Indizes bestimmen
targetindices <- match(txt.bgh$registerzeichen,
                       az.bgh$zeichen_code)

#'### Vektor der Verfahrensarten erstellen und einfügen
txt.bgh$verfahrensart <- az.bgh$bedeutung[targetindices]





#'## Variable "aktenzeichen" hinzufügen

txt.bgh$aktenzeichen <- paste0(txt.bgh$spruchkoerper_az,
                                  " ",
                               mgsub(txt.bgh$registerzeichen,
                                     az.bgh$zeichen_code,
                                     az.bgh$zeichen_original),
                               " ",
                               txt.bgh$eingangsnummer,
                               "/",
                               txt.bgh$eingangsjahr_az)


txt.bgh$aktenzeichen <- gsub("NA ",
                             "",
                             txt.bgh$aktenzeichen)



#'## Variable "entscheidung_typ" hinzufügen


#+
#'### Entscheidungen Parsen
matches <- regexpr("BESCHLUSS|URTEIL|VERFÜGUNG",
                   txt.bgh$text,
                   ignore.case = TRUE)


#'### Indizes bestimmen

matches.logical <- ifelse(matches > 0,
                          TRUE,
                          FALSE)

matches.indices <- which(matches.logical)



#'### Leeren Vektor erstellen

entscheidung_typ <- rep(NA,
                        txt.bgh[,.N])


#'### Typen bei Indizes platzieren

entscheidung_typ[matches.indices] <- regmatches(txt.bgh$text,
                                                matches)


#'### Typen auf Kurzform reduzieren

entscheidung_typ  <- gsub("URTEIL",
                          "U",
                          entscheidung_typ,
                          ignore.case = TRUE)

entscheidung_typ  <- gsub("BESCHLUSS",
                          "B",
                          entscheidung_typ,
                          ignore.case = TRUE)


entscheidung_typ  <- gsub("VERFÜGUNG",
                          "V",
                          entscheidung_typ,
                          ignore.case = TRUE)


#'### Vektor in Datensatz einfügen

txt.bgh$entscheidung_typ <- entscheidung_typ







#'## Variable "ecli" hinzufügen
#' Struktur und Inhalt der ECLI für deutsche Gerichte sind auf dem Europäischen Justizportal näher erläutert. \footnote{\url{https://e-justice.europa.eu/content_european_case_law_identifier_ecli-175-de-de.do?member=1}}
#'
#' Sofern die Variablen korrekt extrahiert wurden lässt sich die ECLI vollständig rekonstruieren.
#'
#' **ACHTUNG:** diese ECLIs sind experimentell. Der BGH vergibt offiziell ECLI-Identifikatoren nur für Entscheidungen ab 2016. Ausserdem steht die originale Kollisions-ID nicht zur Verfügung. Alle Entscheidungen mit einer Kollisions-ID größer 0 und ihre korrespondierenden Entscheidungen mit der ID 0 haben potenziell syntaktisch korrekte, aber semantisch fehlerhafte ECLIs.


#+
#'### Formatieren der Registerzeichen für ECLI

ecli.registerzeichen <- az.bgh$zeichen_original[targetindices]

ecli.registerzeichen <- gsub("\\(",
                             "\\.",
                             ecli.registerzeichen)

ecli.registerzeichen <- gsub(")",
                             "",
                             ecli.registerzeichen)

ecli.registerzeichen <- toupper(ecli.registerzeichen)





#'### Erstellen der ECLI-Ordinalzahl

ecli.ordinalzahl <- paste0(format(txt.bgh$datum,
                                  "%d%m%y"),
                           txt.bgh$entscheidung_typ,
                           ifelse(is.na(txt.bgh$spruchkoerper_az),
                                  "",
                                  txt.bgh$spruchkoerper_az),
                           ecli.registerzeichen,
                           txt.bgh$eingangsnummer,
                           ".",
                           formatC(txt.bgh$eingangsjahr_az,
                                   width = 2,
                                   flag = "0"),
                           ".",
                           txt.bgh$kollision)




#'### Vollständige ECLI erstellen

txt.bgh$ecli <- paste0("ECLI:DE:BGH:",
                          txt.bgh$entscheidungsjahr,
                          ":",
                          ecli.ordinalzahl)


#'### Zufällige ECLI-Beispiele zur manuellen Nachprüfung

sample(txt.bgh$ecli,
       20)






#'## Variable "bemerkung" hinzufügen

dt.names.txt <- gsub("\\.pdf",
                     "\\.txt",
                     dt.download$filenames.final)

targetindices <- match(txt.bgh$doc_id,
                       dt.names.txt)

txt.bgh$bemerkung <- dt.download[targetindices]$comment



#'## Variable "berichtigung" hinzufügen

txt.bgh$berichtigung <- ifelse(grepl("Berichtigung",
                                     txt.bgh$bemerkung,
                                     ignore.case = TRUE),
                               "Berichtigung",
                               NA)




#'## Variable "leitsatz" hinzufügen
txt.bgh$leitsatz <- dt.download[targetindices]$leitsatz
##---- ACHTUNG Dopplung mit Dateinamen---


#'## Variable "name" hinzufügen
txt.bgh$name <- dt.download[targetindices]$name
##---- ACHTUNG Dopplung mit Dateinamen---





#'## Variable "doi_concept" hinzufügen
txt.bgh$doi_concept <- rep(doi.concept,
                       txt.bgh[,.N])


#'## Variable "doi_version" hinzufügen
txt.bgh$doi_version <- rep(doi.version,
                       txt.bgh[,.N])


#'## Variable "version" hinzufügen
txt.bgh$version <- as.character(rep(datestamp,
                                txt.bgh[,.N]))

#'## Variable "lizenz" hinzufügen
txt.bgh$lizenz <- as.character(rep(license,
                                   txt.bgh[,.N]))






#'## Entfernen von Dokumenten ohne Typ/Name/Berichtigung
#' Dokumente ohne Typ, Name oder Berichtigung sind fast immer Platzhalter-Dokumente, die auf den Push-Service der Universität des Saarlandes hinweisen. Diese werden am Ende des Variablen-Abschnitts aus der CSV-Datei entfernt und die PDF- und TXT-Dateien zur weiteren Prüfung separat gespeichert.



#+
#'### Platzhalter-Dokumente definieren
#' Dokumente ohne Typ, Name und Berichtigung sind fast immer Platzhalter-Dokumente, die keine Begründung enthalten und/oder auf den Push-Service der Universität des Saarlandes hinweisen. Diese werden am Ende dieses Abschnitts entfernt.

placeholder.txt <- txt.bgh[is.na(entscheidung_typ) == TRUE & is.na(name) == TRUE & is.na(berichtigung) == TRUE]$doc_id



#'### Einzelkorrektur
#' Das folgende Dokument ist nach Extraktion ein leeres Text-Dokument, im originalen PDF aber ein funktionaler Scan. Es wird temporär vom Datensatz ausgeschlossen damit keine Fehler in der Zählung linguistischer Kennzahlen auftreten. In Zukunft wird ein OCR-Modul hierfür eingerichtet.


if (file.exists("BGH_I_LE_2006-07-13_I_ZR_241_03_NA_Kontaktanzeigen_0.txt") == TRUE){

placeholder.txt <- c(placeholder.txt,
                     "BGH_I_LE_2006-07-13_I_ZR_241_03_NA_Kontaktanzeigen_0.txt")

}


#+
#'### Dokumente ohne Typ, Name und Berichtigung anzeigen
print(placeholder.txt)


#'### PDF-Namen definieren

placeholder.pdf <- gsub("\\.txt",
                        "\\.pdf",
                        placeholder.txt)



#'### Platzhalter PDF/TXT speichern
dir.create("PlatzhalterDokumente")

file_move(placeholder.txt,
          "PlatzhalterDokumente")

file_move(placeholder.pdf,
          "PlatzhalterDokumente")


#'### Platzhalter aus Datensatz entfernen
txt.bgh <- txt.bgh[!(doc_id %in% placeholder.txt)]









#'# Frequenztabellen erstellen

#+
#'## Funktion anzeigen
print(f.fast.freqtable)


#'## Ignorierte Variablen
print(varremove)



#'## Liste zu prüfender Variablen

varlist <- names(txt.bgh)
varlist <- grep(paste(varremove,
                      collapse="|"),
                varlist,
                invert = TRUE,
                value = TRUE)
print(varlist)


#'## Präfix definieren

prefix <- paste0(datasetname,
                 "_01_Frequenztabelle_var-")



#'## Frequenztabellen berechnen


#+ results = "asis"
f.fast.freqtable(txt.bgh,
                 varlist = varlist,
                 sumrow = TRUE,
                 output.list = FALSE,
                 output.kable = TRUE,
                 output.csv = TRUE,
                 outputdir = outputdir,
                 prefix = prefix,
                 align = c("p{5cm}",
                           rep("r", 4)))






#'# Frequenztabellen visualisieren

#'## Präfix erstellen

prefix <- paste0("ANALYSE/",
                 datasetname,
                 "_01_Frequenztabelle_var-")



#'## Tabellen einlesen


table.entsch.typ <- fread(paste0(prefix,
                                 "entscheidung_typ.csv"))

table.spruch.db <- fread(paste0(prefix,
                                "spruchkoerper_db.csv"))

table.spruch.az <- fread(paste0(prefix,
                                "spruchkoerper_az.csv"))

table.regz <- fread(paste0(prefix,
                           "registerzeichen.csv"))

table.jahr.eingangISO <- fread(paste0(prefix,
                                      "eingangsjahr_iso.csv"))

table.jahr.entscheid <- fread(paste0(prefix,
                                     "entscheidungsjahr.csv"))


table.output.praesi <- fread(paste0(prefix,
                                    "praesi.csv"))

table.output.vpraesi <- fread(paste0(prefix,
                                     "v_praesi.csv"))




#'\newpage
#'## Diagramm: Typ der Entscheidung

freqtable <- table.entsch.typ[-.N]


#+ CE-BGH_02_Barplot_Entscheidungstyp, fig.height = 5, fig.width = 8
ggplot(data = freqtable) +
    geom_bar(aes(x = reorder(entscheidung_typ,
                             -N),
                 y = N),
             stat = "identity",
             fill = "#7e0731",
             color = "black",
             width = 0.5) +
    theme_bw() +
    labs(
        title = paste(datasetname,
                      "| Version",
                      datestamp,
                      "| Entscheidungen je Typ"),
        caption = paste("DOI:",
                        doi.version),
        x = "Typ der Entscheidung",
        y = "Entscheidungen"
    )+
    theme(
        text = element_text(size = 14),
        plot.title = element_text(size = 14,
                                  face = "bold"),
        legend.position = "none",
        plot.margin = margin(10, 20, 10, 10)
    )


#'\newpage
#'## Diagramm: Spruchkörper nach Datenbank

freqtable <- table.spruch.db[-.N]


#+ CE-BGH_03_Barplot_Spruchkoerper_DB, fig.height = 12, fig.width = 8
ggplot(data = freqtable) +
    geom_bar(aes(x = reorder(spruchkoerper_db,
                             N),
                 y = N),
             stat = "identity",
             fill = "#7e0731",
             color = "black",
             width = 0.5) +
    coord_flip()+
    theme_bw() +
    labs(
        title = paste(datasetname,
                      "| Version",
                      datestamp,
                      "| Entscheidungen je Senat (DB)"),
        caption = paste("DOI:",
                        doi.version),
        x = "Senat",
        y = "Entscheidungen"
    )+
    theme(
        text = element_text(size = 14),
        plot.title = element_text(size = 14,
                                  face = "bold"),
        legend.position = "none",
        plot.margin = margin(10, 20, 10, 10)
    )





#'\newpage
#'## Diagramm: Spruchkörper nach Aktenzeichen

freqtable <- table.spruch.az[-.N]


#+ CE-BGH_03_Barplot_Spruchkoerper_AZ, fig.height = 5, fig.width = 8
ggplot(data = freqtable) +
    geom_bar(aes(x = reorder(spruchkoerper_az,
                             -N),
                 y = N),
             stat = "identity",
             fill = "#7e0731",
             color = "black",
             width = 0.5) +
    theme_bw() +
    labs(
        title = paste(datasetname,
                      "| Version",
                      datestamp,
                      "| Entscheidungen je Senat (Aktenzeichen)"),
        caption = paste("DOI:",
                        doi.version),
        x = "Senat",
        y = "Entscheidungen"
    )+
    theme(
        text = element_text(size = 14),
        plot.title = element_text(size = 14,
                                  face = "bold"),
        legend.position = "none",
        plot.margin = margin(10, 20, 10, 10)
    )





#'\newpage
#'## Diagramm: Registerzeichen

freqtable <- table.regz[-.N]

#+ CE-BGH_04_Barplot_Registerzeichen, fig.height = 14, fig.width = 10
ggplot(data = freqtable) +
    geom_bar(aes(x = reorder(registerzeichen,
                             N),
                 y = N),
             stat = "identity",
             fill = "#7e0731",
             color = "black") +
    coord_flip()+
    theme_bw() +
    labs(
        title = paste(datasetname,
                      "| Version",
                      datestamp,
                      "| Entscheidungen je Registerzeichen"),
        caption = paste("DOI:",
                        doi.version),
        x = "Registerzeichen",
        y = "Entscheidungen"
    )+
    theme(
        text = element_text(size = 14),
        plot.title = element_text(size = 14,
                                  face = "bold"),
        legend.position = "none",
        plot.margin = margin(10, 20, 10, 10)
    )





#'\newpage
#'## Diagramm: Präsident:in

freqtable <- table.output.praesi[-.N]

#+ CE-BGH_05_Barplot_PraesidentIn, fig.height = 5.5, fig.width = 8
ggplot(data = freqtable) +
    geom_bar(aes(x = reorder(praesi,
                             N),
                 y = N),
             stat = "identity",
             fill = "#7e0731",
             color = "black") +
    coord_flip()+
    theme_bw() +
    labs(
        title = paste(datasetname,
                      "| Version",
                      datestamp,
                      "| Entscheidungen je Präsident:in"),
        caption = paste("DOI:",
                        doi.version),
        x = "Präsident:in",
        y = "Entscheidungen"
    )+
    theme(
        axis.title.y = element_blank(),
        text = element_text(size = 14),
        plot.title = element_text(size = 14,
                                  face = "bold"),
        legend.position = "none",
        plot.margin = margin(10, 20, 10, 10)
    )





#'\newpage
#'## Diagramm: Vize-Präsident:in

freqtable <- table.output.vpraesi[-.N]

#+ CE-BGH_06_Barplot_VizePraesidentIn, fig.height = 5.5, fig.width = 8
ggplot(data = freqtable) +
    geom_bar(aes(x = reorder(v_praesi,
                             N),
                 y = N),
             stat = "identity",
             fill = "#7e0731",
             color = "black") +
    coord_flip()+
    theme_bw() +
    labs(
        title = paste(datasetname,
                      "| Version",
                      datestamp,
                      "| Entscheidungen je Vize-Präsident:in"),
        caption = paste("DOI:",
                        doi.version),
        x = "Vize-Präsident:in",
        y = "Entscheidungen"
    )+
    theme(
        axis.title.y = element_blank(),
        text = element_text(size = 14),
        plot.title = element_text(size = 14,
                                  face = "bold"),
        legend.position = "none",
        plot.margin = margin(10, 20, 10, 10)
    )



#'\newpage
#'## Diagramm: Entscheidungsjahr

freqtable <- table.jahr.entscheid[-.N][,lapply(.SD, as.numeric)]

#+ CE-BGH_07_Barplot_Entscheidungsjahr, fig.height = 7, fig.width = 11
ggplot(data = freqtable) +
    geom_bar(aes(x = entscheidungsjahr,
                 y = N),
             stat = "identity",
             fill = "#7e0731") +
    theme_bw() +
    labs(
        title = paste(datasetname,
                      "| Version",
                      datestamp,
                      "| Entscheidungen je Entscheidungsjahr"),
        caption = paste("DOI:",
                        doi.version),
        x = "Entscheidungsjahr",
        y = "Entscheidungen"
    )+
    theme(
        text = element_text(size = 16),
        plot.title = element_text(size = 16,
                                  face = "bold"),
        legend.position = "none",
        plot.margin = margin(10, 20, 10, 10)
    )



#'\newpage
#'## Diagramm: Eingangsjahr (ISO)

freqtable <- table.jahr.eingangISO[-.N][,lapply(.SD, as.numeric)]



#+ CE-BGH_08_Barplot_EingangsjahrISO, fig.height = 7, fig.width = 11
ggplot(data = freqtable) +
    geom_bar(aes(x = eingangsjahr_iso,
                 y = N),
             stat = "identity",
             fill = "#7e0731") +
    theme_bw() +
    labs(
        title = paste(datasetname,
                      "| Version",
                      datestamp,
                      "| Entscheidungen je Eingangsjahr (ISO)"),
        caption = paste("DOI:",
                        doi.version),
        x = "Eingangsjahr (ISO)",
        y = "Entscheidungen"
    )+
    theme(
        text = element_text(size = 16),
        plot.title = element_text(size = 16,
                                  face = "bold"),
        legend.position = "none",
        plot.margin = margin(10, 20, 10, 10)
    )











#'# Korpus-Analytik
#'

#+
#'## Berechnung linguistischer Kennwerte
#' An dieser Stelle werden für jedes Dokument die Anzahl Zeichen, Tokens, Typen und Sätze berechnet und mit den jeweiligen Metadaten verknüpft. Das Ergebnis ist grundsätzlich identisch mit dem eigentlichen Datensatz, nur ohne den Text der Entscheidungen.


#+
#'### Funktion anzeigen
print(f.summarize.iterator,
      threads = fullCores,
      chunksize = 1)


#'### Berechnung durchführen
summary.corpus <- f.summarize.iterator(txt.bgh)





#'### Variablen-Namen anpassen

setnames(summary.corpus,
         old = c("nchars",
                 "ntokens",
                 "ntypes",
                 "nsentences"),
         new = c("zeichen",
                 "tokens",
                 "typen",
                 "saetze"))

setnames(txt.bgh,
         old = "nchars",
         new = "zeichen")


#'### Kennwerte dem Korpus hinzufügen

txt.bgh$zeichen <- summary.corpus$zeichen
txt.bgh$tokens <- summary.corpus$tokens
txt.bgh$typen <- summary.corpus$typen
txt.bgh$saetze <- summary.corpus$saetze





#'\newpage
#'## Zusammenfasssungen: Linguistische Kennwerte
#' **Hinweis:** Typen sind definiert als einzigartige Tokens und werden für jedes Dokument gesondert berechnet. Daher ergibt es an dieser Stelle auch keinen Sinn die Typen zu summieren, denn bezogen auf den Korpus wäre der Kennwert ein anderer. Der Wert wird daher manuell auf "NA" gesetzt.

#+
#'### Zusammenfassungen berechnen

dt.summary.ling <- summary.corpus[, lapply(.SD,
                                           function(x)unclass(summary(x))),
                                  .SDcols = c("zeichen",
                                              "tokens",
                                              "saetze",
                                              "typen")]


dt.sums.ling <- summary.corpus[,
                               lapply(.SD, sum),
                               .SDcols = c("zeichen",
                                           "tokens",
                                           "saetze",
                                           "typen")]

dt.sums.ling$typen <- NA




dt.stats.ling <- rbind(dt.sums.ling,
                       dt.summary.ling)

dt.stats.ling <- transpose(dt.stats.ling,
                           keep.names = "names")


setnames(dt.stats.ling, c("Variable",
                          "Sum",
                          "Min",
                          "Quart1",
                          "Median",
                          "Mean",
                          "Quart3",
                          "Max"))



#'### Zusammenfassungen anzeigen

kable(dt.stats.ling,
      format.args = list(big.mark = ","),
      format = "latex",
      booktabs = TRUE,
      longtable = TRUE)




#'### Zusammenfassungen speichern

fwrite(dt.stats.ling,
       paste0(outputdir,
              datasetname,
              "_00_KorpusStatistik_ZusammenfassungLinguistisch.csv"),
       na = "NA")




#'\newpage
#'## Zusammenfassungen: Quantitative Variablen


#+
#'### Entscheidungsdatum

summary(as.IDate(summary.corpus$datum))



#'### Zusammenfassungen berechnen

dt.summary.docvars <- summary.corpus[,
                                     lapply(.SD, function(x)unclass(summary(na.omit(x)))),
                                     .SDcols = c("entscheidungsjahr",
                                                 "eingangsjahr_iso",
                                                 "eingangsnummer")]


dt.unique.docvars <- summary.corpus[,
                                    lapply(.SD, function(x)length(unique(na.omit(x)))),
                                    .SDcols = c("entscheidungsjahr",
                                                "eingangsjahr_iso",
                                                "eingangsnummer")]


dt.stats.docvars <- rbind(dt.unique.docvars,
                          dt.summary.docvars)

dt.stats.docvars <- transpose(dt.stats.docvars,
                              keep.names = "names")


setnames(dt.stats.docvars, c("Variable",
                             "Einzigartig",
                             "Min",
                             "Quart1",
                             "Median",
                             "Mean",
                             "Quart3",
                             "Max"))



#'### Zusammenfassungen anzeigen

kable(dt.stats.docvars,
      format = "latex",
      booktabs = TRUE,
      longtable = TRUE)



#'### Zusammenfassungen speichern

fwrite(dt.stats.docvars,
       paste0(outputdir,
              datasetname,
              "_00_KorpusStatistik_ZusammenfassungDocvarsQuantitativ.csv"),
       na = "NA")






#'\newpage
#'## Verteilungen linguistischer Kennwerte

#+
#'### Diagramm: Verteilung Zeichen

#+ CE-BGH_09_Density_Zeichen, fig.height = 6, fig.width = 9
ggplot(data = summary.corpus)+
    geom_density(aes(x = zeichen),
                 fill = "#7e0731")+
    scale_x_log10(breaks = trans_breaks("log10", function(x) 10^x),
                  labels = trans_format("log10", math_format(10^.x)))+
    annotation_logticks(sides = "b")+
    coord_cartesian(xlim = c(1, 10^6))+
    theme_bw()+
    labs(
        title = paste(datasetname,
                      "| Version",
                      datestamp,
                      "| Verteilung der Zeichen je Dokument"),
        caption = paste("DOI:",
                        doi.version),
        x = "Zeichen",
        y = "Dichte"
    )+
    theme(
        text = element_text(size = 14),
        plot.title = element_text(size = 14,
                                  face = "bold"),
        legend.position = "none",
        plot.margin = margin(10, 20, 10, 10)
    )



#+
#'### Diagramm: Verteilung Tokens

#+ CE-BGH_10_Density_Tokens, fig.height = 6, fig.width = 9
ggplot(data = summary.corpus)+
    geom_density(aes(x = tokens),
                 fill = "#7e0731")+
    scale_x_log10(breaks = trans_breaks("log10", function(x) 10^x),
                  labels = trans_format("log10", math_format(10^.x)))+
    annotation_logticks(sides = "b")+
    coord_cartesian(xlim = c(1, 10^6))+
    theme_bw()+
    labs(
        title = paste(datasetname,
                      "| Version",
                      datestamp,
                      "| Verteilung der Tokens je Dokument"),
        caption = paste("DOI:",
                        doi.version),
        x = "Tokens",
        y = "Dichte"
    )+
    theme(
        text = element_text(size = 14),
        plot.title = element_text(size = 14,
                                  face = "bold"),
        legend.position = "none",
        plot.margin = margin(10, 20, 10, 10)
    )




#'\newpage
#'### Diagramm: Verteilung Typen

#+ CE-BGH_11_Density_Typen, fig.height = 6, fig.width = 9
ggplot(data = summary.corpus)+
    geom_density(aes(x = typen),
                 fill = "#7e0731")+
    scale_x_log10(breaks = trans_breaks("log10", function(x) 10^x),
                  labels = trans_format("log10", math_format(10^.x)))+
    annotation_logticks(sides = "b")+
    coord_cartesian(xlim = c(1, 10^6))+
    theme_bw()+
    labs(
        title = paste(datasetname,
                      "| Version",
                      datestamp,
                      "| Verteilung der Typen je Dokument"),
        caption = paste("DOI:",
                        doi.version),
        x = "Typen",
        y = "Dichte"
    )+
    theme(
        text = element_text(size = 14),
        plot.title = element_text(size = 14,
                                  face = "bold"),
        legend.position = "none",
        plot.margin = margin(10, 20, 10, 10)
    )



#'\newpage
#'### Diagramm: Verteilung Sätze

#+ CE-BGH_12_Density_Saetze, fig.height = 6, fig.width = 9
ggplot(data = summary.corpus)+
    geom_density(aes(x = saetze),
                 fill = "#7e0731")+
    scale_x_log10(breaks = trans_breaks("log10", function(x) 10^x),
                  labels = trans_format("log10", math_format(10^.x)))+
    annotation_logticks(sides = "b")+
    coord_cartesian(xlim = c(1, 10^6))+
    theme_bw()+
    labs(
        title = paste(datasetname,
                      "| Version",
                      datestamp,
                      "| Verteilung der Sätze je Dokument"),
        caption = paste("DOI:",
                        doi.version),
        x = "Sätze",
        y = "Dichte"
    )+
    theme(
        text = element_text(size = 14),
        plot.title = element_text(size = 14,
                                  face = "bold"),
        legend.position = "none",
        plot.margin = margin(10, 20, 10, 10)
    )




#'## Anzahl Variablen im Korpus
length(txt.bgh)


#'## Namen der Variablen im Korpus
names(txt.bgh)







#'# CSV-Dateien erstellen

#+
#'## CSV mit vollem Datensatz speichern

csvname.full <- paste(datasetname,
                      datestamp,
                      "DE_CSV_Datensatz.csv",
                      sep = "_")

fwrite(txt.bgh,
       csvname.full,
       na = "NA")




#'## CSV mit Metadaten speichern
#' Diese Datei ist grundsätzlich identisch mit dem eigentlichen Datensatz, nur ohne den Text der Entscheidungen.

csvname.meta <- paste(datasetname,
                      datestamp,
                      "DE_CSV_Metadaten.csv",
                      sep = "_")

fwrite(summary.corpus,
       csvname.meta,
       na = "NA")





#'# Dateigrößen analysieren

#+
#'## Gesamtgröße

#+
#'### Korpus-Objekt in RAM (MB)

print(object.size(corpus(txt.bgh)),
      standard = "SI",
      humanReadable = TRUE,
      units = "MB")


#'### CSV Korpus (MB)
file.size(csvname.full) / 10 ^ 6


#'### CSV Metadaten (MB)
file.size(csvname.meta) / 10 ^ 6



#'### PDF-Dateien (MB)

files.pdf <- list.files(pattern = "\\.pdf$",
                        ignore.case = TRUE)

pdf.MB <- file.size(files.pdf) / 10^6
sum(pdf.MB)



#'### TXT-Dateien (MB)

files.txt <- list.files(pattern = "\\.txt$",
                        ignore.case = TRUE)

txt.MB <- file.size(files.txt) / 10^6
sum(txt.MB)





#'\newpage
#'## Diagramm: Verteilung der Dateigrößen (PDF)

dt.plot <- data.table(pdf.MB)

#+ CE-BGH_13_Density_Dateigroessen_PDF, fig.height = 6, fig.width = 9
ggplot(data = dt.plot,
       aes(x = pdf.MB)) +
    geom_density(fill = "#7e0731") +
    scale_x_log10(breaks = trans_breaks("log10", function(x) 10^x),
                  labels = trans_format("log10", math_format(10^.x)))+
    annotation_logticks(sides = "b")+
    theme_bw() +
    labs(
        title = paste(datasetname,
                      "| Version",
                      datestamp,
                      "| Verteilung der Dateigrößen (PDF)"),
        caption = paste("DOI:",
                        doi.version),
        x = "Dateigröße in MB",
        y = "Dichte"
    )+
    theme(
        text = element_text(size = 14),
        plot.title = element_text(size = 14,
                                  face = "bold"),
        legend.position = "none",
        panel.spacing = unit(0.1, "lines"),
        plot.margin = margin(10, 20, 10, 10)
    )



#'\newpage
#'## Diagramm: Verteilung der Dateigrößen (TXT)

dt.plot <- data.table(txt.MB)

#+ CE-BGH_14_Density_Dateigroessen_TXT, fig.height = 6, fig.width = 9
ggplot(data = dt.plot,
       aes(x = txt.MB)) +
    geom_density(fill = "#7e0731") +
    scale_x_log10(breaks = trans_breaks("log10", function(x) 10^x),
                  labels = trans_format("log10", math_format(10^.x)))+
    annotation_logticks(sides = "b")+
    theme_bw() +
    labs(
        title = paste(datasetname,
                      "| Version",
                      datestamp,
                      "| Verteilung der Dateigrößen (TXT)"),
        caption = paste("DOI:",
                        doi.version),
        x = "Dateigröße in MB",
        y = "Dichte"
    )+
    theme(
        text = element_text(size = 14),
        plot.title = element_text(size = 14,
                                  face = "bold"),
        legend.position = "none",
        panel.spacing = unit(0.1, "lines"),
        plot.margin = margin(10, 20, 10, 10)
    )





#'# Erstellen der ZIP-Archive

#'## Verpacken der CSV-Dateien

#+ results = 'hide'
csvname.full.zip <- gsub(".csv",
                    ".zip",
                    csvname.full)

zip(csvname.full.zip,
    csvname.full)

unlink(csvname.full)


#+ results = 'hide'
csvname.meta.zip <- gsub(".csv",
                    ".zip",
                    csvname.meta)

zip(csvname.meta.zip,
    csvname.meta)


unlink(csvname.meta)




#'## Verpacken der PDF-Dateien


#+
#'### Nur Leitsatz-Entscheidungen


files.leitsatz <- gsub("\\.txt",
                       "\\.pdf",
                       txt.bgh[leitsatz == "LE"]$doc_id)

#+ results = 'hide'
zip(paste(datasetname,
          datestamp,
          "DE_PDF_Leitsatz-Entscheidungen.zip",
          sep = "_"),
    files.leitsatz)


#'### Nur Benannte Entscheidungen

files.benannt <- gsub("\\.txt",
                      "\\.pdf",
                      txt.bgh[is.na(name) == FALSE]$doc_id)

#+ results = 'hide'
zip(paste(datasetname,
          datestamp,
          "DE_PDF_Entscheidungen-mit-Namen.zip",
          sep = "_"),
    files.benannt)


#'### Alle Entscheidungen

#+ results = 'hide'
zip(paste(datasetname,
          datestamp,
          "DE_PDF_Datensatz.zip",
          sep = "_"),
    files.pdf)

unlink(files.pdf)






#'## Verpacken der TXT-Dateien

#+ results = 'hide'
files.txt <- list.files(pattern="\\.txt",
                        ignore.case = TRUE)

zip(paste(datasetname,
          datestamp,
          "DE_TXT_Datensatz.zip",
          sep = "_"),
    files.txt)

unlink(files.txt)




#'## Verpacken der Analyse-Dateien

zip(paste0(datasetname,
           "_",
           datestamp,
           "_DE_",
           basename(outputdir),
           ".zip"),
    basename(outputdir))




#'## Verpacken der Source-Dateien

files.source <- c(list.files(pattern = "Source"),
                  "buttons")


files.source <- grep("spin",
                     files.source,
                     value = TRUE,
                     ignore.case = TRUE,
                     invert = TRUE)

zip(paste(datasetname,
           datestamp,
           "Source_Files.zip",
           sep = "_"),
    files.source)






#'# Kryptographische Hashes
#' Dieses Modul berechnet für jedes ZIP-Archiv zwei Arten von Hashes: SHA2-256 und SHA3-512. Mit diesen kann die Authentizität der Dateien geprüft werden und es wird dokumentiert, dass sie aus diesem Source Code hervorgegangen sind. Die SHA-2 und SHA-3 Algorithmen sind äußerst resistent gegenüber *collision* und *pre-imaging* Angriffen, sie gelten derzeit als kryptographisch sicher. Ein SHA3-Hash mit 512 bit Länge ist nach Stand von Wissenschaft und Technik auch gegenüber quantenkryptoanalytischen Verfahren unter Einsatz des *Grover-Algorithmus* hinreichend resistent.

#+
#'## Liste der ZIP-Archive erstellen
files.zip <- list.files(pattern = "\\.zip$",
                        ignore.case = TRUE)


#'## Funktion anzeigen
#+ results = "asis"
print(f.dopar.multihashes)


#'## Hashes berechnen
multihashes <- f.dopar.multihashes(files.zip)


#'## In Data Table umwandeln
setDT(multihashes)



#'## Index hinzufügen
multihashes$index <- seq_len(multihashes[,.N])

#'\newpage
#'## In Datei schreiben
fwrite(multihashes,
       paste(datasetname,
             datestamp,
             "KryptographischeHashes.csv",
             sep = "_"),
       na = "NA")


#'## Leerzeichen hinzufügen um Zeilenumbruch zu ermöglichen
#' Hierbei handelt es sich lediglich um eine optische Notwendigkeit. Die normale 128 Zeichen lange Zeichenfolge wird ansonsten nicht umgebrochen und verschwindet über die Seitengrenze. Das Leerzeichen erlaubt den automatischen Zeilenumbruch und damit einen für Menschen sinnvoll lesbaren Abdruck im Codebook. Diese Variante wird nur zur Anzeige verwendet und danach verworfen.

multihashes$sha3.512 <- paste(substr(multihashes$sha3.512, 1, 64),
                              substr(multihashes$sha3.512, 65, 128))



#'## In Bericht anzeigen

kable(multihashes[,.(index,filename)],
      format = "latex",
      align = c("p{1cm}",
                "p{13cm}"),
      booktabs = TRUE,
      longtable = TRUE)

#'\newpage

kable(multihashes[,.(index,sha2.256)],
      format = "latex",
      align = c("c",
                "p{13cm}"),
      booktabs = TRUE,
      longtable = TRUE)




kable(multihashes[,.(index,sha3.512)],
      format = "latex",
      align = c("c",
                "p{13cm}"),
      booktabs = TRUE,
      longtable = TRUE)





#'# Abschluss

#+
#'## Datumsstempel
print(datestamp)


#'## Datum und Uhrzeit (Anfang)
print(begin.script)


#'## Datum und Uhrzeit (Ende)
end.script <- Sys.time()
print(end.script)


#'## Laufzeit des gesamten Skriptes
print(end.script - begin.script)


#'## Warnungen
warnings()



#'# Parameter für strenge Replikationen

system2("openssl", "version", stdout = TRUE)

sessionInfo()


#'# Literaturverzeichnis
