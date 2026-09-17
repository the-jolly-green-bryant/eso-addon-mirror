local Addon = LarvalTearMod
local FoodHelper = Addon.Modules.FoodHelper
local Log = Addon.Common.Log
local Util = Addon.Common.Util

local AUTO_EAT_UPDATE_NAME = "LTM_FoodHelper_AutoEatMonitor"
local AUTO_EAT_MONITOR_INTERVAL_MS = 5000
local FOOD_HELPER_AUTO_EAT_PVP_ZONE_IDS = {
    [181] = true, -- Cyrodiil
    [584] = true, -- Imperial City
    [643] = true, -- Imperial City
}

local function NormalizeCardId(cardId)
    if type(cardId) ~= "string" or cardId == "" then
        return nil
    end
    return cardId
end

local function NormalizeOptionalCardId(cardId)
    if type(cardId) ~= "string" or cardId == "" or cardId == "none" then
        return nil
    end
    return cardId
end

local function BuildFoodCardDisplayName(card, cardId)
    if type(card) ~= "table" then
        return NormalizeOptionalCardId(cardId) or "Food"
    end

    return Util:NormalizeDisplayName(card.name)
        or Util:NormalizeDisplayName(card.itemLink)
        or (card.itemId ~= nil and tostring(card.itemId) or nil)
        or NormalizeOptionalCardId(cardId)
        or "Food"
end

local function NormalizeCharacterKey(characterKey)
    if characterKey ~= nil then
        return tostring(characterKey)
    end

    if type(GetCurrentCharacterId) ~= "function" then
        return nil
    end

    local ok, characterId = pcall(GetCurrentCharacterId)
    if ok and characterId ~= nil then
        return tostring(characterId)
    end

    return nil
end

local function GetItemLinkItemIdSafe(itemLink)
    if type(itemLink) ~= "string" or itemLink == "" or type(GetItemLinkItemId) ~= "function" then
        return nil
    end

    local ok, itemId = pcall(GetItemLinkItemId, itemLink)
    if ok and type(itemId) == "number" and itemId > 0 then
        return itemId
    end

    return nil
end

local function IterateBackpackSlots(visitor)
    if type(visitor) ~= "function" then
        return
    end

    if type(ZO_IterateBagSlots) == "function" then
        for slotIndex in ZO_IterateBagSlots(BAG_BACKPACK) do
            visitor(slotIndex)
        end
        return
    end

    if type(GetBagSize) ~= "function" then
        return
    end

    local bagSize = GetBagSize(BAG_BACKPACK)
    if type(bagSize) ~= "number" then
        return
    end

    for slotIndex = 0, bagSize - 1 do
        visitor(slotIndex)
    end
end

local function IsFoodOrDrinkItemType(itemType)
    return itemType == ITEMTYPE_FOOD or itemType == ITEMTYPE_DRINK
end

local function GetCurrentZoneIdSafe()
    if type(GetUnitZoneIndex) ~= "function" or type(GetZoneId) ~= "function" then
        return nil
    end

    local ok, zoneIndex = pcall(GetUnitZoneIndex, "player")
    if not ok or type(zoneIndex) ~= "number" then
        return nil
    end

    local okZoneId, zoneId = pcall(GetZoneId, zoneIndex)
    if okZoneId and type(zoneId) == "number" then
        return zoneId
    end

    return nil
end

local function IsAutoEatAllowedArea()
    local inDungeonOrTrial = type(IsUnitInDungeon) == "function" and IsUnitInDungeon("player") == true
    local zoneId = GetCurrentZoneIdSafe()
    local inPvP = zoneId ~= nil and FOOD_HELPER_AUTO_EAT_PVP_ZONE_IDS[zoneId] == true
    return inDungeonOrTrial or inPvP
end

local function RemoveFirstValue(values, targetValue)
    if type(values) ~= "table" then
        return false
    end

    for index, value in ipairs(values) do
        if value == targetValue then
            table.remove(values, index)
            return true
        end
    end

    return false
end

function FoodHelper:Initialize(savedVars)
    self.savedVars = savedVars
    if self:GetAutoEatEnabled() then
        self:StartAutoEatMonitor(false)
    end
end

function FoodHelper:EnsureSavedVarsShape(readOnly)
    if type(self.savedVars) ~= "table" then
        return nil
    end

    if type(self.savedVars.foodHelperByCharacter) ~= "table" then
        if readOnly then
            return nil
        end
        self.savedVars.foodHelperByCharacter = {}
    end

    return self.savedVars
end

function FoodHelper:BuildDefaultCharacterBucket(characterKey)
    return {
        autoEatEnabled = false,
        activeCardId = nil,
        cardOrder = {},
        cards = {},
        nextIndex = 1,
        ownerCharacterId = characterKey,
    }
end

function FoodHelper:GetCharacterBucketReadonly()
    local savedVars = self:EnsureSavedVarsShape(true)
    if type(savedVars) ~= "table" or type(savedVars.foodHelperByCharacter) ~= "table" then
        return nil
    end

    local characterKey = NormalizeCharacterKey()
    if type(characterKey) ~= "string" or characterKey == "" then
        return nil
    end

    local foodHelper = savedVars.foodHelperByCharacter[characterKey]
    if type(foodHelper) ~= "table" then
        return nil
    end

    foodHelper = Util:DeepCopy(foodHelper)
    return self:NormalizeCharacterBucket(foodHelper, characterKey)
end

function FoodHelper:EnsureCharacterBucketForWrite()
    local savedVars = self:EnsureSavedVarsShape(false)
    if type(savedVars) ~= "table" then
        return nil
    end

    local characterKey = NormalizeCharacterKey()
    if type(characterKey) ~= "string" or characterKey == "" then
        return nil
    end

    local foodHelper = savedVars.foodHelperByCharacter[characterKey]
    if type(foodHelper) ~= "table" then
        foodHelper = self:BuildDefaultCharacterBucket(characterKey)
        savedVars.foodHelperByCharacter[characterKey] = foodHelper
    end

    return self:NormalizeCharacterBucket(foodHelper, characterKey)
end

function FoodHelper:NormalizeCharacterBucket(foodHelper, characterKey)
    if type(foodHelper) ~= "table" then
        return nil
    end

    if type(foodHelper.cards) ~= "table" then
        foodHelper.cards = {}
    end
    if type(foodHelper.cardOrder) ~= "table" then
        foodHelper.cardOrder = {}
        for cardId, card in pairs(foodHelper.cards) do
            if type(cardId) == "string" and type(card) == "table" then
                foodHelper.cardOrder[#foodHelper.cardOrder + 1] = cardId
            end
        end
        table.sort(foodHelper.cardOrder)
    end
    foodHelper.nextIndex = math.max(tonumber(foodHelper.nextIndex) or 1, 1)
    foodHelper.autoEatEnabled = foodHelper.autoEatEnabled == true
    foodHelper.activeCardId = NormalizeCardId(foodHelper.activeCardId)
    foodHelper.ownerCharacterId = foodHelper.ownerCharacterId or characterKey
    foodHelper.ownerCharacterName = nil

    if foodHelper.activeCardId ~= nil and type(foodHelper.cards[foodHelper.activeCardId]) ~= "table" then
        foodHelper.activeCardId = nil
    end

    return foodHelper
end

function FoodHelper:GetAutoEatEnabled()
    local foodHelper = self:GetCharacterBucketReadonly()
    return type(foodHelper) == "table" and foodHelper.autoEatEnabled == true
end

function FoodHelper:SetAutoEatEnabled(enabled)
    local foodHelper = self:EnsureCharacterBucketForWrite()
    if type(foodHelper) ~= "table" then
        return false
    end

    local isEnabled = enabled == true
    foodHelper.autoEatEnabled = isEnabled

    if isEnabled then
        self:StartAutoEatMonitor(true)
    else
        self:StopAutoEatMonitor()
    end
    return true
end

function FoodHelper:SetActiveCard(cardId)
    cardId = NormalizeCardId(cardId)
    local existingFoodHelper = self:GetCharacterBucketReadonly()
    if type(existingFoodHelper) ~= "table"
        or cardId == nil
        or type(existingFoodHelper.cards[cardId]) ~= "table" then
        return nil, "food_card_not_found"
    end

    local foodHelper = self:EnsureCharacterBucketForWrite()
    if type(foodHelper) ~= "table" or type(foodHelper.cards[cardId]) ~= "table" then
        return nil, "food_card_not_found"
    end

    foodHelper.activeCardId = cardId
    return Util:DeepCopy(foodHelper.cards[cardId])
end

function FoodHelper:DeleteCard(cardId)
    cardId = NormalizeCardId(cardId)
    local existingFoodHelper = self:GetCharacterBucketReadonly()
    if type(existingFoodHelper) ~= "table"
        or cardId == nil
        or type(existingFoodHelper.cards[cardId]) ~= "table" then
        return false, "food_card_not_found"
    end

    local foodHelper = self:EnsureCharacterBucketForWrite()
    if type(foodHelper) ~= "table" or type(foodHelper.cards[cardId]) ~= "table" then
        return false, "food_card_not_found"
    end

    foodHelper.cards[cardId] = nil
    RemoveFirstValue(foodHelper.cardOrder, cardId)
    if foodHelper.activeCardId == cardId then
        foodHelper.activeCardId = nil
    end

    return true
end

function FoodHelper:GenerateCardId()
    local foodHelper = self:EnsureCharacterBucketForWrite()
    if type(foodHelper) ~= "table" then
        return nil
    end

    while true do
        local nextIndex = math.max(tonumber(foodHelper.nextIndex) or 1, 1)
        local cardId = string.format("food_%04d", nextIndex)
        foodHelper.nextIndex = nextIndex + 1
        if type(foodHelper.cards[cardId]) ~= "table" then
            return cardId
        end
    end
end

function FoodHelper:BuildItemStateFromBagSlot(bagId, slotIndex)
    if type(bagId) ~= "number" or type(slotIndex) ~= "number" then
        return nil, "food_invalid_slot"
    end
    if type(GetItemType) ~= "function" or not IsFoodOrDrinkItemType(GetItemType(bagId, slotIndex)) then
        return nil, "food_invalid_item"
    end
    if type(GetItemLink) ~= "function" then
        return nil, "food_item_api_unavailable"
    end

    local itemLink = GetItemLink(bagId, slotIndex, LINK_STYLE_DEFAULT)
    local itemId = type(GetItemId) == "function" and GetItemId(bagId, slotIndex) or nil
    if type(itemId) ~= "number" or itemId <= 0 then
        itemId = GetItemLinkItemIdSafe(itemLink)
    end
    if type(itemId) ~= "number" or itemId <= 0 then
        return nil, "food_invalid_item"
    end

    local icon = type(GetItemLinkIcon) == "function" and GetItemLinkIcon(itemLink) or nil
    local name = type(GetItemLinkName) == "function" and GetItemLinkName(itemLink) or nil
    local stackCount = type(GetSlotStackSize) == "function" and GetSlotStackSize(bagId, slotIndex) or nil

    return {
        itemId = itemId,
        itemLink = itemLink,
        name = type(name) == "string" and name ~= "" and name or itemLink,
        icon = icon,
        stackCount = tonumber(stackCount) or 0,
    }
end

function FoodHelper:UpsertCardFromItemState(itemState, cardId)
    if type(itemState) ~= "table" or type(itemState.itemId) ~= "number" then
        return nil, "food_invalid_item"
    end

    local foodHelper = self:EnsureCharacterBucketForWrite()
    if type(foodHelper) ~= "table" then
        return nil, "food_savedvars_unavailable"
    end

    cardId = NormalizeCardId(cardId)
    local isNew = false
    if cardId == nil then
        cardId = self:GenerateCardId()
        isNew = true
    elseif type(foodHelper.cards[cardId]) ~= "table" then
        isNew = true
    end

    local now = Util:GetTimestamp()
    local card = {
        id = cardId,
        itemId = itemState.itemId,
        itemLink = itemState.itemLink,
        name = itemState.name,
        icon = itemState.icon,
        createdAt = isNew and now or (foodHelper.cards[cardId] and foodHelper.cards[cardId].createdAt or now),
        updatedAt = now,
    }

    foodHelper.cards[cardId] = card
    if isNew then
        foodHelper.cardOrder[#foodHelper.cardOrder + 1] = cardId
    end
    if foodHelper.activeCardId == nil then
        foodHelper.activeCardId = cardId
    end

    return Util:DeepCopy(card)
end

function FoodHelper:CreateOrReplaceFromBagSlot(bagId, slotIndex, cardId)
    local itemState, err = self:BuildItemStateFromBagSlot(bagId, slotIndex)
    if type(itemState) ~= "table" then
        return nil, err
    end

    return self:UpsertCardFromItemState(itemState, cardId)
end

function FoodHelper:GetBackpackCount(itemId)
    itemId = tonumber(itemId)
    if itemId == nil then
        return 0
    end

    local count = 0
    IterateBackpackSlots(function(slotIndex)
        local currentItemId = type(GetItemId) == "function" and GetItemId(BAG_BACKPACK, slotIndex) or nil
        if type(currentItemId) ~= "number" or currentItemId <= 0 then
            local itemLink = type(GetItemLink) == "function" and GetItemLink(BAG_BACKPACK, slotIndex, LINK_STYLE_DEFAULT) or nil
            currentItemId = GetItemLinkItemIdSafe(itemLink)
        end
        if currentItemId == itemId then
            local stackCount = type(GetSlotStackSize) == "function" and GetSlotStackSize(BAG_BACKPACK, slotIndex) or nil
            count = count + (tonumber(stackCount) or 0)
        end
    end)

    return count
end

function FoodHelper:GetActiveAutoEatContext()
    local foodHelper = self:GetCharacterBucketReadonly()
    if type(foodHelper) ~= "table" or foodHelper.activeCardId == nil then
        return nil
    end

    local itemId = tonumber(foodHelper.cards[foodHelper.activeCardId].itemId)
    if itemId == nil or itemId <= 0 then
        return nil
    end

    return {
        cardId = foodHelper.activeCardId,
        itemId = itemId,
    }
end

function FoodHelper:FindBackpackSlotForItemId(itemId)
    itemId = tonumber(itemId)
    if itemId == nil then
        return nil
    end

    local found = nil
    IterateBackpackSlots(function(slotIndex)
        if found ~= nil then
            return
        end

        local currentItemId = type(GetItemId) == "function" and GetItemId(BAG_BACKPACK, slotIndex) or nil
        if type(currentItemId) ~= "number" or currentItemId <= 0 then
            local itemLink = type(GetItemLink) == "function" and GetItemLink(BAG_BACKPACK, slotIndex, LINK_STYLE_DEFAULT) or nil
            currentItemId = GetItemLinkItemIdSafe(itemLink)
        end
        if currentItemId ~= itemId then
            return
        end

        found = {
            bagId = BAG_BACKPACK,
            slotIndex = slotIndex,
        }
    end)

    return found
end

local function ClearAutoEatUseLatch(foodHelper)
    foodHelper.autoEatUseLatch = nil
end

function FoodHelper:StartAutoEatMonitor(runImmediately)
    if self.autoEatMonitorRegistered then
        return
    end

    self.autoEatMonitorRegistered = true
    EVENT_MANAGER:RegisterForUpdate(AUTO_EAT_UPDATE_NAME, AUTO_EAT_MONITOR_INTERVAL_MS, function()
        FoodHelper:CheckAutoEat()
    end)
    if runImmediately == true then
        self:CheckAutoEat()
    end
end

function FoodHelper:StopAutoEatMonitor()
    if self.autoEatMonitorRegistered == true then
        EVENT_MANAGER:UnregisterForUpdate(AUTO_EAT_UPDATE_NAME)
        self.autoEatMonitorRegistered = false
    end
    ClearAutoEatUseLatch(self)
end

local function CheckAutoEatUseLatch(foodHelper, context)
    local latch = foodHelper.autoEatUseLatch
    if type(latch) ~= "table" then
        return false
    end
    if latch.consumed == true then
        return true
    end

    local currentCount = foodHelper:GetBackpackCount(context.itemId)
    if currentCount < latch.backpackCountBeforeUse then
        latch.consumed = true
        Log.Debug(
            "[FoodHelper][AutoEat]",
            "useLatch",
            "consumed=true",
            "cardId=" .. tostring(context.cardId),
            "itemId=" .. tostring(context.itemId)
        )
        return true
    end

    ClearAutoEatUseLatch(foodHelper)
    return false
end

function FoodHelper:CheckAutoEat()
    local context = self:GetActiveAutoEatContext()
    if type(context) ~= "table" then
        ClearAutoEatUseLatch(self)
        return false
    end

    local latch = self.autoEatUseLatch
    if type(latch) == "table" and (latch.cardId ~= context.cardId or latch.itemId ~= context.itemId) then
        ClearAutoEatUseLatch(self)
    end

    if LibFoodDrinkBuff:IsFoodBuffActive("player") then
        ClearAutoEatUseLatch(self)
        return false
    end
    if not IsAutoEatAllowedArea() then
        return false
    end
    if IsUnitDead("player") == true then
        return false
    end
    if IsUnitInCombat("player") == true then
        return false
    end
    if CheckAutoEatUseLatch(self, context) then
        return false
    end

    local slot = self:FindBackpackSlotForItemId(context.itemId)
    if type(slot) ~= "table" then
        return false
    end

    local remainingMs = GetItemCooldownInfo(slot.bagId, slot.slotIndex)
    remainingMs = tonumber(remainingMs) or 0
    if remainingMs > 0 then
        return false
    end

    self.autoEatUseLatch = {
        cardId = context.cardId,
        itemId = context.itemId,
        backpackCountBeforeUse = self:GetBackpackCount(context.itemId),
    }
    local ok, result = pcall(CallSecureProtected, "UseItem", slot.bagId, slot.slotIndex)
    if ok and result ~= false then
        return true
    end

    ClearAutoEatUseLatch(self)
    return false
end

function FoodHelper:GetCardList()
    local foodHelper = self:GetCharacterBucketReadonly()
    local cards = {}
    if type(foodHelper) ~= "table" or type(foodHelper.cards) ~= "table" then
        return cards
    end

    for _, cardId in ipairs(foodHelper.cardOrder or {}) do
        local card = foodHelper.cards[cardId]
        if type(card) == "table" then
            local copy = Util:DeepCopy(card)
            copy.backpackCount = self:GetBackpackCount(copy.itemId)
            copy.isActive = foodHelper.activeCardId == cardId
            cards[#cards + 1] = copy
        end
    end

    return cards
end

function FoodHelper:GetCardLinkOptions()
    local foodHelper = self:GetCharacterBucketReadonly()
    local options = {}
    if type(foodHelper) ~= "table" or type(foodHelper.cards) ~= "table" then
        return options
    end

    for _, cardId in ipairs(foodHelper.cardOrder or {}) do
        local card = foodHelper.cards[cardId]
        if type(cardId) == "string" and cardId ~= "" and type(card) == "table" then
            options[#options + 1] = {
                id = cardId,
                displayName = BuildFoodCardDisplayName(card, cardId),
            }
        end
    end

    return options
end

function FoodHelper:GetCardDisplayNameById(cardId)
    cardId = NormalizeOptionalCardId(cardId)
    if cardId == nil then
        return nil
    end

    local foodHelper = self:GetCharacterBucketReadonly()
    local card = type(foodHelper) == "table" and type(foodHelper.cards) == "table" and foodHelper.cards[cardId] or nil
    if type(card) ~= "table" then
        return nil
    end

    return BuildFoodCardDisplayName(card, cardId)
end

function FoodHelper:HasCard(cardId)
    cardId = NormalizeOptionalCardId(cardId)
    if cardId == nil then
        return false
    end

    local foodHelper = self:GetCharacterBucketReadonly()
    return type(foodHelper) == "table"
        and type(foodHelper.cards) == "table"
        and type(foodHelper.cards[cardId]) == "table"
end
