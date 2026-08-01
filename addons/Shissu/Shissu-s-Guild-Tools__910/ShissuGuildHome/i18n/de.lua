ShissuLocalization = ShissuLocalization or {}

ShissuLocalization["ShissuGuildHome"] = {
  TITLE =           "Gilde: " .. GetString(SI_WINDOW_TITLE_GUILD_HOME),
  KIOSK =           "Zeit bis zum nächsten Gildenhändlergebot",
  KIOSK_TT =        "Zeigt in der Gildenübersicht die Zeit bis zum Wechsel des NPC-Händler an. Blendet zusätzlich beim Klicken auf die Info ein zusätzlichen Fenster mit folgenden Informationen ein: Letzter Zeitpunkt für Gebotsabgabe, Gebots Ende, Zeitpunkt für Ersatzhändler.",

  LEFTTIME =        "Restzeit",
  
  TRADER =          "Gilden-NPC",
  NEWKIOSK =        "Neuer Händler in",
  BIDEND =          "Versteigerung Ende",
  REPLACE =         "Ersatzhändler ab",        
  
  TEXT =            "DEINTEXT",
  
  COLOR =           GetString(SI_GUILD_HERALDRY_COLOR),       -- Farbe
  COLOR_INFO =      "Anzeigen von zusätzlichen Schaltflächen zum Einfügen von HTML-Farbcodes.",
  COLOR_MOTD =      "Nachricht des Tages",
  COLOR_DESC =      "Hintergrundinformationen",
}