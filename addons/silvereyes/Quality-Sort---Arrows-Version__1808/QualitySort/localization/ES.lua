local strings = {
    ["SI_QUALITYSORT_AUTO"]        = "Ordenar automáticamente por calidad",
    ["SI_QUALITYSORT_SORT_ORDER"]  = "Orden de clasificación",
    ["SI_QUALITYSORT_EQUIP_SLOT"]  = "Ranura de equip. (ej. casco, hombreras, etc.)",
    ["SI_QUALITYSORT_STYLE"]       = "Estilo",
    ["SI_QUALITYSORT_SET"]         = "Conjunto",
    ["SI_QUALITYSORT_ID"]          = "Id. único de objetos",
    ["SI_QUALITYSORT_VOUCHERS"]    = "Cant. de vales de encomienda",
    ["SI_QUALITYSORT_MASTER_WRIT"] = "Req. de encargos de maestro",
    ["SI_QUALITYSORT_ASCENDING"]   = "Orden ascendente",
    ["SI_QUALITYSORT_DESCENDING"]  = "Orden descendente",
}

-- Overwrite English strings
for stringId, value in pairs(strings) do
    QUALITYSORT_STRINGS[stringId] = value
end