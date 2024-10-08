# Changelog


## Version \version

- Vollständige Aktualisierung der Daten
- LIZENZÄNDERUNG: Source Code jetzt unter GNU General Public License Version 3 (GPLv3) oder später lizenziert
- NEU: Zitationsnetzwerk Aktenzeichen-zu-BGHZ und Aktenzeichen-zu-BGHSt
- NEU: Variable für BGHZ
- Extraktion von Zitaten für Aktenzeichen-zu-Aktenzeichen komplett überarbeitet
- R-Version auf 4.4.0 aktualisiert (wegen CVE-2024-27322)
- Variable "bghr" wird nun korrekt extrahiert
- Source-Archiv wird nun aus dem Git-Manifest gebildet
- Anpassung von Compose File an Debian 11
- Docker Zeitzone auf Berlin eingestellt
- Vereinfachung der Repository-Struktur
- Python Toolchain entfernt
- Zusätzliches Lösch-Skript mit Docker-Integration
- Verbesserung von Warnmeldungen
- Erweiterung der Unit Tests
- Erweiterung der automatischen Korrektur der Aktenzeichen
- Extraktion von PDFs ignoriert fehlerhafte PDFs
- Fix für Segmentation Fault bei Zählung von Types bei leeren Dokumenten
- Fix für gitconfig-Problem
- Diagramme nicht mehr nummeriert, sondern nach Typ geordnet



## Version 2023-03-10

- Vollständige Aktualisierung der Daten
- NEU Zitations-Netzwerk zwischen allen Aktenzeichen des Bundesgerichtshofs als GraphML zur freien Verwendung (EXPERIMENTELL!)
- Gesamte Laufzeitumgebung mit Docker versionskontrolliert
- Aktenzeichen aus dem Eingangszeitraum 2000 bis 2009 nun korrekt mit führender Null formatiert (z.B. 1 BvR 44/02 statt 1 BvR 44/2)
- Vereinfachung der Konfigurations-Datei
- Verbesserte Formatierung von Warnungen und Fehlermeldungen im Compilation Report
- Verbesserung des Robustness Check Reports
- Neue Funktion für automatischen clean run (Löschung aller Zwischenergebnisse)
- Update der Download-Funktion
- Überflüssige Warnung in f.future_lingsummarize-Funktion entfernt
- Alle Roh-Dateien werden nun im Unterordner "files" gespeichert
- Korrektur für RiSt-Aktenzeichen eingefügt




## Version 2022-08-16

- Vollständige Aktualisierung der Daten
- Neuer Entwurf des gesamten Source Codes im {targets} framework
- Die Zivilsenate in der Variable "spruchkoerper_db" sind jetzt arabisch nummeriert, damit sie automatisch sortiert werden können. Die originale römische Nummerierung ist weiterhin in der Variable "spruchkoerper_az" zu finden.
- Variable "comment" wurde in "bemerkung" umbenannt
- Variable "berichtigung" ist jetzt entweder mit TRUE oder FALSE codiert
- Diagramme sind in neuer Reihenfolge nummeriert, um die Reihenfolge im Codebook abzubilden
- Umfang der Datenbankabfrage ist nun vollautomatisiert



## Version 2022-02-12
 
- Vollständige Aktualisierung der Daten
- Strenge Kontrolle und semantische Sortierung aller Variablen (entsprechend der Reihenfolge im Codebook)
- Datenstruktur wird nicht mehr im Codebook angezeigt um Fehler mit der UTF8-Kodierung und *listings* für \LaTeX\ zu vermeiden
- Strenge Versionskontrolle aller R packages mit *renv*
- Der Prozess der Kompilierung ist jetzt detailliert konfigurierbar, insbesondere die Parallelisierung
- Parallelisierung nun vollständig mit *future* statt mit *foreach* und *doParallel*
- Fehlerhafte Kompilierungen werden beim vor der nächsten Kompilierung vollautomatisch aufgeräumt
- Alle Ergebnisse werden automatisch fertig verpackt in den Ordner 'output' sortiert
- README und CHANGELOG sind jetzt externe Markdown-Dateien, die bei der Kompilierung automatisiert eingebunden werden
- Issue #1 fixed: Senate normalisiert; die Variable "spruchkoerper_db" enthält nun die Präfixe "Strafsenat" und "Zivilsenat" vor der jeweiligen Senatsnummer um in den Dateinamen eine einfachere Orientierung zu ermöglichen
- Issue #2 fixed: Variablen nicht mehr doppelt definiert
- Issue #3 fixed: Alle Dateinamen-Präfixe nun korrekt
- Source Code des Changelogs zu Markdown konvertiert
- In der Vergangenheit fälschlich als "Platzhalter" aussortierte drei Dokumente sind nun im Datensatz enthalten
- Das Diagramm "Entscheidungen je Registerzeichen" ist nun zu einer Log-Skala konvertiert um die Darstellung informativer zu gestalten



## Version 2021-04-27

- Vollständige Aktualisierung der Daten
- Veröffentlichung des vollständigen Source Codes
- Deutliche Erweiterung des inhaltlichen Umfangs des Codebooks
- Einführung der vollautomatischen Erstellung von Datensatz und Codebook
- Einführung von Compilation Reports um den Erstellungsprozess exakt zu dokumentieren
- Einführung von Variablen für Lizenz, Versionsnummer, Concept DOI, Version DOI, ECLI, Typ der Entscheidung, Präsident:in, Vize-Präsident:in, Verfahrensart, Name, Leitsatz, Bemerkungen, Berichtigungen, und linguistische Kennzahlen (Zeichen, Tokens, Typen, Sätze)
- Einführung von PDF-Varianten für Leitsatzentscheidungen und namentlich gekennzeichneten Entscheidungen.
- Zusammenfügung von über Zeilengrenzen getrennten Wörtern in der CSV-Variante
- Automatisierung und Erweiterung der Qualitätskontrolle
- Einführung von Diagrammen zur Visualisierung von Prüfergebnissen
- Einführung kryptographischer Signaturen
- Alle Variablen sind nun in Kleinschreibung und Snake Case gehalten
- Variable 'Ordinalzahl' in 'eingangsnummer' umbenannt

 
 
## Version 2020-07-09

- Erstveröffentlichung

