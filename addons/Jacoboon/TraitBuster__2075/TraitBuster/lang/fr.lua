strings = {
  TBUST_TRAITBUSTER = "TraitBuster",
  TBUST_ACTIVATED = "Activé Utilisez %s pour les options.",
  TBUST_LONG_SINGULAR = "TraitBuster: 1 autre objet avec le même trait de recherche.",
  TBUST_SHORT_SINGULAR = "1 duplicata de recherche.",
  TBUST_LONG_PLURAL = "TraitBuster: %s autres articles avec le même trait de recherche.",
  TBUST_SHORT_PLURAL = "%s doublons de recherche.",
  TBUST_SLASH_TBUST = "/tbust",
  TBUST_SLASH_ON = "sur",
  TBUST_SLASH_OFF = "de",
  TBUST_SLASH_LONG = "longue",
  TBUST_SLASH_SHORT = "court",
  TBUST_SLASH_GREET = "saluer",
  TBUST_SLASH_DEFAULT = "défaut",
  TBUST_MENU_TITLE = " -=-=-= MENU PRINCIPAL =-=-=-",
  TBUST_MENU_ON = "= Active les info-bulles pour ce personnage. [DÉFAUT]",
  TBUST_MENU_OFF = "= Désactive les info-bulles pour ce personnage.",
  TBUST_MENU_LONG = "= Des info-bulles plus descriptives plus longues. [DÉFAUT]",
  TBUST_MENU_SHORT = "= Des infobulles plus courtes et plus concises.",
  TBUST_MENU_GREET_ON = "= Active le message d'accueil de connexion. [DÉFAUT]",
  TBUST_MENU_GREET_OFF = "= Désactive le message d'accueil de connexion.",
  TBUST_MENU_DEFAULT = "= Réinitialiser les paramètres par défaut.",
  TBUST_MENU_SELECT_ON = "Info-bulles activées pour ce personnage.",
  TBUST_MENU_SELECT_OFF = "Les info-bulles sont désactivées pour ce personnage.",
  TBUST_MENU_SELECT_LONG = "Les info-bulles seront plus longues et plus descriptives.",
  TBUST_MENU_SELECT_SHORT = "Les infobulles seront courtes et concises.",
  TBUST_MENU_SELECT_GREET_ON = "Le message d'accueil sera affiché.",
  TBUST_MENU_SELECT_GREET_OFF = "Le message d'accueil de connexion ne sera pas affiché.",
  TBUST_MENU_SELECT_DEFAULT = "Paramètres par défaut chargés."
}

if GetString(TBUST_TRAITBUSTER):len() == 0 then
  for key,value in pairs(strings) do
    SafeAddVersion(key, 1)
    ZO_CreateStringId(key, value)
  end
end