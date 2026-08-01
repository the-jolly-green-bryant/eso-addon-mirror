if not GildedUI then return end

local Addon = GildedUI

function Addon:CreateResourcesOverlay()
    local wm = WINDOW_MANAGER
    self:CreateBagOverlay(wm)
    self:CreateBankOverlay(wm)
    self:CreateCurrencyOverlays()
end

function Addon:ApplyResourcesFont()
    local sv = self.state.sv
    if not sv then return end

    self:ApplyReadoutFont(self.state.bagLabel, sv.bagFontSize)
    self:ApplyReadoutFont(self.state.bankLabel, sv.bankFontSize)
    self:ApplyBagIcon()
    self:ApplyBankIcon()
    self:ApplyAllCurrencyFonts()
end

function Addon:ApplyResourcesBackground()
    local sv = self.state.sv
    if not sv then return end

    self:ApplyBagIcon()
    self:ApplyBankIcon()
    self:ApplyAllCurrencyBackgrounds()
end

function Addon:ApplyResourcesDefaults()
    self:ApplyBagPosition()
    self:ApplyBankPosition()
    self:ApplyAllCurrencyPositions()
    self:ApplyResourcesFont()
    self:ApplyResourcesBackground()
    self:ApplyAllCurrencyColors()
end

function Addon:UpdateResources()
    self:UpdateBagSpace()
    self:UpdateBankSpace()
    self:UpdateCurrencies()
end

function Addon:RegisterResourceEvents()
    local eventName = self.name .. "_Resources"
    local function OnResourceEvent()
        self:UpdateResources()
    end

    EVENT_MANAGER:RegisterForEvent(eventName, EVENT_MONEY_UPDATE, OnResourceEvent)
    EVENT_MANAGER:RegisterForEvent(eventName, EVENT_ALLIANCE_POINT_UPDATE, OnResourceEvent)
    EVENT_MANAGER:RegisterForEvent(eventName, EVENT_TELVAR_STONE_UPDATE, OnResourceEvent)
    if EVENT_CURRENCY_UPDATE then
        EVENT_MANAGER:RegisterForEvent(eventName, EVENT_CURRENCY_UPDATE, OnResourceEvent)
    end
    EVENT_MANAGER:RegisterForEvent(eventName, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, OnResourceEvent)
    EVENT_MANAGER:RegisterForEvent(eventName, EVENT_INVENTORY_ITEM_DESTROYED, OnResourceEvent)
    EVENT_MANAGER:RegisterForEvent(eventName, EVENT_INVENTORY_ITEM_USED, OnResourceEvent)
    EVENT_MANAGER:RegisterForEvent(eventName, EVENT_INVENTORY_BAG_CAPACITY_CHANGED, OnResourceEvent)
    EVENT_MANAGER:RegisterForEvent(eventName, EVENT_INVENTORY_BOUGHT_BAG_SPACE, OnResourceEvent)
    EVENT_MANAGER:RegisterForEvent(eventName, EVENT_INVENTORY_BANK_CAPACITY_CHANGED, OnResourceEvent)
    EVENT_MANAGER:RegisterForEvent(eventName, EVENT_INVENTORY_BOUGHT_BANK_SPACE, OnResourceEvent)
    EVENT_MANAGER:RegisterForEvent(eventName, EVENT_CLOSE_BANK, OnResourceEvent)
    EVENT_MANAGER:RegisterForEvent(eventName, EVENT_CLOSE_GUILD_BANK, OnResourceEvent)
    EVENT_MANAGER:RegisterForEvent(eventName, EVENT_STABLE_INTERACT_END, OnResourceEvent)

    local function OnLocationChanged()
        self:UpdateVisibility()
    end
    EVENT_MANAGER:RegisterForEvent(eventName, EVENT_ZONE_CHANGED, OnLocationChanged)
    EVENT_MANAGER:RegisterForEvent(eventName, EVENT_PLAYER_ACTIVATED, OnLocationChanged)
    if EVENT_BATTLEGROUND_STATE_CHANGED then
        EVENT_MANAGER:RegisterForEvent(eventName, EVENT_BATTLEGROUND_STATE_CHANGED, OnLocationChanged)
    end
end
