-- STRING_DEFINITIONS — Deutsche Lokalisierung für den Addon
local strings = {
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_NOTIFICATION_AVAILABLE"] = "|t34:34:/esoui/art/characterselect/keyboard/characterselect_esoplus_chalice.dds|t|c00FF00Abonnement verfügbar|r",
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_NOTIFICATION_UNAVAILABLE"] = "|t34:34:/esoui/art/characterselect/keyboard/characterselect_esoplus_chalice.dds|t|cFF0000Abonnement nicht verfügbar|r",
    
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_NOTIFICATION_LIBADDOMENU"] = "|cFF0000[ESO Plus]|r LibAddonMenu-2.0 nicht gefunden. Bitte prüfen und installieren.",
    
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_STRING_MENU"] = "|cCCECC0Datum|r                |c98FB98Status|r",
    
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_ESWAGROM"] = "|cEEEE00Lasst uns @Eswagrom fragen...|r",
    
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_ESWAGROM_A"] = "|c2DF5F8[@Eswagrom] flüstert: Hallo, das Abonnement ist jetzt verfügbar NUTZ ES|r",
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_ESWAGROM_C"] = "|c5EB9D7[@Eswagrom]: Hallo, was ist mit dem kostenlosen Probeabo?|r",
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_ESWAGROM_B"] = "|c2DF5F8[@Eswagrom] flüstert: Hallo, aktuell ist das Abonnement nicht verfügbar -_-|r",
    
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_CHAT_NOTIFICATION"] = "Benachrichtigungen im Chat senden",
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_CHAT_NOTIFICATION_A"] = "|c00FF00Wenn AUS, wird keine automatische Chat-Nachricht über das Abonnement gesendet, es bleibt nur die manuelle Prüfung /esoplus.|r",
    
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_FONT"] = "Schriftgröße in der Tabelle",
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_FONT_A"] = "|c00FF00Ändert die Schriftgröße im Fenster der Status-Historie (von 8 bis 24)|r",
    
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_HISTORY"] = "Tabelle zur Aufzeichnung des Abonnements",
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_HISTORY_A"] = "|c00FF00Öffnet ein separates Fenster mit Informationen zum kostenlosen Probeabonnement|r",
    
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_LOCK"] = "Fensterposition sperren",
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_LOCK_A"] = "|c00FF00Verhindert das Verschieben des Fensters auf dem Bildschirm|r",
    
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_AAA"] = "Transparenz des Hintergrunds",
    
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_BBB"] = "Fensterposition zurücksetzen",
    
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_CCC"] = "Status-Historie aktualisieren",
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_UPDATE_WINDOW_H"] = "|c00FF00Falls etwas im Historiefenster fehlerhaft ist — aktualisieren Sie es, vielleicht hilft das.|r",
    
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_AVA"] = "verfügbar",
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_UNAVA"] = "nicht verfügbar",
    
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_HISTORY_LINES"] = "Anzahl der Zeilen für die Aufzeichnung",
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_HISTORY_LINES_A"] = "|c00FF00Wie viele Zeilen werden in der SavedVariables-Historie gespeichert [beeinflusst Dateigröße und Dauer, bei Limit Überschreitung wird überschrieben] (von 100 bis 5000 mögliche Zeilen)|r",
    
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_RESET_WINDOW"] = "|cEEEE00Fensterposition zurückgesetzt.|r",
    
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_ADDON_NAME"] = "|c00FF00EsoPlus-Aufzeichnungen|r",
    
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_DEFAULTS_SETTINGS"] = "|cFF6347Einstellungen zurücksetzen!!!|r",
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_DEFAULTS_SETTINGS_A"] = "|cFF6347Setzt alle Addon-Einstellungen auf 'gerade installiert' zurück. Setzt Position, Größe, Transparenz, Schrift, Sichtbarkeit, Zeilenanzahl (löscht Zeilen über dem aufgezeichneten Limit!!! anfangs 2000 Zeilen) und Historie zurück.|r",
    
    -- Информационное сабменю
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_INFORMATION_ESO_PLUS"] = "|c00FF00Informationen zu ESO Plus|r",
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_INFORMATION_ESO_PLUS_A"] = "|c9999FF/esoplus|r |cFF6347im Chat eingeben für manuelle Prüfung!|r Dieses Addon speichert Aufzeichnungen über den Erhalt der kostenlosen Testversion, sodass Sie immer genau wissen, an welchem Tag sie aktiviert war oder fehlte. Standardmäßig speichert die Historie bis zu 2000 Einträge. Was bedeutet das praktisch? Jeder Eintrag in der Tabelle nimmt eine Zeile pro Tag ein. Damit umfasst das Limit von 2000 Zeilen einen Zeitraum von ca. 2000/365≈5,48 Jahren. Mit anderen Worten: Das Addon speichert Ihre Abonnement-Historie fast fünfeinhalb Jahre lang.",
    
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_INFORMATION_ESO_PLUS_AA"] = "|c00FF00APIs, die dieses Addon verwendet|r",
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_INFORMATION_ESO_PLUS_AAA"] = "|c00FF00API (Application Programming Interface)|r — ist eine Reihe von Regeln, nach denen Ihr Addon mit dem Spielserver interagiert. Einfach gesagt: Es definiert erlaubte Befehle. Für die Implementierung wurden folgende Methoden verwendet:",
    
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_INFORMATION_ESO_PLUS_AB"] = "|c00FF00* HasEsoPlusFreeTrialNotification()|r",
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_INFORMATION_ESO_PLUS_AAB"] = "** _Returns:_ *bool* _hasFreeTrialNotification_",
    
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_INFORMATION_ESO_PLUS_AC"] = "|c00FF00* ClearEsoPlusFreeTrialNotification()|r",
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_INFORMATION_ESO_PLUS_AAC"] = "Dieses Addon hat keine Funktion zum Binden einer Taste, um die Benutzertabelle mit Historie aufzurufen, da es rein informativ ist. Diese Tabelle benötigen Sie fast nie. Der Autor hat bewusst darauf verzichtet wegen der Begrenzung im Spiel: Nur 100 Slots sind für benutzerdefinierte Tasten verfügbar, daher ist es unpraktisch, sie mit unnötigen Elementen zu füllen.",
    
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_INFORMATION_ESO_PLUS_AD"] = "|c00FF00Automatische Überprüfungsfunktion!!!|r",
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_INFORMATION_ESO_PLUS_AAD"] = "|c9999FFAutomatische Überprüfungen des Abonnementstatus finden alle 15 Minuten statt, unabhängig von den Addon-Einstellungen, damit Sie den Status nicht verpassen, falls er am selben Tag später aktiviert wird. Die Prüfung belastet Ihr System nicht. Solch ein Timer ist komplett sicher für die Leistung. Warum:|r |cFFFFC5Ausführungshäufigkeit Alle 15 Minuten — extrem selten für eine Spiele-Engine. Zum Vergleich: Der ESO-Client selbst verarbeitet zehntausende Events pro Sekunde (Animation, Rendering, Netzwerkpakete). Eine Funktion alle 15 Minuten ist ein Tropfen auf dem heißen Stein. - Alle Operationen hier sind rein logisch: Lesen des Kontostatus via API (HasEsoPlus...), Arbeit mit lokaler Lua-Tabelle und Ausgabe einer Nachricht im Chat (d()). Keine schweren Berechnungen, große Arrays, Datei- oder Netzwerkzugriffe. Calls wie ZO_SavedVars, d(), ClearEsoPlus... sind von ZOS optimiert und laufen in Mikrosekunden.|r |cffd700Ping|r hängt von Internetqualität und Serverlast ab. Lokaler Lua-Timer sendet Daten nicht häufiger als das Spiel selbst. HasEsoPlusFreeTrialNotification() nutzt gecachten Account-Status — kein zusätzlicher Traffic. |c1E90FFVergleich mit anderen Addons.|r Viele populäre Addons verwiesen viel häufigere Timer: |cADD8E6- Inventory Insight|r — prüft Inventar beim Öffnen; |cADD8E6- Combat Metrics|r — analysiert jeden Kampf-Tick (dutzende Male pro Sekunde); — sogar UI-Elemente updaten sich 60+ Mal pro Sekunde. Dieser |cADD8E6Timer|r von 900 Sekunden wirkt wie 'einmal in einer Ära' dagegen."
}

-- Регистрация всех строк одним циклом — ТРЕБОВАНИЕ ESOUI!
for stringId, text in pairs(strings) do
    ZO_CreateStringId(stringId, text)
end