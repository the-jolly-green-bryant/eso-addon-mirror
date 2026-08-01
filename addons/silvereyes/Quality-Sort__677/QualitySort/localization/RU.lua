local strings = {
    ["SI_QUALITYSORT_AUTO"]        = "Автоматическая cортировка по качеству",
    ["SI_QUALITYSORT_SORT_ORDER"]  = "Порядок cортировки",
    ["SI_QUALITYSORT_EQUIP_SLOT"]  = "Слот (например: грудь, плечи и т.д.)",
    ["SI_QUALITYSORT_STYLE"]       = "Стиль",
    ["SI_QUALITYSORT_SET"]         = "Набор предмета",
    ["SI_QUALITYSORT_ID"]          = "Уникальный идентификатор предмета",
    ["SI_QUALITYSORT_VOUCHERS"]    = "Врит заказ значение",
    ["SI_QUALITYSORT_MASTER_WRIT"] = "Врит заказ требования",
    ["SI_QUALITYSORT_ASCENDING"]   = "По возрастанию",
    ["SI_QUALITYSORT_DESCENDING"]  = "По убыванию",
}

-- Overwrite English strings
for stringId, value in pairs(strings) do
    QUALITYSORT_STRINGS[stringId] = value
end