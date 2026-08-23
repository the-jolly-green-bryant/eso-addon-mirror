local Addon = LarvalTearMod
local FoodHelper = Addon.Modules.FoodHelper
local Log = Addon.Common.Log
local Util = Addon.Common.Util

local AUTO_EAT_EFFECT_EVENT_NAME = "LTM_FoodHelper_AutoEatEffectChanged"
local AUTO_EAT_COMBAT_EVENT_NAME = "LTM_FoodHelper_CombatState"
local AUTO_EAT_PLAYER_ACTIVATED_EVENT_NAME = "LTM_FoodHelper_PlayerActivated"
local AUTO_EAT_PLAYER_ALIVE_EVENT_NAME = "LTM_FoodHelper_PlayerAlive"
local AUTO_EAT_ACTIVATED_CHECK_DELAY_MS = 2000
local AUTO_EAT_REVIVE_CHECK_DELAY_MS = 2000
local AUTO_EAT_REVIVE_MAX_CHECK_COUNT = 15
local AUTO_EAT_VERIFY_DELAY_MS = 1500
local AUTO_EAT_RETRY_DELAY_MS = 2000
local AUTO_EAT_MAX_RETRY_COUNT = 2
local FOOD_HELPER_AUTO_EAT_PVP_ZONE_IDS = {
    [181] = true, -- Cyrodiil
    [584] = true, -- Imperial City
    [643] = true, -- Imperial City
}

FoodHelper.FOOD_BUFF_BY_ITEM_ID = {
    [64711] = 68411,
    [64712] = 68416,
    [135109] = 68411,
    [135112] = 68416,
    [68233] = 61259,
    [68234] = 61259,
    [68235] = 61259,
    [68236] = 61260,
    [68237] = 61260,
    [68238] = 61260,
    [68239] = 61261,
    [68240] = 61261,
    [68241] = 61261,
    [68242] = 61257,
    [68243] = 61257,
    [68244] = 61257,
    [68245] = 61255,
    [68246] = 61255,
    [68247] = 61255,
    [68248] = 61294,
    [68249] = 61294,
    [68250] = 61294,
    [68251] = 61218,
    [68252] = 61218,
    [68253] = 61218,
    [68254] = 61218,
    [68255] = 61322,
    [68256] = 61322,
    [68257] = 61322,
    [68258] = 61325,
    [68259] = 61325,
    [68260] = 61325,
    [68261] = 61328,
    [68262] = 61328,
    [68263] = 61328,
    [68264] = 61335,
    [68265] = 61335,
    [68266] = 61335,
    [68267] = 61340,
    [68268] = 61340,
    [68269] = 61340,
    [68270] = 61345,
    [68271] = 61345,
    [68272] = 61345,
    [68273] = 61350,
    [68274] = 61350,
    [68275] = 61350,
    [68276] = 61350,
    [71056] = 72816,
    [71057] = 72819,
    [71058] = 72822,
    [71059] = 72824,
    [87685] = 84678,
    [87686] = 84681,
    [87687] = 84700,
    [87690] = 84704,
    [87691] = 84709,
    [87695] = 84720,
    [87696] = 84725,
    [87697] = 84731,
    [87699] = 84735,
    [94437] = 85484,
    [94438] = 85497,
    [101879] = 86559,
    [112425] = 86673,
    [112426] = 86677,
    [112433] = 86746,
    [112434] = 86749,
    [112435] = 84678,
    [112438] = 86787,
    [112439] = 86789,
    [112440] = 86791,
    [120436] = 84678,
    [120762] = 89955,
    [120763] = 89957,
    [120764] = 89971,
    [133554] = 100502,
    [133555] = 100488,
    [133556] = 100498,
    [139016] = 107748,
    [139018] = 107789,
    [153625] = 127531,
    [153627] = 127572,
    [153629] = 127596,
    [171322] = 148633,
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

local function IsAutoEatDebugEnabled()
    return Log.IsDebugEnabled() == true
end

local function DebugAutoEat(...)
    if IsAutoEatDebugEnabled() then
        Log.Debug("[FoodHelper][AutoEat]", ...)
    end
end

local function BuildAutoEatState(foodHelper)
    local enabled = type(foodHelper) == "table" and foodHelper.autoEatEnabled == true
    local activeCardId = type(foodHelper) == "table" and foodHelper.activeCardId or nil
    local card = type(foodHelper) == "table" and type(activeCardId) == "string" and foodHelper.cards[activeCardId] or nil
    local itemId = type(card) == "table" and tonumber(card.itemId) or nil
    local buffAbilityId = type(card) == "table" and tonumber(card.buffAbilityId) or nil

    return {
        enabled = enabled,
        activeCardId = activeCardId,
        card = card,
        itemId = itemId,
        buffAbilityId = buffAbilityId,
    }
end

local function IsAutoEatConfiguredState(state)
    return type(state) == "table"
        and state.enabled == true
        and type(state.activeCardId) == "string"
        and state.activeCardId ~= ""
        and type(state.card) == "table"
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

local function BuildFoodHelperAutoEatAreaProbe()
    local inDungeonOrTrial = type(IsUnitInDungeon) == "function" and IsUnitInDungeon("player") == true
    local isPlayerInRaid = type(IsPlayerInRaid) == "function" and IsPlayerInRaid() == true
    local zoneId = GetCurrentZoneIdSafe()
    local inPvP = zoneId ~= nil and FOOD_HELPER_AUTO_EAT_PVP_ZONE_IDS[zoneId] == true
    local allowed = inDungeonOrTrial or inPvP

    return {
        allowed = allowed,
        inDungeonOrTrial = inDungeonOrTrial,
        isPlayerInRaid = isPlayerInRaid,
        zoneId = zoneId,
        inPvP = inPvP,
    }
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
    self:RegisterAutoEatEvents()
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

    foodHelper.autoEatEnabled = enabled == true
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

function FoodHelper:GetBuffAbilityIdForItemId(itemId)
    itemId = tonumber(itemId)
    return itemId and self.FOOD_BUFF_BY_ITEM_ID[itemId] or nil
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
    local buffAbilityId = self:GetBuffAbilityIdForItemId(itemId)
    if buffAbilityId == nil then
        return nil, "food_unsupported_item"
    end

    local icon = type(GetItemLinkIcon) == "function" and GetItemLinkIcon(itemLink) or nil
    local name = type(GetItemLinkName) == "function" and GetItemLinkName(itemLink) or nil
    local stackCount = type(GetSlotStackSize) == "function" and GetSlotStackSize(bagId, slotIndex) or nil

    return {
        itemId = itemId,
        buffAbilityId = buffAbilityId,
        itemLink = itemLink,
        name = type(name) == "string" and name ~= "" and name or itemLink,
        icon = icon,
        stackCount = tonumber(stackCount) or 0,
    }
end

function FoodHelper:FindBackpackFoodByItemIds(itemIds)
    if type(itemIds) ~= "table" then
        return nil
    end

    local wanted = {}
    for _, itemId in ipairs(itemIds) do
        if type(itemId) == "number" then
            wanted[itemId] = true
        end
    end

    local foundState = nil
    IterateBackpackSlots(function(slotIndex)
        if foundState ~= nil then
            return
        end

        local state = self:BuildItemStateFromBagSlot(BAG_BACKPACK, slotIndex)
        if type(state) == "table" and wanted[state.itemId] == true then
            foundState = state
        end
    end)

    return foundState
end

function FoodHelper:GetCurrentFoodBuffAbilityId()
    if type(GetNumBuffs) ~= "function" or type(GetUnitBuffInfo) ~= "function" then
        return nil
    end

    for buffIndex = 1, GetNumBuffs("player") do
        local abilityId = select(11, GetUnitBuffInfo("player", buffIndex))
        if type(abilityId) == "number" and self:GetItemIdsForBuffAbilityId(abilityId) ~= nil then
            return abilityId
        end
    end

    return nil
end

function FoodHelper:HasFoodBuffAbilityId(buffAbilityId)
    buffAbilityId = tonumber(buffAbilityId)
    if buffAbilityId == nil or type(GetNumBuffs) ~= "function" or type(GetUnitBuffInfo) ~= "function" then
        return false
    end

    for buffIndex = 1, GetNumBuffs("player") do
        local abilityId = select(11, GetUnitBuffInfo("player", buffIndex))
        if abilityId == buffAbilityId then
            return true
        end
    end

    return false
end

function FoodHelper:GetItemIdsForBuffAbilityId(buffAbilityId)
    buffAbilityId = tonumber(buffAbilityId)
    if buffAbilityId == nil then
        return nil
    end

    local itemIds = {}
    for itemId, mappedBuffAbilityId in pairs(self.FOOD_BUFF_BY_ITEM_ID) do
        if mappedBuffAbilityId == buffAbilityId then
            itemIds[#itemIds + 1] = itemId
        end
    end
    table.sort(itemIds)

    return #itemIds > 0 and itemIds or nil
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
        buffAbilityId = itemState.buffAbilityId,
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

function FoodHelper:FindCardIdByItemId(itemId)
    local foodHelper = self:GetCharacterBucketReadonly()
    itemId = tonumber(itemId)
    if type(foodHelper) ~= "table" or itemId == nil then
        return nil
    end

    for _, cardId in ipairs(foodHelper.cardOrder or {}) do
        local card = foodHelper.cards[cardId]
        if type(card) == "table" and tonumber(card.itemId) == itemId then
            return cardId
        end
    end

    return nil
end

function FoodHelper:CreateOrReplaceFromBagSlot(bagId, slotIndex, cardId)
    local itemState, err = self:BuildItemStateFromBagSlot(bagId, slotIndex)
    if type(itemState) ~= "table" then
        return nil, err
    end

    return self:UpsertCardFromItemState(itemState, cardId)
end

function FoodHelper:RegisterCurrentActiveFood()
    local buffAbilityId = self:GetCurrentFoodBuffAbilityId()
    if buffAbilityId == nil then
        return nil, "food_no_active_buff"
    end

    local itemIds = self:GetItemIdsForBuffAbilityId(buffAbilityId)
    local itemState = self:FindBackpackFoodByItemIds(itemIds)
    if type(itemState) ~= "table" then
        return nil, "food_matching_item_not_found"
    end

    return self:UpsertCardFromItemState(itemState, self:FindCardIdByItemId(itemState.itemId))
end

function FoodHelper:GetBackpackCount(itemId)
    itemId = tonumber(itemId)
    if itemId == nil then
        return 0
    end

    local count = 0
    IterateBackpackSlots(function(slotIndex)
        local itemLink = type(GetItemLink) == "function" and GetItemLink(BAG_BACKPACK, slotIndex, LINK_STYLE_DEFAULT) or nil
        local currentItemId = GetItemLinkItemIdSafe(itemLink)
        if currentItemId == itemId then
            local stackCount = type(GetSlotStackSize) == "function" and GetSlotStackSize(BAG_BACKPACK, slotIndex) or nil
            count = count + (tonumber(stackCount) or 0)
        end
    end)

    return count
end

function FoodHelper:GetActiveAutoEatContext()
    local foodHelper = self:GetCharacterBucketReadonly()
    local state = BuildAutoEatState(foodHelper)
    local enabled = state.enabled
    local activeCardId = state.activeCardId
    local card = state.card
    local itemId = state.itemId
    local buffAbilityId = state.buffAbilityId

    if itemId ~= nil then
        local mappedBuffAbilityId = self:GetBuffAbilityIdForItemId(itemId)
        if mappedBuffAbilityId ~= nil then
            buffAbilityId = mappedBuffAbilityId
        end
    end

    if not enabled then
        return nil, "auto_eat_disabled"
    end
    if type(activeCardId) ~= "string" or activeCardId == "" then
        return nil, "food_no_active_card"
    end
    if type(card) ~= "table" then
        return nil, "food_card_not_found"
    end
    if itemId == nil then
        return nil, "food_invalid_item"
    end
    if buffAbilityId == nil then
        return nil, "food_unsupported_item"
    end
    local areaProbe = BuildFoodHelperAutoEatAreaProbe()
    if IsAutoEatDebugEnabled() then
        DebugAutoEat(
            "state",
            "enabled=" .. tostring(enabled),
            "activeCardId=" .. tostring(activeCardId),
            "itemId=" .. tostring(itemId),
            "buffAbilityId=" .. tostring(buffAbilityId),
            "areaAllowed=" .. tostring(areaProbe.allowed == true),
            "inDungeonOrTrial=" .. tostring(areaProbe.inDungeonOrTrial),
            "isPlayerInRaid=" .. tostring(areaProbe.isPlayerInRaid),
            "zoneId=" .. tostring(areaProbe.zoneId),
            "inPvP=" .. tostring(areaProbe.inPvP)
        )
    end
    if areaProbe.allowed ~= true then
        DebugAutoEat("areaGate", "allowed=false")
        return nil, "food_area_not_allowed"
    end
    if type(IsUnitDead) == "function" and IsUnitDead("player") == true then
        return nil, "player_dead"
    end

    return {
        cardId = activeCardId,
        itemId = itemId,
        buffAbilityId = buffAbilityId,
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

        local stackCount = type(GetSlotStackSize) == "function" and GetSlotStackSize(BAG_BACKPACK, slotIndex) or nil
        found = {
            bagId = BAG_BACKPACK,
            slotIndex = slotIndex,
            stackCount = tonumber(stackCount) or 0,
        }
    end)

    DebugAutoEat(
        "inventory",
        "itemId=" .. tostring(itemId),
        "found=" .. tostring(found ~= nil),
        "slotIndex=" .. tostring(found and found.slotIndex or nil),
        "stackCount=" .. tostring(found and found.stackCount or nil)
    )
    return found
end

function FoodHelper:QueueAutoEat(context, reason)
    if type(context) ~= "table" then
        return false
    end

    self.pendingAutoEatContext = {
        cardId = context.cardId,
        itemId = context.itemId,
        buffAbilityId = context.buffAbilityId,
        retryCount = tonumber(context.retryCount) or 0,
    }
    DebugAutoEat("combatDefer", "queued=true", "reason=" .. tostring(reason))
    return true
end

function FoodHelper:ScheduleAutoEatVerify(context, delayMs)
    if type(context) ~= "table" or type(zo_callLater) ~= "function" then
        return false
    end

    self.autoEatVerifyGeneration = (tonumber(self.autoEatVerifyGeneration) or 0) + 1
    local generation = self.autoEatVerifyGeneration
    local snapshot = {
        cardId = context.cardId,
        itemId = context.itemId,
        buffAbilityId = context.buffAbilityId,
        retryCount = tonumber(context.retryCount) or 0,
    }

    zo_callLater(function()
        if self.autoEatVerifyGeneration ~= generation then
            return
        end
        self:VerifyAutoEatResult(snapshot)
    end, tonumber(delayMs) or AUTO_EAT_VERIFY_DELAY_MS)
    return true
end

function FoodHelper:VerifyAutoEatResult(context)
    if type(context) ~= "table" then
        return false
    end

    local currentContext, err = self:GetActiveAutoEatContext()
    if type(currentContext) ~= "table" then
        DebugAutoEat("verify", "stopped=true", "reason=" .. tostring(err))
        return false
    end
    if currentContext.cardId ~= context.cardId
        or currentContext.itemId ~= context.itemId
        or currentContext.buffAbilityId ~= context.buffAbilityId then
        DebugAutoEat("verify", "stopped=true", "reason=active_card_changed")
        return false
    end

    local hasBuff = self:HasFoodBuffAbilityId(context.buffAbilityId)
    DebugAutoEat(
        "verify",
        "buffAbilityId=" .. tostring(context.buffAbilityId),
        "hasBuff=" .. tostring(hasBuff),
        "retryCount=" .. tostring(context.retryCount)
    )
    if hasBuff then
        return true
    end
    if (tonumber(context.retryCount) or 0) >= AUTO_EAT_MAX_RETRY_COUNT then
        return false
    end
    if self:FindBackpackSlotForItemId(context.itemId) == nil then
        DebugAutoEat("verify", "stopped=true", "reason=item_missing")
        return false
    end

    context.retryCount = (tonumber(context.retryCount) or 0) + 1
    return self:TryAutoEat(context, "verify_retry")
end

function FoodHelper:TryAutoEat(context, reason)
    local currentContext, err = self:GetActiveAutoEatContext()
    if type(currentContext) ~= "table" then
        DebugAutoEat("try", "skipped=true", "reason=" .. tostring(err))
        return false
    end

    if type(context) ~= "table" then
        context = currentContext
    elseif context.cardId ~= currentContext.cardId
        or context.itemId ~= currentContext.itemId
        or context.buffAbilityId ~= currentContext.buffAbilityId then
        DebugAutoEat("try", "skipped=true", "reason=active_card_changed")
        return false
    end

    if self:HasFoodBuffAbilityId(context.buffAbilityId) then
        return false
    end
    DebugAutoEat("currentBuff", "exists=false", "buffAbilityId=" .. tostring(context.buffAbilityId))

    if type(IsUnitInCombat) == "function" and IsUnitInCombat("player") == true then
        return self:QueueAutoEat(context, reason or "combat")
    end

    local slot = self:FindBackpackSlotForItemId(context.itemId)
    if type(slot) ~= "table" then
        return false
    end

    if type(GetItemCooldownInfo) == "function" then
        local remainingMs, durationMs = GetItemCooldownInfo(slot.bagId, slot.slotIndex)
        remainingMs = tonumber(remainingMs) or 0
        DebugAutoEat(
            "cooldown",
            "remainingMs=" .. tostring(remainingMs),
            "durationMs=" .. tostring(durationMs)
        )
        if remainingMs > 0 then
            context.retryCount = (tonumber(context.retryCount) or 0) + 1
            if context.retryCount <= AUTO_EAT_MAX_RETRY_COUNT then
                self:ScheduleAutoEatVerify(context, math.max(AUTO_EAT_RETRY_DELAY_MS, remainingMs))
            end
            return false
        end
    end

    if type(CallSecureProtected) ~= "function" then
        DebugAutoEat("useAttempt", "ok=false", "reason=CallSecureProtected_unavailable")
        return false
    end

    local ok, result = pcall(CallSecureProtected, "UseItem", slot.bagId, slot.slotIndex)
    DebugAutoEat(
        "useAttempt",
        "ok=" .. tostring(ok),
        "result=" .. tostring(result),
        "bagId=" .. tostring(slot.bagId),
        "slotIndex=" .. tostring(slot.slotIndex),
        "itemId=" .. tostring(context.itemId),
        "reason=" .. tostring(reason)
    )
    if ok and result ~= false then
        self:ScheduleAutoEatVerify(context, AUTO_EAT_VERIFY_DELAY_MS)
        return true
    end

    return false
end

function FoodHelper:CheckAutoEatMissingBuff(reason)
    local state = BuildAutoEatState(self:GetCharacterBucketReadonly())
    if not IsAutoEatConfiguredState(state) then
        return false
    end

    local context, err = self:GetActiveAutoEatContext()
    if type(context) ~= "table" then
        DebugAutoEat("missingCheck", "skipped=true", "reason=" .. tostring(err))
        return false
    end

    return self:TryAutoEat(context, reason or "missing_check")
end

function FoodHelper:OnAutoEatEffectChanged(changeType, unitTag, abilityId)
    if changeType ~= EFFECT_RESULT_FADED then
        return false
    end

    if unitTag ~= "player" then
        return false
    end

    local state = BuildAutoEatState(self:GetCharacterBucketReadonly())
    if not IsAutoEatConfiguredState(state) then
        return false
    end

    abilityId = tonumber(abilityId)
    local expectedBuffAbilityId = self:GetBuffAbilityIdForItemId(state.itemId) or state.buffAbilityId
    if expectedBuffAbilityId == nil or abilityId ~= expectedBuffAbilityId then
        return false
    end

    if IsAutoEatDebugEnabled() then
        DebugAutoEat(
            "effectChanged",
            "changeType=" .. tostring(changeType),
            "unitTag=" .. tostring(unitTag),
            "abilityId=" .. tostring(abilityId)
        )
    end

    local context, err = self:GetActiveAutoEatContext()
    if type(context) ~= "table" then
        DebugAutoEat("effectChanged", "skipped=true", "reason=" .. tostring(err))
        return false
    end

    return self:TryAutoEat(context, "effect_faded")
end

function FoodHelper:OnAutoEatCombatStateChanged(inCombat)
    if inCombat == true then
        return false
    end

    local context = self.pendingAutoEatContext
    self.pendingAutoEatContext = nil
    if type(context) ~= "table" then
        return false
    end

    DebugAutoEat("combatDefer", "execute=true")
    return self:TryAutoEat(context, "combat_ended")
end

local function ScheduleAutoEatReviveCheck(foodHelper, generation, checkCount)
    if type(zo_callLater) ~= "function" then
        return false
    end

    zo_callLater(function()
        if foodHelper.autoEatReviveGeneration ~= generation then
            return
        end

        local context = foodHelper:GetActiveAutoEatContext()
        if type(context) == "table" and foodHelper:HasFoodBuffAbilityId(context.buffAbilityId) then
            return
        end

        local isDeadOrReincarnating = type(IsUnitDeadOrReincarnating) == "function"
            and IsUnitDeadOrReincarnating("player") == true
        if isDeadOrReincarnating then
            if checkCount < AUTO_EAT_REVIVE_MAX_CHECK_COUNT then
                ScheduleAutoEatReviveCheck(foodHelper, generation, checkCount + 1)
            end
            return
        end

        foodHelper:CheckAutoEatMissingBuff("player_alive")
    end, AUTO_EAT_REVIVE_CHECK_DELAY_MS)
    return true
end

local function StartAutoEatReviveMonitor(foodHelper)
    foodHelper.autoEatReviveGeneration = (tonumber(foodHelper.autoEatReviveGeneration) or 0) + 1
    return ScheduleAutoEatReviveCheck(foodHelper, foodHelper.autoEatReviveGeneration, 1)
end

function FoodHelper:RegisterAutoEatEvents()
    if self.autoEatEventsRegistered then
        return false
    end
    if EVENT_MANAGER == nil or type(EVENT_MANAGER.RegisterForEvent) ~= "function" then
        return false
    end

    self.autoEatEventsRegistered = true
    EVENT_MANAGER:RegisterForEvent(AUTO_EAT_EFFECT_EVENT_NAME, EVENT_EFFECT_CHANGED, function(_, changeType, _, _, unitTag, _, _, _, _, _, _, _, _, _, _, abilityId)
        FoodHelper:OnAutoEatEffectChanged(changeType, unitTag, abilityId)
    end)

    if type(EVENT_MANAGER.AddFilterForEvent) == "function" and rawget(_G, "REGISTER_FILTER_UNIT_TAG") ~= nil then
        EVENT_MANAGER:AddFilterForEvent(AUTO_EAT_EFFECT_EVENT_NAME, EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG, "player")
    end

    if rawget(_G, "EVENT_PLAYER_COMBAT_STATE") ~= nil then
        EVENT_MANAGER:RegisterForEvent(AUTO_EAT_COMBAT_EVENT_NAME, EVENT_PLAYER_COMBAT_STATE, function(_, inCombat)
            FoodHelper:OnAutoEatCombatStateChanged(inCombat)
        end)
    end

    if rawget(_G, "EVENT_PLAYER_ACTIVATED") ~= nil then
        EVENT_MANAGER:RegisterForEvent(AUTO_EAT_PLAYER_ACTIVATED_EVENT_NAME, EVENT_PLAYER_ACTIVATED, function()
            if type(zo_callLater) == "function" then
                zo_callLater(function()
                    FoodHelper:CheckAutoEatMissingBuff("player_activated")
                end, AUTO_EAT_ACTIVATED_CHECK_DELAY_MS)
            else
                FoodHelper:CheckAutoEatMissingBuff("player_activated")
            end
        end)
    end

    if rawget(_G, "EVENT_PLAYER_ALIVE") ~= nil then
        EVENT_MANAGER:RegisterForEvent(AUTO_EAT_PLAYER_ALIVE_EVENT_NAME, EVENT_PLAYER_ALIVE, function()
            StartAutoEatReviveMonitor(FoodHelper)
        end)
    end

    return true
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
