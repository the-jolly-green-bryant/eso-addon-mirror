local LocaleUtils = LibStub:GetLibrary("Up_LocaleUtils")

--- Russian localization file.

-- Version for proper saving in EsoStringVersions.
local localizationVersion = 1
-- Table with localized names.
local localizedStrings = {
    THIEF_HELPER_ADDON_NAME = "|c99004cВоровской помощник|r",

    SI_BINDING_NAME_THIEF_HELPER_VISIBILITY_TOGGLE = "Показать/Скрыть",

    FENCE_DATA_PROVIDER_ADDON_NAME = "|c99004cСкупщик краденого|r",
    FENCE_DATA_PROVIDER_ADDON_DESC = "Отображает информацию о скупщике краденого.",

    FENCE_DATA_PROVIDER_CONFIG_SOLD_INDICATOR = "Индикатор количества проданных скупщику вещей",
    FENCE_DATA_PROVIDER_CONFIG_LIMIT_INDICATOR = "Индикатор ограничения количества продаваемых скупщику вещей",

    THIEF_BAG_DATA_PROVIDER_ADDON_NAME = "|c99004cСумка вора|r",
    THIEF_BAG_DATA_PROVIDER_ADDON_DESC = "Отображает информацию о вороманных предметах в сумке.",

    THIEF_BAG_DATA_PROVIDER_CONFIG_STOLEN_INDICATOR = "Индикатор количества краденых вещей в сумке",
    THIEF_BAG_DATA_PROVIDER_CONFIG_STOLEN_COST_INDICATOR = "Индикатор цены краденых вещей в сумке",
}
LocaleUtils.register(localizedStrings, localizationVersion)
