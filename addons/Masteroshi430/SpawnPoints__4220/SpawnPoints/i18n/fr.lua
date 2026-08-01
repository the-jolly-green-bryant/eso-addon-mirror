SpawnPoints = SpawnPoints or {}

local localization = {

    LOADED_STR = "%s %s %s",
    WAS_LOADED = "chargé",
    NOT_LOADED = "NON chargé",
    NAME_SUPPRESS = "Supprimer le message chargé du module complémentaire",
    TOOLTIP_SUPPRESS = "Supprimez le message dans la fenêtre de discussion vous indiquant que le module complémentaire a été chargé avec succès.",
    SETTINGS_GENERAL_OPTIONS_HEADER = "PARAMÈTRES DU NIP DE LA CARTE",
    SETTINGS_MAP_PIN_ICON_LABEL = "Sélectionnez l'icône d'épingle de la carte",
    SETTINGS_MAP_PIN_ICON_DESCRIPTION = "Sélectionnez l'icône d'épingle de la carte",
    SETTINGS_MAP_PIN_SIZE_LABEL = "Taille des broches",
    SETTINGS_MAP_PIN_SIZE_DESCRIPTION = "Définir la taille des épingles de la carte",
    SETTINGS_MAP_PIN_COLOR_LABEL = "Couleur de la broche",
    SETTINGS_MAP_PIN_COLOR_DESCRIPTION = "Définir la couleur des épingles de la carte",
    SETTINGS_CLICKABLE_LABEL = "Cliquer sur les pins de la carte SpawnPoints définit le waypoint",
    SETTINGS_CLICKABLE_DESCRIPTION = "Devriez-vous autoriser ou interdire le clic sur l'épingle de la carte pour placer un waypoint sur votre carte ?",
    CLICK_HANDLER_NAME = "Définir le waypoint vers le site d'apparition du Volendrung",
    PIN_FILTER_NAME = "Lieux d'apparition du Volendrung",
}

if SpawnPoints.Localization and #localization == #SpawnPoints.Localization then
    ZO_ShallowTableCopy(localization, SpawnPoints.Localization)
end