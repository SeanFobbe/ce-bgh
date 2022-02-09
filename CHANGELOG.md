# Changelog


## Version \version
 
- Vollständige Aktualisierung der Daten
- Strenge Kontrolle und semantische Sortierung aller Variablen (entsprechend der Reihenfolge im Codebook)
- Datenstruktur wird nicht mehr im Codebook angezeigt um Fehler mit der UTF8-Kodierung und *listings* für \LaTeX\ zu vermeiden
- Strenge Versionskontrolle aller R packages mit *renv*
- Der Prozess der Kompilierung ist jetzt detailliert konfigurierbar, insbesondere die Parallelisierung
- Parallelisierung nun vollständig mit *future* statt mit *foreach* und *doParallel*
- Fehlerhafte Kompilierungen werden beim vor der nächsten Kompilierung vollautomatisch aufgeräumt
- Alle Ergebnisse werden automatisch fertig verpackt in den Ordner 'output' sortiert
- README und CHANGELOG sind jetzt externe Markdown-Dateien, die bei der Kompilierung automatisiert eingebunden werden
- Issue #1 fixed: Senate normalisiert
- Issue #2 fixed: Variablen nicht mehr doppelt definiert
- Issue #3 fixed: Alle Dateinamen-Präfixe nun korrekt
- Source Code des Changelogs zu Markdown konvertiert
- In der Vergangenheit fälschlich als "Platzhalter" aussortierte drei Dokumente sind nun im Datensatz enthalten


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

