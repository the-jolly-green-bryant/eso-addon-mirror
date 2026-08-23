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
    SI_COVETOUSCOUNTESSASSISTANT_OPTION_HIGHLIGHT_QUEST_ITEMS
        = "Підсвічувати збіги предметів завдання",
    SI_COVETOUSCOUNTESSASSISTANT_OPTION_HIGHLIGHT_QUEST_ITEMS_TOOLTIP
        = "Забарвлює значки предметів у зелений, якщо вони відповідають тегам активного завдання.",
    SI_COVETOUSCOUNTESSASSISTANT_MSG_HIGHLIGHT_ON
        = "Підсвічування предметів завдання: УВІМК.",
    SI_COVETOUSCOUNTESSASSISTANT_MSG_HIGHLIGHT_OFF
        = "Підсвічування предметів завдання: ВИМК.",
    SI_COVETOUSCOUNTESSASSISTANT_OPTION_AUTOSKIP_TIPBOARD
        = "Авто-пропуск пропозицій Дошки підказок",
    SI_COVETOUSCOUNTESSASSISTANT_OPTION_AUTOSKIP_TIPBOARD_TOOLTIP
        = "Автоматично закривати пропозиції Дошки підказок, які не стосуються Жадібної графині.",
    SI_COVETOUSCOUNTESSASSISTANT_OPTION_AUTOSKIP_TIPBOARD_WARNING
        = "Це автоматично закриє діалоги, що не стосуються графині.",
    SI_COVETOUSCOUNTESSASSISTANT_MSG_AUTOSKIP_ON
        = "Авто-пропуск Дошки підказок: УВІМК",
    SI_COVETOUSCOUNTESSASSISTANT_MSG_AUTOSKIP_OFF
        = "Авто-пропуск Дошки підказок: ВИМК",
}

for stringId, stringValue in pairs(strings) do
    SafeAddString(_G[stringId], stringValue, 2)
end
