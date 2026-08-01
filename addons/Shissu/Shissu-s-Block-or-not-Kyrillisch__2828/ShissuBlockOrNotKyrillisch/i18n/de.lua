ShissuLocalization = ShissuLocalization or {}

ShissuLocalization["ShissuBlockOrNotKyrillisch"] = {       
  TITLE       = "Block or not Kyrillisch",

  GENERAL     = "Allgemeine Chat-Filter",
  CMD         = "Ausgeblendete Nachrichten aufgrund der Filter können mit /chatfilter eingeblendet und durchsucht werden.",
  GUILD       = "Gildenwerbung ausblenden",
  ITEMS       = "Verkäufe, Itemsuchanfragen ausblenden",
  ACHIEVMENT  = "Erfolge (Achievments)-Verkäufe ausblenden",
  
  CYRILLIC    = "Kyrillisch",
  DESC        = "Entfernt Nachrichten mit kyrillischen Schriftzeichen im Chat. Über eine Tastenkombination lässt sich die Funktion ein- und ausschalten. Alternativ lässt sich nur noch die kyrillische Schrift anzeigen.",
  SET         = "Blockieren von kyrillischen Schriftzeichen",
  SET2        = "Zeige nur Chatnachrichten mit kyrillischer Schrift",
  ON          = "Kyrillische Schriftzeichen werden geblockt.",
  OFF         = "Kyrillische Schriftzeichen werden nicht mehr geblockt.",

  USER        = "Benutzerdefinierter Chatfilter",
  USERHELP    = "Um mehrere Zeichenfolgen zufiltern, die einzelnen Wörter/Zeichenfolgen mit einem Semikolon trennen.",
  USEREXAMPLE = "Beispiel: Hallo;WTB;Kuta;Maus;Accountname",
  USER_TT     = "Blendet alle Chatnachrichten, die die benutzerdefinierten Zeichenfolgen beinhalten aus.",
  USER_2      = "Benutzerdefiniert",

  PROTOCOL    = "Protokoll",
  SAVE        = "Protokoll speichern",
  SAVE_TT     = "Speichert das Protokoll, die herausgefilterten Chatnachrichten",
  COUNT       = "Anzahl der Einträge",
  COUNT_TT    = "Legt die Anzahl der Chatnachrichten fest, die maximal gespeichert/angezeigt werden sollen.",

  FILTER_TT   = "Suche nach XYZ in den gefilterten Chatnachrichten. z.B. guild für Gildenwerbung, items für Gegenstände",
}

ZO_CreateStringId("SI_BINDING_NAME_SBK_Toogle", "Blockieren von kyrillischen Schriftzeichen")