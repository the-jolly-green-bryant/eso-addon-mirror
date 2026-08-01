SpawnPoints = SpawnPoints or {}

local localization = { 

    LOADED_STR = "%s %s %s",
    WAS_LOADED = "загружен",
    NOT_LOADED = "НЕ загружено",
    NAME_SUPPRESS = "Подавить сообщение о загрузке дополнения",
    TOOLTIP_SUPPRESS = "Подавить сообщение в окне чата о том, что дополнение было успешно загружено.",
    SETTINGS_GENERAL_OPTIONS_HEADER = "НАСТРОЙКИ ПИН-кода КАРТЫ",
    SETTINGS_MAP_PIN_ICON_LABEL = "Выберите значок отметки на карте",
    SETTINGS_MAP_PIN_ICON_DESCRIPTION = "Выберите значок отметки на карте",
    SETTINGS_MAP_PIN_SIZE_LABEL = "Размер контакта",
    SETTINGS_MAP_PIN_SIZE_DESCRIPTION = "Установить размер отметок карты",
    SETTINGS_MAP_PIN_COLOR_LABEL = "Цвет булавки",
    SETTINGS_MAP_PIN_COLOR_DESCRIPTION = "Установить цвет отметок на карте",
    SETTINGS_CLICKABLE_LABEL = "Нажатие на отметки на карте SpawnPoints устанавливает путевую точку",
    SETTINGS_CLICKABLE_DESCRIPTION = "Разрешить или запретить нажатие на отметку на карте, чтобы разместить путевую точку на карте?",
    CLICK_HANDLER_NAME = "Установить точку появления Волендранга",
    PIN_FILTER_NAME = "Точки появления Волендранга",
}

if SpawnPoints.Localization and #localization == #SpawnPoints.Localization then
    ZO_ShallowTableCopy(localization, SpawnPoints.Localization)
end