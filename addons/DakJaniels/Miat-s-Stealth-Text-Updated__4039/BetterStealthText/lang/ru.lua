local strings =
{
    -- Main state strings
    BETTERSTEALTHTEXT_INVISIBLE = "Невидимый",
    BETTERSTEALTHTEXT_REVEALED = "Обнаружен",
    BETTERSTEALTHTEXT_HIDING = "Скрывается",

    -- Addon menu and option strings
    BETTERSTEALTHTEXT_ADDON_NAME = "Текст скрытности Миат",
    BETTERSTEALTHTEXT_ADDON_OPTIONS = "Опции текста скрытности Миат",
    BETTERSTEALTHTEXT_ADDON_ENABLED = "АДДОН ВКЛЮЧЕН",
    BETTERSTEALTHTEXT_ADDON_ENABLED_TOOLTIP = "ВКЛ - включено, ВЫКЛ - выключено",
    BETTERSTEALTHTEXT_ACCOUNTWIDE = "Одинаковые настройки для всех персонажей",
    BETTERSTEALTHTEXT_ACCOUNTWIDE_TOOLTIP = "ВКЛ - каждый персонаж имеет одинаковый набор настроек, ВЫКЛ - отдельные настройки для каждого персонажа",
    BETTERSTEALTHTEXT_ACCOUNTWIDE_WARNING = "Включение этой опции перезагрузит интерфейс",
    BETTERSTEALTHTEXT_DISPLAY_OPTIONS = "Настройки отображения",
    BETTERSTEALTHTEXT_SCALE = "Установить масштаб текста скрытности (%)",
    BETTERSTEALTHTEXT_SCALE_TOOLTIP = "Масштаб иконки и текста от 50% до 400% от оригинального размера",
    BETTERSTEALTHTEXT_STEALTH_COLORS_OPTIONS = "Настройки цветов скрытности",
    BETTERSTEALTHTEXT_SAME_HIDDEN_INVISIBLE = "Одинаковый цвет для состояний скрытности СКРЫТ и НЕВИДИМЫЙ",
    BETTERSTEALTHTEXT_SAME_HIDDEN_INVISIBLE_TOOLTIP = "ВКЛ - включено (цвет СКРЫТ применяется к НЕВИДИМЫЙ), ВЫКЛ - выключено (отдельные настройки для СКРЫТ и НЕВИДИМЫЙ)",
    BETTERSTEALTHTEXT_HIDDEN_COLOR = "Выбрать цвет для состояния СКРЫТ",
    BETTERSTEALTHTEXT_HIDDEN_COLOR_TOOLTIP = "Выбрать цвет текста для состояния скрытности СКРЫТ",
    BETTERSTEALTHTEXT_INVISIBLE_COLOR = "Выбрать цвет для состояния НЕВИДИМЫЙ",
    BETTERSTEALTHTEXT_INVISIBLE_COLOR_TOOLTIP = "Выбрать цвет текста для состояния скрытности НЕВИДИМЫЙ",
    BETTERSTEALTHTEXT_SAME_ALMOST_HIDDEN_INVISIBLE = "Одинаковый цвет для состояний скрытности СКРЫТ и НЕВИДИМЫЙ почти обнаружен",
    BETTERSTEALTHTEXT_SAME_ALMOST_HIDDEN_INVISIBLE_TOOLTIP = "ВКЛ - включено (цвет СКРЫТ применяется к НЕВИДИМЫЙ) для состояний почти обнаружен, ВЫКЛ - выключено (отдельные настройки для СКРЫТ и НЕВИДИМЫЙ) для состояний почти обнаружен",
    BETTERSTEALTHTEXT_HIDDEN_ALMOST_COLOR = "Выбрать цвет для состояния СКРЫТ ПОЧТИ ОБНАРУЖЕН",
    BETTERSTEALTHTEXT_HIDDEN_ALMOST_COLOR_TOOLTIP = "Выбрать цвет текста для состояния скрытности СКРЫТ ПОЧТИ ОБНАРУЖЕН",
    BETTERSTEALTHTEXT_INVISIBLE_ALMOST_COLOR = "Выбрать цвет для состояния НЕВИДИМЫЙ ПОЧТИ ОБНАРУЖЕН",
    BETTERSTEALTHTEXT_INVISIBLE_ALMOST_COLOR_TOOLTIP = "Выбрать цвет текста для состояния скрытности НЕВИДИМЫЙ ПОЧТИ ОБНАРУЖЕН",
    BETTERSTEALTHTEXT_ENABLE_HIDING = "Включить текст 'СКРЫВАЕТСЯ'",
    BETTERSTEALTHTEXT_ENABLE_HIDING_TOOLTIP = "ВКЛ - включено, ВЫКЛ - выключено",
    BETTERSTEALTHTEXT_HIDING_COLOR = "Выбрать цвет для состояния СКРЫВАЕТСЯ",
    BETTERSTEALTHTEXT_HIDING_COLOR_TOOLTIP = "Выбрать цвет текста для состояния скрытности СКРЫВАЕТСЯ",
    BETTERSTEALTHTEXT_DETECTED_COLOR = "Выбрать цвет для состояния ОБНАРУЖЕН",
    BETTERSTEALTHTEXT_DETECTED_COLOR_TOOLTIP = "Выбрать цвет текста для состояния скрытности ОБНАРУЖЕН",
    BETTERSTEALTHTEXT_REVEALED_COLOR = "Выбрать цвет для состояния РАСКРЫТ",
    BETTERSTEALTHTEXT_REVEALED_COLOR_TOOLTIP = "Выбрать цвет текста для состояния скрытности РАСКРЫТ",
    BETTERSTEALTHTEXT_DISGUISE_COLORS_OPTIONS = "Настройки цветов маскировки",
    BETTERSTEALTHTEXT_DISGUISED_COLOR = "Выбрать цвет для состояния ЗАМАСКИРОВАН",
    BETTERSTEALTHTEXT_DISGUISED_COLOR_TOOLTIP = "Выбрать цвет текста для состояния маскировки ЗАМАСКИРОВАН",
    BETTERSTEALTHTEXT_SUSPICIOUS_COLOR = "Выбрать цвет для состояния ПОДОЗРИТЕЛЬНЫЙ",
    BETTERSTEALTHTEXT_SUSPICIOUS_COLOR_TOOLTIP = "Выбрать цвет текста для состояния маскировки ПОДОЗРИТЕЛЬНЫЙ",
    BETTERSTEALTHTEXT_DANGER_COLOR = "Выбрать цвет для состояния ОПАСНОСТЬ",
    BETTERSTEALTHTEXT_DANGER_COLOR_TOOLTIP = "Выбрать цвет текста для состояния маскировки ОПАСНОСТЬ",
    BETTERSTEALTHTEXT_DISCOVERED_COLOR = "Выбрать цвет для состояния РАЗОБЛАЧЕН",
    BETTERSTEALTHTEXT_DISCOVERED_COLOR_TOOLTIP = "Выбрать цвет текста для состояния маскировки РАЗОБЛАЧЕН"
}

for stringId, stringValue in pairs(strings) do
    SafeAddString(_G[stringId], stringValue, 2)
end
