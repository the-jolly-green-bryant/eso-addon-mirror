local strings =
{
    SI_ADDONLOADOUTS_LOADOUTS = "Cargas",
    SI_ADDONLOADOUTS_SAVE_CURRENT = "Guardar actual como nueva carga",
    SI_ADDONLOADOUTS_APPLY_LOADOUT = "Aplicar carga",
    SI_ADDONLOADOUTS_APPLY_LOADOUT_TOOLTIP = "Elige una carga guardada para aplicar, luego recarga la interfaz.",
    SI_ADDONLOADOUTS_LOAD = "Cargar",
    SI_ADDONLOADOUTS_DELETE = "Eliminar",
    SI_ADDONLOADOUTS_NEW_LOADOUT_NAME = "Nombre de la nueva carga",
    SI_ADDONLOADOUTS_APPLY = "Aplicar",
    SI_ADDONLOADOUTS_RELOADING = "Carga aplicada. Recargando interfaz...",
    SI_ADDONLOADOUTS_NO_LOADOUTS = "No hay cargas guardadas. Guarda el estado actual de los addons como nueva carga en Ajustes.",
    SI_ADDONLOADOUTS_UPDATE_ACTIVE = "Actualizar carga activa",
    SI_ADDONLOADOUTS_UPDATE_ACTIVE_TOOLTIP_NAMED = "Sobrescribir \"%s\" con los addons activados actualmente (la última carga aplicada).",
    SI_ADDONLOADOUTS_UPDATE_ACTIVE_TOOLTIP_NONE = "Aplica una carga primero; luego puedes actualizarla con tu selección actual.",
    SI_ADDONLOADOUTS_MOVE_UP = "Subir",
    SI_ADDONLOADOUTS_MOVE_DOWN = "Bajar",
    SI_ADDONLOADOUTS_ORGANIZE = "Organizar cargas",
    SI_ADDONLOADOUTS_ORGANIZE_TITLE = "Organizar cargas",
    SI_ADDONLOADOUTS_LOADOUT_TOOLTIP_EMPTY = "(Ningún addon activado en esta carga.)",
}

for stringId, stringValue in pairs(strings) do
    SafeAddString(_G[stringId], stringValue, 2)
end
