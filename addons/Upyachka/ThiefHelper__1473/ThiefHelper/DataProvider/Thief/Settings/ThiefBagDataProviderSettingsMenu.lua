--- Settings menu for ThiefBagDataProvider.
ThiefBagDataProviderSettingsMenu = {}
-- name of addon required by Up_AddonConfigurator.
ThiefBagDataProviderSettingsMenu.name = "ThiefBagDataProvider_SettingsMenu"
--- LibAddonMenu reference.
local SettingsMenu = LibStub:GetLibrary("Up_FloatingWindowSettingsMenu")

--- Describes menu for fence data provider.
function ThiefBagDataProviderSettingsMenu.createOptionsData(addon)
    return {
        [1] = {
            type = "description",
            text = GetString(THIEF_BAG_DATA_PROVIDER_ADDON_DESC),
        },
        [2] = {
            type = "submenu",
            name = GetString(THIEF_BAG_DATA_PROVIDER_CONFIG_STOLEN_INDICATOR),
            tooltip = nil,
            controls = SettingsMenu.createIndicatorWithIconControls(addon.Settings.Icons.StolenItemsNumberInBagIndicator, addon.Default.Settings.Icons.StolenItemsNumberInBagIndicator),
        },
        [3] = {
            type = "submenu",
            name = GetString(THIEF_BAG_DATA_PROVIDER_CONFIG_STOLEN_COST_INDICATOR),
            tooltip = nil,
            controls = SettingsMenu.createIndicatorWithIconControls(addon.Settings.Icons.StolenItemsCostInBagIndicator, addon.Default.Settings.Icons.StolenItemsCostInBagIndicator),
        },
    }
end

--- Creates settings menu for fence data provider.
function ThiefBagDataProviderSettingsMenu.createMenu(addon)
    local optionsData = ThiefBagDataProviderSettingsMenu.createOptionsData(addon)
    SettingsMenu.createMenu(addon, optionsData, GetString(THIEF_BAG_DATA_PROVIDER_ADDON_NAME))
end
