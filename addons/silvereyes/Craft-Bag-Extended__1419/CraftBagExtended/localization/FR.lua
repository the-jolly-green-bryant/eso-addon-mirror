local strings = {
    ["SI_CBE_AND"]                                             = " et ",
    ["SI_CBE_PRIMARY_ACTIONS_USE_DEFAULT"]                     = "Affecter le stockage/retrait rapide",
    ["SI_CBE_PRIMARY_ACTIONS_USE_DEFAULT_TOOLTIP"]             = "La case à cocher par défaut de de la boîte de dialogue de stockage et de retrait affecte également les actions principales de stockage et de retrait. Si cette option est désactivée, les actions de retrait et de stockage utiliseront toujours la quantité maximale.",
}

-- Overwrite English strings
for stringId, value in pairs(strings) do
    CRAFTBAGEXTENDED_STRINGS[stringId] = value
end