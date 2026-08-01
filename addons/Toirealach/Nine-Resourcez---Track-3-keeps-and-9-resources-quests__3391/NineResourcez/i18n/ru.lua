NineResourcez = NineResourcez or {}

local localization = {
    
    LOADED_STR = "%s %s %s",
    WAS_LOADED = "загружен",
    NOT_LOADED = "НЕ загружено",
   
    SETTINGS_GENERAL_OPTIONS_HEADER = "НАСТРОЙКИ ПИН-кода КАРТЫ",
    SETTINGS_SUPPRESS_MSGS_LABEL = "Подавить сбор ресурсов и другие сообщения",
    SETTINGS_SUPPRESS_MSGS_DESCRIPTION = "Подавить сбор ресурсов и другие сообщения в окне чата",
    SETTINGS_MAP_PIN_ICON_LABEL = "Выберите значок отметки на карте",
    SETTINGS_MAP_PIN_ICON_DESCRIPTION = "Выберите значок отметки на карте",
    SETTINGS_MAP_PIN_SIZE_LABEL = "Размер контакта",
    SETTINGS_MAP_PIN_SIZE_DESCRIPTION = "Установить размер отметок карты",
    SETTINGS_MAP_PIN_COLOR_LABEL = "Цвет булавки",
    SETTINGS_MAP_PIN_COLOR_DESCRIPTION = "Установить цвет отметок на карте",
    SETTINGS_MAP_PIN_LEVEL_LABEL = "Уровень контакта",
    SETTINGS_MAP_PIN_LEVEL_DESCRIPTION = "Установить уровень метки карты",
    CLICK_HANDLER_NAME = "Установить маршрутную точку для захваченной цели",
    PIN_FILTER_NAME = "Захватите девять ресурсов или три замка",
    NOW_TRACKING = "Текущая задача отслеживания: %s",
    YOU_CAPTURED = "Захвачен",
    QUEST_COMPLETED = "Квест %s выполнен!",
    QUEST_ABANDONED = "Квест %s прерван.",
    NEITHER_QUEST = "В вашем журнале квестов нет ни %s, ни %s.",
}

if NineResourcez.Localization and #localization == #NineResourcez.Localization then
    ZO_ShallowTableCopy(localization, NineResourcez.Localization)
end