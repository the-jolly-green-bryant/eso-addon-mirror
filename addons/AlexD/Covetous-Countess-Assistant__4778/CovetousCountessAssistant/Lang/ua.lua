local strings = {
    SI_COVETOUSCOUNTESSASSISTANT_OPTION_TRACK_COUNTESS
        = "Відстежувати Жадібну графиню",
    SI_COVETOUSCOUNTESSASSISTANT_OPTION_TRACK_COUNTESS_TOOLTIP
        = "Позначати скарби, придатні для полювань Жадібної графині.",
    SI_COVETOUSCOUNTESSASSISTANT_OPTION_TRACK_CROW
        = "Відстежувати Скарбника данини",
    SI_COVETOUSCOUNTESSASSISTANT_OPTION_TRACK_CROW_TOOLTIP
        = "Позначати скарби, придатні для полювань Скарбника данини (Ворон).",
    SI_COVETOUSCOUNTESSASSISTANT_OPTION_SETTINGS
        = "Налаштування",
    SI_COVETOUSCOUNTESSASSISTANT_MSG_COUNTESS_ON
        = "Відстеження Жадібної графині: УВІМК",
    SI_COVETOUSCOUNTESSASSISTANT_MSG_COUNTESS_OFF
        = "Відстеження Жадібної графині: ВИМК",
    SI_COVETOUSCOUNTESSASSISTANT_MSG_CROW_ON
        = "Відстеження Скарбника данини: УВІМК",
    SI_COVETOUSCOUNTESSASSISTANT_MSG_CROW_OFF
        = "Відстеження Скарбника данини: ВИМК",
}

for stringId, stringValue in pairs(strings) do
    SafeAddString(_G[stringId], stringValue, 2)
end
