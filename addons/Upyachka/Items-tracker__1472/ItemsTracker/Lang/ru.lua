local LocaleUtils = LibStub:GetLibrary("Up_LocaleUtils")

--- Russian localization file.

-- Version for proper saving in EsoStringVersions.
local localizationVersion = 1
-- Table with localized names.
local localizedStrings = {
    ITEMS_TRACKER_ADDON_NAME = "|c99004cОтслеживание|r",
    ITEMS_TRACKER_ADD_TO_TRACKING = "Отслеживать количество",
    SI_BINDING_NAME_ITEMS_TRACKER_STOP_TRACKING = "Остановить отслеживание всех предметов",
    SI_BINDING_NAME_ITEMS_TRACKER_VISIBILITY_TOGGLE = "Показать/скрыть",
}
LocaleUtils.register(localizedStrings, localizationVersion)
