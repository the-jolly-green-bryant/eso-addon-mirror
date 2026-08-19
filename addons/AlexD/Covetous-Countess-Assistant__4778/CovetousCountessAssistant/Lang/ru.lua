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
}

for stringId, stringValue in pairs(strings) do
    SafeAddString(_G[stringId], stringValue, 2)
end
