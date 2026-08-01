local strings =
{
    SI_ADDONLOADOUTS_LOADOUTS = "Sélection d'addons",
    SI_ADDONLOADOUTS_SAVE_CURRENT = "Enregistrer cette sélection d'addons",
    SI_ADDONLOADOUTS_APPLY_LOADOUT = "Appliquer cette sélection d'addons",
    SI_ADDONLOADOUTS_APPLY_LOADOUT_TOOLTIP = "Choisissez une sélection d'addons à charger, puis rechargez l'interface.",
    SI_ADDONLOADOUTS_LOAD = "Charger",
    SI_ADDONLOADOUTS_DELETE = "Supprimer",
    SI_ADDONLOADOUTS_NEW_LOADOUT_NAME = "Nom de la nouvelle sélection d'addons",
    SI_ADDONLOADOUTS_APPLY = "Appliquer",
    SI_ADDONLOADOUTS_RELOADING = "Sélection d'addons chargée. Rechargement de l'interface...",
    SI_ADDONLOADOUTS_NO_LOADOUTS = "Aucune sélection d'addons enregistrée. Enregistrez l'état actuel des addons (activés/désactivés) comme nouvelle sélection dans les Paramètres.",
    SI_ADDONLOADOUTS_UPDATE_ACTIVE = "Mettre à jour la sélection active",
    SI_ADDONLOADOUTS_UPDATE_ACTIVE_TOOLTIP_NAMED = "Remplacer « %s » par vos addons actuellement activés (dernière sélection appliquée).",
    SI_ADDONLOADOUTS_UPDATE_ACTIVE_TOOLTIP_NONE = "Appliquez d'abord une sélection ; vous pourrez ensuite la mettre à jour avec votre choix actuel.",
    SI_ADDONLOADOUTS_MOVE_UP = "Monter",
    SI_ADDONLOADOUTS_MOVE_DOWN = "Descendre",
    SI_ADDONLOADOUTS_ORGANIZE = "Gérer les sélections",
    SI_ADDONLOADOUTS_ORGANIZE_TITLE = "Gérer les sélections",
    SI_ADDONLOADOUTS_LOADOUT_TOOLTIP_EMPTY = "(Aucun addon activé dans cette sélection.)",
}

for stringId, stringValue in pairs(strings) do
    SafeAddString(_G[stringId], stringValue, 2)
end
