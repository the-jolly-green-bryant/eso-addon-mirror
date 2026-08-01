local strings = {
    ["SI_AUTORESEARCH_BAGS"]                   = "Sacs pour rechercher de l'équipement à la recherche",
    ["SI_AUTORESEARCH_STYLES"]                 = GetString(SI_SMITHING_HEADER_STYLE),
    ["SI_AUTORESEARCH_SETS"]                   = GetString(SI_MASTER_WRIT_DESCRIPTION_SET),
    ["SI_AUTORESEARCH_CHAT_MESSAGES"]          = "Messages Chat",
    ["SI_AUTORESEARCH_SHORT_PREFIX"]           = "Utiliser le préfixe court dans la messagerie",
    ["SI_AUTORESEARCH_SHORT_PREFIX_TOOLTIP"]   = "Affiche le préfixe AR au lieu de AutoResearch dans les messages de discussion.",
    ["SI_AUTORESEARCH_COLORED_PREFIX"]         = "Verwenden die AutoResearch 1 Präfix Farbe",
    ["SI_AUTORESEARCH_COLORED_PREFIX_TOOLTIP"] = "Fait que le préfixe des messages de discussion utilise les couleurs bleues de AutoResearch 1 (c'est-à-dire |c99CCEFAutoResearch|r ou |c99CCEFAR|r) au lieu du paramètre Couleur des Messages Chat.",
    ["SI_AUTORESEARCH_CHAT_USE_SYSTEM_COLOR"]  = "Utiliser la couleur de message système par défaut",
    ["SI_AUTORESEARCH_CHAT_COLOR"]             = "Couleur des Messages Chat",
}

-- Overwrite English strings
for stringId, value in pairs(strings) do
    AUTORESEARCH_STRINGS[stringId] = value
end