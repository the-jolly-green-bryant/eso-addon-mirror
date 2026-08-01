NineResourcez = NineResourcez or {}

local localization = {

    LOADED_STR = "%s %s %s",
    WAS_LOADED = "chargé",
    NOT_LOADED = "NON chargé",
   
    SETTINGS_GENERAL_OPTIONS_HEADER = "PARAMÈTRES DU NIP DE LA CARTE",
    SETTINGS_SUPPRESS_MSGS_LABEL = "Supprimer la collecte de ressources et autres messages",
    SETTINGS_SUPPRESS_MSGS_DESCRIPTION = "Supprimer la collecte de ressources et autres messages dans la fenêtre de discussion",
    SETTINGS_MAP_PIN_ICON_LABEL = "Sélectionnez l'icône d'épingle de la carte",
    SETTINGS_MAP_PIN_ICON_DESCRIPTION = "Sélectionnez l'icône d'épingle de la carte",
    SETTINGS_MAP_PIN_SIZE_LABEL = "Taille des broches",
    SETTINGS_MAP_PIN_SIZE_DESCRIPTION = "Définir la taille des épingles de la carte",
    SETTINGS_MAP_PIN_COLOR_LABEL = "Couleur de la broche",
    SETTINGS_MAP_PIN_COLOR_DESCRIPTION = "Définir la couleur des épingles de la carte",
    SETTINGS_MAP_PIN_LEVEL_LABEL = "Niveau des broches",
    SETTINGS_MAP_PIN_LEVEL_DESCRIPTION = "Définir le niveau du repère de la carte",
    CLICK_HANDLER_NAME = "Définir le waypoint sur la cible capturée",
    PIN_FILTER_NAME = "Capturez neuf ressources ou trois châteaux",
    NOW_TRACKING = "Tâche de suivi maintenant: %s",
    YOU_CAPTURED = "Capturé",
    QUEST_COMPLETED = "Quête %s terminée !",
    QUEST_ABANDONED = "Quête %s abandonnée.",
    NEITHER_QUEST = "Ni %s ni %s ne sont dans votre journal de quête.",
}

if NineResourcez.Localization and #localization == #NineResourcez.Localization then
    ZO_ShallowTableCopy(localization, NineResourcez.Localization)
end