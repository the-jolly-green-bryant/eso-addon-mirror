--- Settings menu for ThiefHelper.
FenceDataProviderSettingsMenu = {}
-- name of addon required by Up_AddonConfigurator.
FenceDataProviderSettingsMenu.name = "FenceDataProvider_SettingsMenu"
--- LibAddonMenu reference.
local LibAddonMenu = LibStub:GetLibrary("LibAddonMenu-2.0")
--- Data for LibAddonMenu.
local settingsPanelInformation = {
    type = "panel",
    name = "FenceDataProvider",
    displayName = "Fence data provider settings",
    author = "Upyachka",
    version = "1.1",
    slashCommand = "/fence-data",
    registerForRefresh = true,
    registerForDefaults = true,
}

--- Returns new editbox binded to specified addon settings for icon path.
local function createIconPathConfigControl(iconSettings, defaultSettings)
    return {
        type = "editbox",
        name = GetString(CONFIG_ICON_TEXTURE_PATH),
        tooltip = GetString(CONFIG_ICON_TEXTURE_PATH_TOOLTIP),
        getFunc = function() return iconSettings.TexturePath end,
        setFunc = function(text) iconSettings.TexturePath = text end,
        isMultiline = true, --boolean
        width = "full", --or "half" (optional)
        disabled = true, --or boolean (optional)
        warning = nil, --(optional)
        default = defaultSettings.TexturePath, --(optional)
        reference = nil --(optional) unique global reference to control
    }
end

--- Returns new slider binded to specified addon settings for icon size.
local function createIconSizeConfigControl(iconSettings, defaultSettings)
    return {
        type = "slider",
        name = GetString(CONFIG_ICON_SIZE),
        tooltip = GetString(CONFIG_ICON_TEXTURE_PATH_TOOLTIP),
        min = 10,
        max = 50,
        step = 2,
        default = defaultSettings.Size, --(optional)
        getFunc = function() return iconSettings.Size end,
        setFunc = function(newValue) iconSettings.Size = newValue end
    }
end

--- Describes menu for fence data provider.
function FenceDataProviderSettingsMenu.createOptionsData(addon)
    return {
        [1] = {
            type = "header",
            name = GetString(FENCE_DATA_PROVIDER_ADDON_NAME)
        },
        [2] = {
            type = "description",
            text = GetString(FENCE_DATA_PROVIDER_ADDON_DESC),
        },
        [3] = {
            type = "submenu",
            name = GetString(FENCE_DATA_PROVIDER_CONFIG_SOLD_ICON),
            tooltip = nil,
            controls = {
                [1] = createIconPathConfigControl(addon.Settings.Icons.SoldStolenItemsNumberIcon, addon.Default.Settings.Icons.SoldStolenItemsNumberIcon),
                [2] = createIconSizeConfigControl(addon.Settings.Icons.SoldStolenItemsNumberIcon, addon.Default.Settings.Icons.SoldStolenItemsNumberIcon),
            }
        },
        [4] = {
            type = "submenu",
            name = GetString(FENCE_DATA_PROVIDER_CONFIG_STOLEN_ICON),
            tooltip = nil,
            controls = {
                [1] = createIconPathConfigControl(addon.Settings.Icons.StolenItemsNumberInBagIcon, addon.Default.Settings.Icons.StolenItemsNumberInBagIcon),
                [2] = createIconSizeConfigControl(addon.Settings.Icons.StolenItemsNumberInBagIcon, addon.Default.Settings.Icons.StolenItemsNumberInBagIcon),
            }
        },
        [5] = {
            type = "submenu",
            name = GetString(FENCE_DATA_PROVIDER_CONFIG_LIMIT_ICON),
            tooltip = nil,
            controls = {
                [1] = createIconPathConfigControl(addon.Settings.Icons.StolenItemsSellingLimitIcon, addon.Default.Settings.Icons.StolenItemsSellingLimitIcon),
                [2] = createIconSizeConfigControl(addon.Settings.Icons.StolenItemsSellingLimitIcon, addon.Default.Settings.Icons.StolenItemsSellingLimitIcon),
            }
        },
    }
end

--- Creates settings menu for fence data provider.
function FenceDataProviderSettingsMenu.createMenu(addon)
    FenceDataProviderSettingsMenu.Panel = LibAddonMenu:RegisterAddonPanel("FenceDataProvider_Panel", settingsPanelInformation)
    local optionsData = FenceDataProviderSettingsMenu.createOptionsData(addon)
    LibAddonMenu:RegisterOptionControls("FenceDataProvider_Panel", optionsData)
end
