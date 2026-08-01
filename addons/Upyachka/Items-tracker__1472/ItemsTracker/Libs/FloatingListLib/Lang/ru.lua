local LocaleUtils = LibStub:GetLibrary("Up_LocaleUtils")

--- Russian localization file.

-- Version for proper saving in EsoStringVersions.
local localizationVersion = 2
-- Table with localized names.
local localizedStrings = {
    SI_BINDING_NAME_VISIBILITY_TOGGLE = "Показать/скрыть",
    CONFIG_ICON_TEXTURE_PATH = "Путь к текстуре иконки",
    CONFIG_ICON_TEXTURE_PATH_TOOLTIP = "Укажите путь к текстуре иконки",
    CONFIG_ICON_SIZE = "Размер",
    CONFIG_ICON_TEXTURE_PATH_TOOLTIP = "Укажите размер иконки",
    CONFIG_ENABLED_STATE_TOGGLE = "Включен/Выключен",
    CONFIG_ENABLED_STATE_TOGGLE_TOOLTIP = "Позволяет включить или отключить элемент",
    CONFIG_WINDOW_BACKDROP_STATE = "Подложка для окна",
    CONFIG_UI_RELOAD_REQUIREMENT = "Потребуется перезагрузка интерфейса. Сразу.",
}
LocaleUtils.register(localizedStrings, localizationVersion)
