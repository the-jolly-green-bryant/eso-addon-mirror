local strings = {
    SI_COVETOUSCOUNTESSASSISTANT_OPTION_TRACK_COUNTESS
        = "Отслеживать Алчную графиню",
    SI_COVETOUSCOUNTESSASSISTANT_OPTION_TRACK_COUNTESS_TOOLTIP
        = "Отмечать сокровища, подходящие для охот Алчной графини.",
    SI_COVETOUSCOUNTESSASSISTANT_OPTION_TRACK_CROW
        = "Отслеживать Казначея дани",
    SI_COVETOUSCOUNTESSASSISTANT_OPTION_TRACK_CROW_TOOLTIP
        = "Отмечать сокровища, подходящие для охот Казначея дани (Ворон).",
    SI_COVETOUSCOUNTESSASSISTANT_OPTION_SETTINGS
        = "Настройки",
    SI_COVETOUSCOUNTESSASSISTANT_MSG_COUNTESS_ON
        = "Отслеживание Алчной графини: ВКЛ",
    SI_COVETOUSCOUNTESSASSISTANT_MSG_COUNTESS_OFF
        = "Отслеживание Алчной графини: ВЫКЛ",
    SI_COVETOUSCOUNTESSASSISTANT_MSG_CROW_ON
        = "Отслеживание Казначея дани: ВКЛ",
    SI_COVETOUSCOUNTESSASSISTANT_MSG_CROW_OFF
        = "Отслеживание Казначея дани: ВЫКЛ",
    SI_COVETOUSCOUNTESSASSISTANT_OPTION_HIGHLIGHT_QUEST_ITEMS
        = "Подсветка совпадений предметов заданий",
    SI_COVETOUSCOUNTESSASSISTANT_OPTION_HIGHLIGHT_QUEST_ITEMS_TOOLTIP
        = "Окрашивает значки предметов в зелёный цвет при совпадении с тегами активного задания.",
    SI_COVETOUSCOUNTESSASSISTANT_MSG_HIGHLIGHT_ON
        = "Подсветка предметов задания: ВКЛ",
    SI_COVETOUSCOUNTESSASSISTANT_MSG_HIGHLIGHT_OFF
        = "Подсветка предметов задания: ВЫКЛ",
    SI_COVETOUSCOUNTESSASSISTANT_OPTION_AUTOSKIP_TIPBOARD
        = "Авто-пропуск предложений Доски подсказок",
    SI_COVETOUSCOUNTESSASSISTANT_OPTION_AUTOSKIP_TIPBOARD_TOOLTIP
        = "Автоматически закрывать предложения Доски подсказок, не относящиеся к Алчной графине.",
    SI_COVETOUSCOUNTESSASSISTANT_OPTION_AUTOSKIP_TIPBOARD_WARNING
        = "Это автоматически закроет диалоги, не связанные с графиней.",
    SI_COVETOUSCOUNTESSASSISTANT_MSG_AUTOSKIP_ON
        = "Авто-пропуск Доски подсказок: ВКЛ",
    SI_COVETOUSCOUNTESSASSISTANT_MSG_AUTOSKIP_OFF
        = "Авто-пропуск Доски подсказок: ВЫКЛ",
}

for stringId, stringValue in pairs(strings) do
    SafeAddString(_G[stringId], stringValue, 2)
end
