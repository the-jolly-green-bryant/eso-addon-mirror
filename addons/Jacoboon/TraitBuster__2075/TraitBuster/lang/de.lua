strings = {
  TBUST_TRAITBUSTER = "TraitBuster",
  TBUST_ACTIVATED = "Aktiviert. Verwenden Sie %s für Optionen.",
  TBUST_LONG_SINGULAR = "TraitBuster: 1 anderer Gegenstand mit der gleichen erforschten Eigenschaft.",
  TBUST_SHORT_SINGULAR = "1 recherchierbares Duplikat.",
  TBUST_LONG_PLURAL = "TraitBuster: %s andere Gegenstände mit der gleichen erforschten Eigenschaft.",
  TBUST_SHORT_PLURAL = "%s erforschbare Duplikate.",
  TBUST_SLASH_TBUST = "/tbust",
  TBUST_SLASH_ON = "auf",
  TBUST_SLASH_OFF = "aus",
  TBUST_SLASH_LONG = "lange",
  TBUST_SLASH_SHORT = "kurz",
  TBUST_SLASH_GREET = "grüßen",
  TBUST_SLASH_DEFAULT = "standard",
  TBUST_MENU_TITLE = " -=-=-=  HAUPTMENÜ  =-=-=-",
  TBUST_MENU_ON = "= Aktiviert Tooltips für dieses Zeichen. [STANDARD]",
  TBUST_MENU_OFF = "= Deaktiviert QuickInfos für dieses Zeichen.",
  TBUST_MENU_LONG = "= Länger aussagekräftige Tooltips. [STANDARD]",
  TBUST_MENU_SHORT = "= Kürzere, prägnantere Tooltips.",
  TBUST_MENU_GREET_ON = "= Aktiviert die Begrüßung für die Anmeldung. [STANDARD]",
  TBUST_MENU_GREET_OFF = "= Deaktiviert die Anmeldebegrüßung.",
  TBUST_MENU_DEFAULT = "= Auf Standardeinstellungen zurücksetzen.",
  TBUST_MENU_SELECT_ON = "Tooltips für diesen Charakter aktiviert.",
  TBUST_MENU_SELECT_OFF = "Tooltips für dieses Zeichen deaktiviert.",
  TBUST_MENU_SELECT_LONG = "Tooltips sind länger und aussagekräftiger.",
  TBUST_MENU_SELECT_SHORT = "Tooltips werden kurz und prägnant sein.",
  TBUST_MENU_SELECT_GREET_ON = "Die Anmeldebegrüßung wird angezeigt.",
  TBUST_MENU_SELECT_GREET_OFF = "Die Anmeldebegrüßung wird nicht angezeigt.",
  TBUST_MENU_SELECT_DEFAULT = "Standardeinstellungen geladen."
}

if GetString(TBUST_TRAITBUSTER):len() == 0 then
  for key,value in pairs(strings) do
    SafeAddVersion(key, 1)
    ZO_CreateStringId(key, value)
  end
end