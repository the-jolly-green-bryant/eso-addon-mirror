local LocaleUtils = LibStub:GetLibrary("Up_LocaleUtils")

--- English localization file.

-- Version for proper saving in EsoStringVersions.
local localizationVersion = 2
-- Table with localized names.
local localizedStrings = {
    SI_BINDING_NAME_VISIBILITY_TOGGLE = "Show/Hide",
    CONFIG_ICON_TEXTURE_PATH = "Path to icon texture",
    CONFIG_ICON_TEXTURE_PATH_TOOLTIP = "Specify icon location (its texture)",
    CONFIG_ICON_SIZE = "Size",
    CONFIG_ICON_TEXTURE_PATH_TOOLTIP = "Specify icon size",
    CONFIG_ENABLED_STATE_TOGGLE = "Enabled/Disabled",
    CONFIG_ENABLED_STATE_TOGGLE_TOOLTIP = "Allows to enable/disable element",
    CONFIG_WINDOW_BACKDROP_STATE = "Background state",
    CONFIG_UI_RELOAD_REQUIREMENT = "Switch will reload UI to apply new settings",
}
LocaleUtils.register(localizedStrings, localizationVersion)
