strings = {
  TBUST_TRAITBUSTER = "TraitBuster",
  TBUST_ACTIVATED = "Attivato. Usa %s per le opzioni.",
  TBUST_LONG_SINGULAR = "TraitBuster: 1 altro oggetto con lo stesso tratto ricercabile di proprietà.",
  TBUST_SHORT_SINGULAR = "1 duplicato ricercabile.",
  TBUST_LONG_PLURAL = "TraitBuster: %s altri articoli con lo stesso tratto ricercabile di proprietà.",
  TBUST_SHORT_PLURAL = "%s duplicati ricercabili.",
  TBUST_SLASH_TBUST = "/tbust",
  TBUST_SLASH_ON = "su",
  TBUST_SLASH_OFF = "via",
  TBUST_SLASH_LONG = "lungo",
  TBUST_SLASH_SHORT = "breve",
  TBUST_SLASH_GREET = "salutare",
  TBUST_SLASH_DEFAULT = "difetto",
  TBUST_MENU_TITLE = " -=-=-= MENU PRINCIPALE =-=-=-",
  TBUST_MENU_ON = "= Abilita i suggerimenti per questo personaggio. [DIFETTO]",
  TBUST_MENU_OFF = "= Disabilita le descrizioni comandi per questo personaggio.",
  TBUST_MENU_LONG = "= Suggerimenti più lunghi e più descrittivi. [DIFETTO]",
  TBUST_MENU_SHORT = "= Tooltips più brevi e concisi.",
  TBUST_MENU_GREET_ON = "= Abilita il saluto di accesso. [DIFETTO]",
  TBUST_MENU_GREET_OFF = "= Disabilita il saluto di accesso.",
  TBUST_MENU_DEFAULT = "= Ripristina le impostazioni predefinite.",
  TBUST_MENU_SELECT_ON = "Tooltip abilitati per questo personaggio.",
  TBUST_MENU_SELECT_OFF = "Tooltips disabilitati per questo personaggio.",
  TBUST_MENU_SELECT_LONG = "I tooltip saranno più lunghi e più descrittivi.",
  TBUST_MENU_SELECT_SHORT = "I tooltip saranno brevi e concisi.",
  TBUST_MENU_SELECT_GREET_ON = "Il messaggio di benvenuto verrà mostrato.",
  TBUST_MENU_SELECT_GREET_OFF = "Il messaggio di benvenuto per l'accesso non verrà mostrato.",
  TBUST_MENU_SELECT_DEFAULT = "Impostazioni predefinite caricate."
}

if GetString(TBUST_TRAITBUSTER):len() == 0 then
  for key,value in pairs(strings) do
    SafeAddVersion(key, 1)
    ZO_CreateStringId(key, value)
  end
end