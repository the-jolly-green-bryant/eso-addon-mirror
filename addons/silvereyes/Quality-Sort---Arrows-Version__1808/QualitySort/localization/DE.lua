local strings = {
    ["SI_QUALITYSORT_AUTO"]        = "Automatisch nach Qualität sortieren",
    ["SI_QUALITYSORT_SORT_ORDER"]  = "Sortierreihenfolge",
    ["SI_QUALITYSORT_EQUIP_SLOT"]  = "Rüstungsslot (z.B. Torso, Schultern, usw.)",
    ["SI_QUALITYSORT_STYLE"]       = "Gegenstandsstil",
    ["SI_QUALITYSORT_SET"]         = "Set-Gegenstände",
    ["SI_QUALITYSORT_ID"]          = "Identifikationsnummer",
    ["SI_QUALITYSORT_VOUCHERS"]    = "Anzahl Schriebscheine",
    ["SI_QUALITYSORT_MASTER_WRIT"] = "Meisterschriebanforderungen",
    ["SI_QUALITYSORT_ASCENDING"]   = "aufsteigend",
    ["SI_QUALITYSORT_DESCENDING"]  = "absteigend",
}

-- Overwrite English strings
for stringId, value in pairs(strings) do
    QUALITYSORT_STRINGS[stringId] = value
end