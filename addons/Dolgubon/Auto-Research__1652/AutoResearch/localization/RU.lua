local strings = {
    ["SI_AUTORESEARCH_BAGS"]                   = "Сумки для поиска оборудования для исследования",
    ["SI_AUTORESEARCH_STYLES"]                 = GetString(SI_SMITHING_HEADER_STYLE),
    ["SI_AUTORESEARCH_SETS"]                   = GetString(SI_MASTER_WRIT_DESCRIPTION_SET),
    ["SI_AUTORESEARCH_CHAT_MESSAGES"]          = "Сообщения чата",
    ["SI_AUTORESEARCH_SHORT_PREFIX"]           = "Короткий префикс для сообщений в чат",
    ["SI_AUTORESEARCH_SHORT_PREFIX_TOOLTIP"]   = "Когда включено, все сообщения в чат будут иметь префикс AR вместо AutoResearch.",
    ["SI_AUTORESEARCH_COLORED_PREFIX"]         = "Используйте цвета префикса AutoResearch 1",
    ["SI_AUTORESEARCH_COLORED_PREFIX_TOOLTIP"] = "Заставляет префикс для сообщений чата использовать синий цвет AutoResearch 1 (т. Е. |c99CCEFAutoResearch|r или |c99CCEFAR|r) вместо использования настройка «Цвет сообщения чата».",
    ["SI_AUTORESEARCH_CHAT_USE_SYSTEM_COLOR"]  = "Используйте цвет системного сообщения по умолчанию",
    ["SI_AUTORESEARCH_CHAT_COLOR"]             = "Цвет сообщения чата",
}

-- Overwrite English strings
for stringId, value in pairs(strings) do
    AUTORESEARCH_STRINGS[stringId] = value
end