local strings = {
    ["SI_QUALITYSORT_AUTO"]        = "Trier automatiquement par qualité",
    ["SI_QUALITYSORT_SORT_ORDER"]  = "Ordre de tri",
    ["SI_QUALITYSORT_EQUIP_SLOT"]  = "Emplacement d'équipement (i.e. poitrine, épaule, etc.)",
    ["SI_QUALITYSORT_STYLE"]       = "Style d'objets",
    ["SI_QUALITYSORT_SET"]         = "Ensembles d'objets",
    ["SI_QUALITYSORT_ID"]          = "Identifiant unique d'objets",
    ["SI_QUALITYSORT_VOUCHERS"]    = "Quantité d'assignats",
    ["SI_QUALITYSORT_MASTER_WRIT"] = "Conditions de commande de maître",
    ["SI_QUALITYSORT_ASCENDING"]   = "Ordre croissant",
    ["SI_QUALITYSORT_DESCENDING"]  = "Ordre décroissant",
}

-- Overwrite English strings
for stringId, value in pairs(strings) do
    QUALITYSORT_STRINGS[stringId] = value
end