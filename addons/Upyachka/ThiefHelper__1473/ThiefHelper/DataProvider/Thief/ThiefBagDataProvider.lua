-- Used to calculate and provide thief (fence - stolen items buyer) information.
ThiefBagDataProvider = Up_DataProvider:new {
    StolenItemsNumber = 0, -- Total number of stolen items.
    StolenItemsCost = 0, -- Total cost of stolen items.
    -- name of addon required by Up_AddonConfigurator.
    name = "ThiefBagDataProvider",
    -- version of addon required by Up_SettingsController.
    version = 1,
    -- Any default data placed here.
    Default = {
        -- default settings for addon. Required by Up_SettingsController.
        Settings = {
            Icons = {
                StolenItemsNumberInBagIndicator = {
                    Enabled = true,
                    TexturePath = "esoui\\art\\inventory\\inventory_stolenitem_icon.dds",
                    Size = 20
                },
                StolenItemsCostInBagIndicator = {
                    Enabled = true,
                    TexturePath = "esoui\\art\\currency\\currency_gold_32.dds",
                    Size = 20
                },
            }
        }
    },

}

local this = ThiefBagDataProvider
local SettingsController = LibStub:GetLibrary("Up_SettingsController")

-- Calculate number of stolen items in inventory.
function this:countStolenItems()
    local bagCache = SHARED_INVENTORY:GenerateFullSlotData(nil, BAG_BACKPACK)
    self.StolenItemsNumber = 0
    self.StolenItemsCost = 0
    for key, data in pairs(bagCache) do
        if (data.stolen) then
            self.StolenItemsNumber = self.StolenItemsNumber + data.stackCount
            self.StolenItemsCost = self.StolenItemsCost + data.stackSellPrice
        end
    end

end

-- Overriden method Up_DataProvider:initialize().
function this:initialize()
    self:countStolenItems()
    local function handleItemSlotUpdate(bagId, slotId, isNewItem, itemSoundCategory, inventoryUpdateReason, stackCountChange)
        -- TODO is there are any other solutions with better perfomance?
        self:countStolenItems()
    end
    EVENT_MANAGER:RegisterForEvent(this.name .. "_slotUpdateHandler", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, handleItemSlotUpdate)
    self:onLoaded()
end

-- Adds counter info to string buffer if it greater than 0.
-- TODO Avoid copy-paste with FenceDataProvider
local function addCounterText(buffer, counter, indicatorSettings)
    if indicatorSettings.Enabled then
        local textureString = zo_iconFormat(indicatorSettings.TexturePath, indicatorSettings.Size, indicatorSettings.Size)
        return string.format("%s %s %d", buffer, textureString, counter)
    else
        return buffer
    end
end

-- Overriden method Up_DataProvider:getText(addon).
function this:getText(addon)
    local iconsSettings = self.Settings.Icons
    local buffer = ""
    buffer = addCounterText(buffer, self.StolenItemsNumber, iconsSettings.StolenItemsNumberInBagIndicator)
    buffer = addCounterText(buffer, self.StolenItemsCost, iconsSettings.StolenItemsCostInBagIndicator)
    if buffer ~= "" then
        return buffer
    else
        return nil
    end
end

-- function callback to initialize addon on first loading. Required by Up_AddonConfigurator
function this:onLoaded(event)
    SettingsController.loadSettings(self)
    ThiefBagDataProviderSettingsMenu.createMenu(self)
end
