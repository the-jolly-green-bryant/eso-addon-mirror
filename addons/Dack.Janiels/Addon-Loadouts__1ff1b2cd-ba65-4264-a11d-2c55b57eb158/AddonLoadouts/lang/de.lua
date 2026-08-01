local strings =
{
    SI_ADDONLOADOUTS_LOADOUTS = "AddOn Packs",
    SI_ADDONLOADOUTS_SAVE_CURRENT = "Aktuelle als neuen Pack speichern",
    SI_ADDONLOADOUTS_APPLY_LOADOUT = "Pack laden",
    SI_ADDONLOADOUTS_APPLY_LOADOUT_TOOLTIP = "Wähle einen gespeicherten AddOn-Pack, danach wird die UI neu geladen.",
    SI_ADDONLOADOUTS_LOAD = "Laden",
    SI_ADDONLOADOUTS_DELETE = "Löschen",
    SI_ADDONLOADOUTS_NEW_LOADOUT_NAME = "Name des neuen Packs",
    SI_ADDONLOADOUTS_APPLY = "Anwenden",
    SI_ADDONLOADOUTS_RELOADING = "AddOn-Pack geladen. UI wird neu geladen...",
    SI_ADDONLOADOUTS_NO_LOADOUTS = "Kein AddOn-Pack gespeichert. Speichere die aktuell ausgewählten Addons in den Einstellungen als neuen Pack.",
    SI_ADDONLOADOUTS_UPDATE_ACTIVE = "Aktiven Pack aktualisieren",
    SI_ADDONLOADOUTS_UPDATE_ACTIVE_TOOLTIP_NAMED = "\"%s\" mit aktuell aktivierten Addons überschreiben (zuletzt geladener Pack).",
    SI_ADDONLOADOUTS_UPDATE_ACTIVE_TOOLTIP_NONE = "Zuerst einen Pack laden; danach kannst du ihn mit der aktuellen AddOn-Auswahl überschreiben.",
    SI_ADDONLOADOUTS_MOVE_UP = "Nach oben",
    SI_ADDONLOADOUTS_MOVE_DOWN = "Nach unten",
    SI_ADDONLOADOUTS_ORGANIZE = "Packs sortieren",
    SI_ADDONLOADOUTS_ORGANIZE_TITLE = "Packs sortieren",
    SI_ADDONLOADOUTS_LOADOUT_TOOLTIP_EMPTY = "(In diesem Pack sind keine Addons aktiviert.)",
}

for stringId, stringValue in pairs(strings) do
    SafeAddString(_G[stringId], stringValue, 2)
end
