local strings = {
    ["SI_AUTORESEARCH_BAGS"]                   = "Ausrüstungs-Taschen durchsuchen für Analyse",
    ["SI_AUTORESEARCH_STYLES"]                 = "Stile zum Analysieren",
    ["SI_AUTORESEARCH_SETS"]                   = "Set-Gegenstände zum Analysieren",
    ["SI_AUTORESEARCH_CHAT_MESSAGES"]          = "Chat-Nachrichten",
    ["SI_AUTORESEARCH_SHORT_PREFIX"]           = "Kurzes Präfix für Nachrichten",
    ["SI_AUTORESEARCH_SHORT_PREFIX_TOOLTIP"]   = "Wenn aktiviert, wird bei allen Chat-Nachrichten AR anstelle von AutoResearch vorangestellt.",
    ["SI_AUTORESEARCH_COLORED_PREFIX"]         = "Verwende die AutoResearch 1 Präfix Farbe",
    ["SI_AUTORESEARCH_COLORED_PREFIX_TOOLTIP"] = "Bewirkt, dass das Präfix für Chat-Nachrichten die blaue Farben von AutoResearch 1 (d. H. |c99CCEFAutoResearch|r oder |c99CCEFAR|r) anstelle der Einstellung für die Chat-Nachrichten Farbe verwendet.",
    ["SI_AUTORESEARCH_CHAT_USE_SYSTEM_COLOR"]  = "Dieselbe Farbe wie Systemnachrichten verwenden.",
    ["SI_AUTORESEARCH_CHAT_COLOR"]             = "Chat-Nachrichten Farbe",
}

-- Overwrite English strings
for stringId, value in pairs(strings) do
    AUTORESEARCH_STRINGS[stringId] = value
end
