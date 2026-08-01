-- Used to calculate and provide thief (fence - stolen items buyer) information.
FenceDataProvider = Up_DataProvider:new {
    StolenItemsCount = 0, -- Count of stolen items.
    -- name of addon required by Up_AddonConfigurator.
    name = "FenceDataProvider",
    -- version of addon required by Up_SettingsController.
    version = 2,
    -- Any default data placed here.
    Default = {
        -- default settings for addon. Required by Up_SettingsController.
        Settings = {
            Icons = {
                SoldStolenItemsNumberIndicator = {
                    Enabled = true,
                    TexturePath = "esoui\\art\\tutorial\\guildstore_sell_tabicon_up.dds",
                    Size = 24
                },
                StolenItemsSellingLimitIndicator = {
                    Enabled = true,
                    TexturePath = "esoui\\art\\icons\\mapkey\\mapkey_fence.dds",
                    Size = 24
                },
            }
        }
    },
}

local this = FenceDataProvider
local SettingsController = LibStub:GetLibrary("Up_SettingsController")

-- Overriden method Up_DataProvider:initialize().
function this:initialize()
    self:onLoaded()
end

-- Adds counter info to string buffer if it greater than 0.
-- TODO Avoid copy-paste with ThiefBagDataProvider
local function addCounterText(buffer, counter, indicatorSettings)
    if indicatorSettings.Enabled then
        local textureString = zo_iconFormat(indicatorSettings.TexturePath, indicatorSettings.Size, indicatorSettings.Size)
        return string.format("%s %s%d", buffer, textureString, counter)
    else
        return buffer
    end
end

-- Overriden method Up_DataProvider:getText(addon).
function this:getText(addon)
    -- TODO cache this values to avoid unnecessary recalculations?
    local limit, sold, _ = GetFenceSellTransactionInfo()
    local iconsSettings = self.Settings.Icons
    local buffer = ""
    buffer = addCounterText(buffer, sold, iconsSettings.SoldStolenItemsNumberIndicator)
    buffer = addCounterText(buffer, limit, iconsSettings.StolenItemsSellingLimitIndicator)
    if buffer ~= "" then
        return buffer
    else
        return nil
    end
end

-- function callback to initialize addon on first loading. Required by Up_AddonConfigurator
function this:onLoaded(event)
    SettingsController.loadSettings(self)
    FenceDataProviderSettingsMenu.createMenu(self)
end
