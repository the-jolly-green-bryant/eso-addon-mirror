local LocaleUtils = LibStub:GetLibrary("Up_LocaleUtils")

--- English localization file.

-- Version for proper saving in EsoStringVersions.
local localizationVersion = 1
-- Table with localized names.
local localizedStrings = {
    THIEF_HELPER_ADDON_NAME = "|c99004cThiefHelper|r",

    SI_BINDING_NAME_THIEF_HELPER_VISIBILITY_TOGGLE = "Show/Hide",

    FENCE_DATA_PROVIDER_ADDON_NAME = "|c99004cFence data provider|r",
    FENCE_DATA_PROVIDER_ADDON_DESC = "Displays actual fence information.",

    FENCE_DATA_PROVIDER_CONFIG_SOLD_INDICATOR = "Sold stolen items count indicator",
    FENCE_DATA_PROVIDER_CONFIG_LIMIT_INDICATOR = "Selling limit for stolen items indicator",

    THIEF_BAG_DATA_PROVIDER_ADDON_NAME = "|c99004cThief bag data provider|r",
    THIEF_BAG_DATA_PROVIDER_ADDON_DESC = "Displays actual information about stolen items in bag.",

    THIEF_BAG_DATA_PROVIDER_CONFIG_STOLEN_INDICATOR = "Stolen items in bag count indicator",
    THIEF_BAG_DATA_PROVIDER_CONFIG_STOLEN_COST_INDICATOR = "Total cost of stolen items in bag count indicator",
}
LocaleUtils.register(localizedStrings, localizationVersion)
