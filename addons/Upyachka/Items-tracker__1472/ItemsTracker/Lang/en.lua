local LocaleUtils = LibStub:GetLibrary("Up_LocaleUtils")

--- English localization file.

-- Version for proper saving in EsoStringVersions.
local localizationVersion = 1
-- Table with localized names.
local localizedStrings = {
    ITEMS_TRACKER_ADDON_NAME = "|c99004cItemsTracker|r",
    ITEMS_TRACKER_ADD_TO_TRACKING = "Track number",
    SI_BINDING_NAME_ITEMS_TRACKER_STOP_TRACKING = "Stop tracking of all items",
    SI_BINDING_NAME_ITEMS_TRACKER_VISIBILITY_TOGGLE = "Show/Hide",
}
LocaleUtils.register(localizedStrings, localizationVersion)
