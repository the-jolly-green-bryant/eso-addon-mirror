--- Settings menu for FenceDataProvider.
FenceDataProviderSettingsMenu = {}
-- name of addon required by Up_AddonConfigurator.
FenceDataProviderSettingsMenu.name = "FenceDataProvider_SettingsMenu"
--- LibAddonMenu reference.
local SettingsMenu = LibStub:GetLibrary("Up_FloatingWindowSettingsMenu")

--- Describes menu for fence data provider.
function FenceDataProviderSettingsMenu.createOptionsData(addon)
    return {
        [1] = {
            type = "description",
            text = GetString(FENCE_DATA_PROVIDER_ADDON_DESC),
        },
        [2] = {
            type = "submenu",
            name = GetString(FENCE_DATA_PROVIDER_CONFIG_SOLD_INDICATOR),
            tooltip = nil,
            controls = SettingsMenu.createIndicatorWithIconControls(addon.Settings.Icons.SoldStolenItemsNumberIndicator, addon.Default.Settings.Icons.SoldStolenItemsNumberIndicator),
        },
        [3] = {
            type = "submenu",
            name = GetString(FENCE_DATA_PROVIDER_CONFIG_LIMIT_INDICATOR),
            tooltip = nil,
            controls = SettingsMenu.createIndicatorWithIconControls(addon.Settings.Icons.StolenItemsSellingLimitIndicator, addon.Default.Settings.Icons.StolenItemsSellingLimitIndicator),
        },
    }
end

--- Creates settings menu for fence data provider.
function FenceDataProviderSettingsMenu.createMenu(addon)
    local optionsData = FenceDataProviderSettingsMenu.createOptionsData(addon)
    SettingsMenu.createMenu(addon, optionsData, GetString(FENCE_DATA_PROVIDER_ADDON_NAME))
end
