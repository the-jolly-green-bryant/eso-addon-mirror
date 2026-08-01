-- Used to provide cooldown time for teleport.
ItemDataProvider = {
    -- name of addon required by Up_AddonConfigurator.
    name = "ItemDataProvider",
    -- version of addon required by Up_SettingsController.
    version = 1,
    -- Any default data placed here.
    Default = {
        -- default settings for addon. Required by Up_SettingsController.
        Settings = {
            Icons = {
                BagpackIcon = {
                    TexturePath = "\\esoui\\art\\tooltips\\icon_bag.dds",
                    Size = 20
                },
                BankIcon = {
                    TexturePath = "\\esoui\\art\\tooltips\\icon_bank.dds",
                    Size = 20
                },
                CraftBagIcon = {
                    TexturePath = "\\esoui\\art\\tooltips\\icon_craft_bag.dds",
                    Size = 20
                },
                ItemIcon = {
                    Size = 32
                },
            }
        }
    },
}

local SettingsController = LibStub:GetLibrary("Up_SettingsController")

-- Creates instance data provider.
function ItemDataProvider:new(itemLink)
    local icon, _, _, _, _ = GetItemLinkInfo(itemLink)
    local instance = ZO_Object.MultiSubclass({
        itemLink = itemLink,
        iconTexturePath = icon,
        stackCountBackpack = 0,
        stackCountBank = 0,
        stackCountCraftBag = 0,
    }, self)
    instance:initialize()
    return instance
end

-- Calculate number of stolen items in inventory.
function ItemDataProvider:countItems()
    local stackCountBackpack, stackCountBank, stackCountCraftBag = GetItemLinkStacks(self.itemLink)
    --d("Counters: " .. stackCountBackpack .. " " .. stackCountBank .. " " .. stackCountCraftBag)
    self.stackCountBackpack = stackCountBackpack
    self.stackCountBank = stackCountBank
    self.stackCountCraftBag = stackCountCraftBag
end

-- Overriden method Up_DataProvider:initialize().
function ItemDataProvider:initialize()
    self:onLoaded()

    self:countItems()
    --d(self.itemLink .. " : " .. "Counters: " .. self.stackCountBackpack .. " " .. self.stackCountBank .. " " .. self.stackCountCraftBag)
    local provider = self
    local function handleItemSlotUpdate(event)
        --d(self.itemLink .. " : " .. event)
        provider:countItems()
        --d(self.itemLink .. " : " .. "Calc: " .. provider.stackCountBackpack .. " " .. provider.stackCountBank .. " " .. provider.stackCountCraftBag)
    end

    local key = "ItemDataProvider_slotUpdateHandler_" .. self.itemLink
    EVENT_MANAGER:RegisterForEvent(key, EVENT_ITEM_SLOT_CHANGED, handleItemSlotUpdate)
    EVENT_MANAGER:RegisterForEvent(key, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, handleItemSlotUpdate)
    EVENT_MANAGER:RegisterForEvent(key, EVENT_INVENTORY_ITEMS_AUTO_TRANSFERRED_TO_CRAFT_BAG, handleItemSlotUpdate)
end

-- Adds counter info to string buffer if it greater than 0.
local function addCounterIfNecessary(buffer, counter, iconPath, iconSize)
    if counter > 0 then
        local textureString = zo_iconFormat(iconPath, iconSize, iconSize)
        buffer = string.format("%s %s%d", buffer, textureString, counter)
    end
    return buffer
end

-- Overriden method Up_DataProvider:getText(addon).
function ItemDataProvider:getText(addon)
    local iconsSettings = self.Settings.Icons
    local itemIconPath = self.iconTexturePath
    local itemIconSize = iconsSettings.ItemIcon.Size
    local itemTextureString = zo_iconFormat(itemIconPath, itemIconSize, itemIconSize)

    local buffer = itemTextureString
    --d("Display counters: " .. self.stackCountBackpack .. " " .. self.stackCountBank .. " " .. self.stackCountCraftBag)
    buffer = addCounterIfNecessary(buffer, self.stackCountBackpack, iconsSettings.BagpackIcon.TexturePath, iconsSettings.BagpackIcon.Size)
    buffer = addCounterIfNecessary(buffer, self.stackCountBank, iconsSettings.BankIcon.TexturePath, iconsSettings.BankIcon.Size)
    buffer = addCounterIfNecessary(buffer, self.stackCountCraftBag, iconsSettings.CraftBagIcon.TexturePath, iconsSettings.CraftBagIcon.Size)

    return buffer
end

-- function callback to initialize addon on first loading. Required by Up_AddonConfigurator
function ItemDataProvider:onLoaded(event)
    SettingsController.loadSettings(self)
    -- TODO settings
end

--- Stops all activities of this provider.
function ItemDataProvider:stop()
    local key = "ItemDataProvider_slotUpdateHandler_" .. self.itemLink
    EVENT_MANAGER:UnregisterForEvent(key, EVENT_ITEM_SLOT_CHANGED)
    EVENT_MANAGER:UnregisterForEvent(key, EVENT_INVENTORY_SINGLE_SLOT_UPDATE)
    EVENT_MANAGER:UnregisterForEvent(key, EVENT_INVENTORY_ITEMS_AUTO_TRANSFERRED_TO_CRAFT_BAG)
end
