
    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_NOTIFICATION_AVAILABLE, "|t34:34:/esoui/art/characterselect/keyboard/characterselect_esoplus_chalice.dds|t|c00FF00Abonnement verfügbar|r", 1)
    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_NOTIFICATION_UNAVAILABLE, "|t34:34:/esoui/art/characterselect/keyboard/characterselect_esoplus_chalice.dds|t|cFF0000Abonnement nicht verfügbar|r", 1)
    
    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_NOTIFICATION_LIBADDOMENU, "|cFF0000[ESO Plus]|r LibAddonMenu-2.0 nicht gefunden. Bitte prüfen und installieren.", 1)
    
    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_STRING_MENU, "|cCCECC0Datum|r                |c98FB98Status|r", 1)
    
    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_ESWAGROM, "|cEEEE00Lasst uns @Eswagrom fragen...|r", 1)
    
    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_ESWAGROM_A, "|c2DF5F8[@Eswagrom] flüstert: Hallo, das Abonnement ist jetzt verfügbar NUTZ ES|r", 1)
    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_ESWAGROM_C, "|c5EB9D7[@Eswagrom]: Hallo, was ist mit dem kostenlosen Probeabo?|r", 1)
    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_ESWAGROM_B, "|c2DF5F8[@Eswagrom] flüstert: Hallo, aktuell ist das Abonnement nicht verfügbar -_-|r", 1)
    
    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_CHAT_NOTIFICATION, "Benachrichtigungen im Chat senden", 1)
    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_CHAT_NOTIFICATION_A, "|c00FF00Wenn AUS, wird keine automatische Chat-Nachricht über das Abonnement gesendet, es bleibt nur die manuelle Prüfung /esoplus.|r", 1)
    
    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_FONT, "Schriftgröße in der Tabelle", 1)
    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_FONT_A, "|c00FF00Ändert die Schriftgröße im Fenster der Status-Historie (von 8 bis 24)|r", 1)
    
    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_HISTORY, "Tabelle zur Aufzeichnung des Abonnements", 1)
    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_HISTORY_A, "|c00FF00Öffnet ein separates Fenster mit Informationen zum kostenlosen Probeabonnement|r", 1)
    
    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_AVA, "|t15:15:/esoui/art/interaction/accept.dds|t |c00FF00verfügbar|r |t15:15:/esoui/art/interaction/accept.dds|t", 1)
    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_UNAVA, "|cFF0000X|r |cFF0000nicht verfügbar|r |cFF0000X|r", 1)
    
    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_HISTORY_LINES, "Anzahl der Zeilen für die Aufzeichnung", 1)
    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_HISTORY_LINES_A, "|c00FF00Wie viele Zeilen werden in der SavedVariables-Historie gespeichert [beeinflusst Dateigröße und Dauer, bei Limit Überschreitung wird überschrieben] (von 100 bis 5000 mögliche Zeilen)|r", 1)
    
    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_RESET_WINDOW, "|cEEEE00Fensterposition zurückgesetzt.|r", 1)
    
    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_ADDON_NAME, "|c00FF00EsoPlus-Aufzeichnungen|r", 1)
    
    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_DEFAULTS_SETTINGS, "|cFF6347Einstellungen zurücksetzen!!!|r", 1)
    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_DEFAULTS_SETTINGS_A, "|cFF6347Setzt alle Addon-Einstellungen auf 'gerade installiert' zurück. Setzt Position, Größe, Transparenz, Schrift, Sichtbarkeit, Zeilenanzahl (löscht Zeilen über dem aufgezeichneten Limit!!! anfangs 2000 Zeilen) und Historie zurück.|r", 1)
    
    -- Информационное сабменю
    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_INFO_ESO_PLUS, "|c00FF00Informationen zu ESO Plus|r", 1)
    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_INFO_ESO_PLUS_A, "|c9999FF/esoplus|r |cFF6347im Chat eingeben für manuelle Prüfung!|r Dieses Addon speichert Aufzeichnungen über den Erhalt der kostenlosen Testversion, sodass Sie immer genau wissen, an welchem Tag sie aktiviert war oder fehlte. Standardmäßig speichert die Historie bis zu 2000 Einträge. Was bedeutet das praktisch? Jeder Eintrag in der Tabelle nimmt eine Zeile pro Tag ein. Damit umfasst das Limit von 2000 Zeilen einen Zeitraum von ca. 2000/365≈5,48 Jahren. Mit anderen Worten: Das Addon speichert Ihre Abonnement-Historie fast fünfeinhalb Jahre lang.", 1)
    
    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_INFO_ESO_PLUS_AA, "|c00FF00APIs, die dieses Addon verwendet|r", 1)
    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_INFO_ESO_PLUS_AAA, "|c00FF00API (Application Programming Interface)|r — ist eine Reihe von Regeln, nach denen Ihr Addon mit dem Spielserver interagiert. Einfach gesagt: Es definiert erlaubte Befehle. Für die Implementierung wurden folgende Methoden verwendet:", 1)
    
    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_INFO_ESO_PLUS_AB, "|c00FF00* HasEsoPlusFreeTrialNotification()|r", 1)
    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_INFO_ESO_PLUS_AAB, "** _Returns:_ *bool* _hasFreeTrialNotification_", 1)
    
    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_INFO_ESO_PLUS_AC, "|c00FF00* ClearEsoPlusFreeTrialNotification()|r", 1)
    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_INFO_ESO_PLUS_AAC, "Dieses Addon hat keine Funktion zum Binden einer Taste, um die Benutzertabelle mit Historie aufzurufen, da es rein informativ ist. Diese Tabelle benötigen Sie fast nie. Der Autor hat bewusst darauf verzichtet wegen der Begrenzung im Spiel: Nur 100 Slots sind für benutzerdefinierte Tasten verfügbar, daher ist es unpraktisch, sie mit unnötigen Elementen zu füllen.", 1)
    
    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_INFO_ESO_PLUS_AD, "|c00FF00Automatische Überprüfungsfunktion!!!|r", 1)
    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_INFO_ESO_PLUS_AAD, "|c9999FFAutomatische Überprüfungen des Abonnementstatus finden alle 15 Minuten statt, unabhängig von den Addon-Einstellungen, damit Sie den Status nicht verpassen, falls er am selben Tag später aktiviert wird. Die Prüfung belastet Ihr System nicht. Solch ein Timer ist komplett sicher für die Leistung. Warum:|r |cFFFFC5Ausführungshäufigkeit Alle 15 Minuten — extrem selten für eine Spiele-Engine. Zum Vergleich: Der ESO-Client selbst verarbeitet zehntausende Events pro Sekunde (Animation, Rendering, Netzwerkpakete). Eine Funktion alle 15 Minuten ist ein Tropfen auf dem heißen Stein. - Alle Operationen hier sind rein logisch: Lesen des Kontostatus via API (HasEsoPlus...), Arbeit mit lokaler Lua-Tabelle und Ausgabe einer Nachricht im Chat (d()). Keine schweren Berechnungen, große Arrays, Datei- oder Netzwerkzugriffe. Calls wie ZO_SavedVars, d(), ClearEsoPlus... sind von ZOS optimiert und laufen in Mikrosekunden.|r |cffd700Ping|r hängt von Internetqualität und Serverlast ab. Lokaler Lua-Timer sendet Daten nicht häufiger als das Spiel selbst. HasEsoPlusFreeTrialNotification() nutzt gecachten Account-Status — kein zusätzlicher Traffic. |c1E90FFVergleich mit anderen Addons.|r Viele populäre Addons verwiesen viel häufigere Timer: |cADD8E6- Inventory Insight|r — prüft Inventar beim Öffnen; |cADD8E6- Combat Metrics|r — analysiert jeden Kampf-Tick (dutzende Male pro Sekunde); — sogar UI-Elemente updaten sich 60+ Mal pro Sekunde. Dieser |cADD8E6Timer|r von 900 Sekunden wirkt wie 'einmal in einer Ära' dagegen.", 1)

    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_ADDON_NAME_INFO, "|cFF6347Tabelle unten:|r", 1)
    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_ADDON_NAME_INFO_A, "|c9999FFTabelle zeigt bis zu 20 Aufzeichnungszyklen an, von welchem Datum bis zu welchem Datum EsoPlus verfügbar oder nicht verfügbar war.|r |cFFFFCTabelle öffnen:|r", 1)

    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_GENERAL_INFO_RECORDS, "|ccdfff3Alle Einträge|r", 1)
    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_GENERAL_INFO_ESOPLUS, "|ccdfff3INFORMATION|r", 1)

    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_CHANGELOG, "Änderungsprotokoll", 1)

    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_CHANGELOGA, "EsoPlusFreeTrialNotification V1.0", 1)
    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_CHANGELOG_A, "erste Version", 1)
    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_CHANGELOG_AA, "mit der alten Bibliothek LibStub", 1)

    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_CHANGELOGB, "EsoPlusFreeTrialNotification v1.1", 1)
    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_CHANGELOG_B, "Änderungen für ESOUI:", 1)
    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_CHANGELOG_BB, "1 Verbindung zu LibStub entfernt, Verbindung zu LibAddonMenu-2.0 hinzugefügt\n 2 alle Sprachdateien mit lokalen Zeichenketten\n 3 Globale Variablen ohne lokale Referenz behoben, um den Zugriff auf die Tabelle _G zu beschleunigen\n 4 einige kleinere Ähnlichkeiten wie oben beschrieben wurden behoben.", 1)

    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_CHANGELOGC, "EsoPlusFreeTrialNotification v1.2", 1)
    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_CHANGELOG_C, "Code-Optimierung, Teil eins", 1)
    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_CHANGELOG_CC, "**1. Einzelne globale Tabelle Unified Namespace\n **Korrekt implementiert.\n Es wird nur eine globale Tabelle verwendet: ESOPLUSFREETRIALNOTIFICATION_ESWAGROM mit dem lokalen Alias EPFTN.\n 2. Zugriffsoptimierung G optimization\n Die Verwendung von local EPFTN ... gilt als sehr guter Programmierstil. Dies beschleunigt den Tabellenzugriff auf Mikroebene durch das Zwischenspeichern der Referenz im Lua-Stack, was wiederholte Suchvorgänge in der langsamen globalen Tabelle _G bei jedem Funktionsaufruf vermeidet. 3.\n Integriertes Einstellungsmenü: Die externe Einstellungsdatei .xml wurde vollständig entfernt. Alle Einträge und Konfigurationen werden nun innerhalb des Systems verarbeitet, und zur einfacheren Handhabung wird die moderne Bibliothek LibAddonMenu-2.0 verwendet.\n 4. Geändert\n Code-Optimierung:\n Alle nicht genutzten Einstellungen wurden entfernt und die meisten Zeilen veralteten Codes wurden gelöscht, um seine Größe erheblich zu reduzieren.\n Die verbliebene Codebasis wurde erheblich optimiert; die Logik ist nun minimal, klar und leicht zu warten.\n 5. Behoben\n Bildlaufbare UI-Tabelle: Das Problem mit der internen Datentabelle wurde behoben. Eine voll funktionsfähige vertikale Bildlaufleiste wurde implementiert, sodass Benutzer sich leicht durch die Einträge bewegen können.", 1)

    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_CHANGELOGD, "EsoPlusFreeTrialNotification v1.3", 1)
    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_CHANGELOG_D, "Tabellen-Optimierung", 1)
    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_CHANGELOG_DD, "1). Optimierung der Verlaufstabelle\n * **Was hat sich geändert:**\n Die Logik zur Anzeige von Einträgen in der Verlaufstabelle wurde vollständig überarbeitet. Zuvor war jede Zeile ein separates UI-Element mit individueller Formatierung, was zu visuellen Fehlern und Verzögerungen bei der Verarbeitung großer Datenmengen führte.\n Probleme mit der Zusammenführung von Textfarben wurden behoben.\n Die Sekundenverzögerung beim Öffnen des Addon-Fensters wurde beseitigt.\n> Warum ist das passiert?\n Dies ist ein klassisches Problem der Interface-Optimierung in Spielen:\n Speicheroptimierung: Jede Farbänderung erhöht die Belastung von CPU und RAM. Die Engine gruppiert Elemente mit identischen Stilen, um die Anzahl der zu rendernden Objekte zu reduzieren.\n Engine-Limit (ZO_ScrollList): Die ESO-API hat eine Begrenzung für die Anzahl einzigartiger Textformate innerhalb einer scrollbaren Liste. Nach Erreichen eines Schwellenwerts von etwa 128 Zeilen stoppt die Engine die Verarbeitung einzelner Farblabels (|c...) und beginnt, den Stil der vorherigen Gruppe auf alle nachfolgenden Einträge anzuwenden.\n Standard-Zusammenführung: Da viele Zeilen dasselbe Format teilen, betrachtet die Benutzeroberfläche sie als einen einzigen logischen Block und wendet einen einheitlichen Stil von unten nach oben an.\n Neue Lösung:\n Der Verlauf speichert nun nur noch die letzten 20 Perioden der Verfügbarkeit/Nicht-Verfügbarkeit von EsoPlus. Dies bietet ein ausreichendes Informationsvolumen und garantiert ein sofortiges Öffnen der Tabelle ohne jegliche Verzögerung.\n Wichtiger Hinweis: Das Datenvolumen in der SavedVariables-Datei (auch wenn sie 2000-5000 Einträge enthält) beeinflusst die Ingame-Leistung überhaupt nicht. Die Einschränkung betrifft ausschließlich die Darstellung der Benutzeroberfläche.\n **2). Sicheres Laden der Lokalisierung\n * **Das Sprachübersetzungssystem wurde verbessert. Englisch dient jetzt als sicherer Basis-Anker (Hauptsprache), woraufhin die vom Benutzer gewählte Lokalisierung darüber geladen wird. Dies macht den Textinitialisierungsprozess stabiler und vorhersagbarer.\n **3). Code-Aufräumen\n * **Alle ungenutzten Funktionen und Variablen wurden aus der Haupt-Addon-Datei entfernt. Der Code-Basis ist nun sauberer, leichter und einfacher zu warten.", 1)
