local strings =
{
    SI_ADDONLOADOUTS_LOADOUTS = "Loadouts",
    SI_ADDONLOADOUTS_SAVE_CURRENT = "Save current as new loadout",
    SI_ADDONLOADOUTS_APPLY_LOADOUT = "Apply loadout",
    SI_ADDONLOADOUTS_APPLY_LOADOUT_TOOLTIP = "Choose a saved loadout to apply, then reload UI.",
    SI_ADDONLOADOUTS_LOAD = "Load",
    SI_ADDONLOADOUTS_DELETE = "Delete",
    SI_ADDONLOADOUTS_NEW_LOADOUT_NAME = "New loadout name",
    SI_ADDONLOADOUTS_APPLY = "Apply",
    SI_ADDONLOADOUTS_RELOADING = "Loadout applied. Reloading UI...",
    SI_ADDONLOADOUTS_NO_LOADOUTS = "No loadouts saved. Save current addon state as a new loadout from Settings.",
    SI_ADDONLOADOUTS_UPDATE_ACTIVE = "Update active loadout",
    SI_ADDONLOADOUTS_UPDATE_ACTIVE_TOOLTIP_NAMED = "Overwrite \"%s\" with your current enabled addons (the loadout you last applied).",
    SI_ADDONLOADOUTS_UPDATE_ACTIVE_TOOLTIP_NONE = "Apply a loadout first; then you can update it with your current addon selection.",
    SI_ADDONLOADOUTS_MOVE_UP = "Move up",
    SI_ADDONLOADOUTS_MOVE_DOWN = "Move down",
    SI_ADDONLOADOUTS_ORGANIZE = "Organize loadouts",
    SI_ADDONLOADOUTS_ORGANIZE_TITLE = "Organize loadouts",
    SI_ADDONLOADOUTS_LOADOUT_TOOLTIP_EMPTY = "(No addons enabled in this loadout.)",
}

for stringId, stringValue in pairs(strings) do
    ZO_CreateStringId(stringId, stringValue)
    SafeAddVersion(stringId, 1)
end
