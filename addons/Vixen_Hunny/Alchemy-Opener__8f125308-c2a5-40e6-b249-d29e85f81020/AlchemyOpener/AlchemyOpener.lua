
-- AlchemyOpener.lua
-- Author: Awh_Lina
AlchemyOpener = {}
AlchemyOpener.name = "AlchemyOpener"
AlchemyOpener.version = "1.1"
AlchemyOpener.isLoaded = false
AlchemyOpener.defaults_db = {
    enabled = true,
    selectedItemKey = "waxed_apothecary",
    customItemName = "",
}

local DEFAULT_ITEM_KEY = "waxed_apothecary"
local OPEN_DELAY_MS = 250
local LOOT_DELAY_MS = 500
local NEXT_OPEN_DELAY_MS = 700
local DEFAULT_PURCHASE_QUANTITY = 99
local POTION_PURCHASE_QUANTITY = 100

AlchemyOpener.itemOptions = {
    waxed_apothecary = {
        label = "Waxed Apothecary's Parcel",
        itemName = "Waxed Apothecary's Parcel",
    },
    custom = {
        label = "Custom item name",
        itemName = nil,
    },
}

local function TrimString(value)
    return tostring(value or ""):match("^%s*(.-)%s*$")
end

local function NormalizeItemName(value)
    return zo_strlower(TrimString(value))
end

local function IsPotionLikeItemName(value)
    local normalizedName = NormalizeItemName(value)
    return normalizedName:find("draught$") ~= nil or normalizedName:find("potion$") ~= nil
end

function AlchemyOpener:DoesItemMatchTargetName(itemName, targetItemName)
    local normalizedItemName = NormalizeItemName(itemName)
    local normalizedTargetItemName = NormalizeItemName(targetItemName)

    if normalizedTargetItemName == "" then
        return false
    end

    if self:GetConfiguredItemKey() == "custom" then
        return normalizedItemName:find(normalizedTargetItemName, 1, true) ~= nil
    end

    return normalizedItemName == normalizedTargetItemName
end

local function UseInventoryItem(bagId, slotIndex)
    CallSecureProtected("UseItem", bagId, slotIndex)
end

local function CanOpenInventoryItem(bagId, slotIndex)
    if IsItemUsable then
        return IsItemUsable(bagId, slotIndex)
    end

    return true
end

function AlchemyOpener:ShouldSkipCustomItemUse(itemName)
    if self:GetConfiguredItemKey() ~= "custom" then
        return false
    end

    return IsPotionLikeItemName(itemName)
end

function AlchemyOpener:GetConfiguredItemKey()
    local itemKey = self.db and self.db.selectedItemKey or DEFAULT_ITEM_KEY
    if self.itemOptions[itemKey] then
        return itemKey
    end

    return DEFAULT_ITEM_KEY
end

function AlchemyOpener:GetTargetItemName()
    local itemKey = self:GetConfiguredItemKey()
    if itemKey == "custom" then
        local customItemName = TrimString(self.db and self.db.customItemName or "")
        if customItemName ~= "" then
            return customItemName
        end

        return self.itemOptions[DEFAULT_ITEM_KEY].itemName
    end

    return self.itemOptions[itemKey].itemName
end

function AlchemyOpener:GetFreeBackpackSlots()
    local size = GetBagUseableSize(BAG_BACKPACK)
    local usedSlots = GetNumBagUsedSlots(BAG_BACKPACK)

    if type(size) ~= "number" or type(usedSlots) ~= "number" then
        return nil
    end

    return math.max(0, size - usedSlots)
end

function AlchemyOpener:HasBackpackItem(itemName)
    local bagCache = SHARED_INVENTORY:GetOrCreateBagCache(BAG_BACKPACK)

    for _, data in pairs(bagCache) do
        local bagId = data.bagId
        local slotIndex = data.slotIndex
        local backpackItemLink = GetItemLink(bagId, slotIndex, LINK_STYLE_BRACKETS)
        local backpackItemName = GetItemLinkName(backpackItemLink)

        if self:DoesItemMatchTargetName(backpackItemName, itemName) then
            return true
        end
    end

    return false
end

function AlchemyOpener:GetTargetPurchaseQuantity(targetItemName)
    if IsPotionLikeItemName(targetItemName) and self:HasBackpackItem(targetItemName) then
        return POTION_PURCHASE_QUANTITY
    end

    local freeSlots = self:GetFreeBackpackSlots()
    if freeSlots == nil then
        return DEFAULT_PURCHASE_QUANTITY
    end

    return freeSlots
end

function AlchemyOpener:GetCurrencyAmountByType(currencyType)
    if not currencyType or currencyType == CURT_NONE then
        return 0
    end

    if currencyType == CURT_MONEY then
        return GetCurrentMoney()
    end

    local characterAmount = 0
    local accountAmount = 0

    if CURRENCY_LOCATION_CHARACTER then
        characterAmount = GetCurrencyAmount(currencyType, CURRENCY_LOCATION_CHARACTER) or 0
    end

    if CURRENCY_LOCATION_ACCOUNT then
        accountAmount = GetCurrencyAmount(currencyType, CURRENCY_LOCATION_ACCOUNT) or 0
    end

    return math.max(characterAmount, accountAmount)
end

function AlchemyOpener:GetAffordableQuantity(price, currencyType1, currencyQuantity1, currencyType2, currencyQuantity2)
    local maxQuantity = math.huge
    local hasCurrencyRequirement = false

    if currencyType1 and currencyType1 ~= CURT_NONE and currencyQuantity1 and currencyQuantity1 > 0 then
        local availableCurrency1 = self:GetCurrencyAmountByType(currencyType1)
        maxQuantity = math.min(maxQuantity, math.floor(availableCurrency1 / currencyQuantity1))
        hasCurrencyRequirement = true
    end

    if currencyType2 and currencyType2 ~= CURT_NONE and currencyQuantity2 and currencyQuantity2 > 0 then
        local availableCurrency2 = self:GetCurrencyAmountByType(currencyType2)
        maxQuantity = math.min(maxQuantity, math.floor(availableCurrency2 / currencyQuantity2))
        hasCurrencyRequirement = true
    end

    if not hasCurrencyRequirement then
        if price and price > 0 then
            maxQuantity = math.floor(GetCurrentMoney() / price)
        else
            maxQuantity = 0
        end
    end

    return math.max(0, maxQuantity)
end

function AlchemyOpener:FindTargetContainer()
    local targetItemName = self:GetTargetItemName()
    local bagCache = SHARED_INVENTORY:GetOrCreateBagCache(BAG_BACKPACK)

    for _, data in pairs(bagCache) do
        local bagId = data.bagId
        local slotIndex = data.slotIndex
        local itemLink = GetItemLink(bagId, slotIndex, LINK_STYLE_BRACKETS)
        local itemName = GetItemLinkName(itemLink)

        if self:DoesItemMatchTargetName(itemName, targetItemName) then
            return bagId, slotIndex, itemName
        end
    end

    return nil, nil, nil
end

function AlchemyOpener:TryOpenNextContainer()
    if not self.db.enabled then
        return
    end

    if self.isOpeningItem then
        return
    end

    local bagId, slotIndex, itemName = self:FindTargetContainer()
    if not bagId then
        return
    end

    if self:ShouldSkipCustomItemUse(itemName) then
        return
    end

    if not CanOpenInventoryItem(bagId, slotIndex) then
        return
    end

    self.isOpeningItem = true

    zo_callLater(function()
        UseInventoryItem(bagId, slotIndex)
    end, OPEN_DELAY_MS)

    zo_callLater(function()
        if LOOT_SHARED then
            LOOT_SHARED:LootAllItems()
        end
    end, LOOT_DELAY_MS)

    zo_callLater(function()
        self.isOpeningItem = false
        self:TryOpenNextContainer()
    end, NEXT_OPEN_DELAY_MS)
end

function AlchemyOpener:BuyConfiguredStoreItem()
    if not self.db.enabled then
        return
    end

    local targetItemName = self:GetTargetItemName()
    local targetQuantity = self:GetTargetPurchaseQuantity(targetItemName)
    if targetQuantity <= 0 then
        return
    end

    local numItems = GetNumStoreItems()
    for storeIndex = 1, numItems do
        local _, itemName, _, price, _, _, _, _, _, currencyType1, currencyQuantity1, currencyType2, currencyQuantity2 = GetStoreEntryInfo(storeIndex)

        if self:DoesItemMatchTargetName(itemName, targetItemName) then
            local affordableQuantity = self:GetAffordableQuantity(price, currencyType1, currencyQuantity1, currencyType2, currencyQuantity2)
            local maxQuantity = math.min(targetQuantity, affordableQuantity)

            if maxQuantity > 0 then
                BuyStoreItem(storeIndex, maxQuantity)
                zo_callLater(function()
                    self:TryOpenNextContainer()
                end, LOOT_DELAY_MS)
            end

            return
        end
    end
end

function AlchemyOpener:OnOpenStore()
    self:BuyConfiguredStoreItem()
end

function AlchemyOpener:OnLootUpdated()
    if LOOT_SHARED then
        LOOT_SHARED:LootAllItems()
    end

    self:TryOpenNextContainer()
end

function AlchemyOpener:Initialize()
    self.db = ZO_SavedVars:New("AlchemyOpenerSettings", 1, nil, self.defaults_db)
    self.isOpeningItem = false

    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_OPEN_STORE, function()
        self:OnOpenStore()
    end)

    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_LOOT_UPDATED, function()
        self:OnLootUpdated()
    end)

    self.isLoaded = true
    d("AlchemyOpener ready")
end

function AlchemyOpener.OnAddOnLoaded(_, addonName)
    if addonName ~= AlchemyOpener.name then
        return
    end

    EVENT_MANAGER:UnregisterForEvent(AlchemyOpener.name, EVENT_ADD_ON_LOADED)
    AlchemyOpener:Initialize()
end

EVENT_MANAGER:RegisterForEvent(AlchemyOpener.name, EVENT_ADD_ON_LOADED, AlchemyOpener.OnAddOnLoaded)
