local addon = ZO_InitializingObject:Subclass()
rewardsTrackerOpener = addon

local function GetCurrencyInfo(currencyType)
    local isAccountWide = GetMaxPossibleCurrency(currencyType, CURRENCY_LOCATION_ACCOUNT) > 0

    local amount = isAccountWide and GetCurrencyAmount(currencyType, CURRENCY_LOCATION_ACCOUNT) or GetCurrencyAmount(currencyType, CURRENCY_LOCATION_CHARACTER)
    local max = isAccountWide and GetMaxPossibleCurrency(currencyType, CURRENCY_LOCATION_ACCOUNT) or GetMaxPossibleCurrency(currencyType, CURRENCY_LOCATION_CHARACTER)

    return isAccountWide, amount, max
end

local function GetNumLootCurrencies()
    local num = 0
    for currencyType = CURT_ITERATION_BEGIN, CURT_ITERATION_END do
        if IsCurrencyValid(currencyType) then
            local unownedCurrency, ownedCurrency = GetLootCurrency(currencyType)
            if unownedCurrency > 0 then
                num = num + 1
            end
        end
    end

    return num
end

function addon:Initialize(owner)
    self.owner = owner
    self.name = string.format("%sOpener", self.owner.name)

    self.provider = rewardsTrackerContainerDataProvider:New(self)

    self.stop = true
    self.slots = {}
    self.itemNames = {}
    self.cooldown = 600
    self.fishCooldown = 2000

    self.geodeQuantity = {
        -- strict
        [134583] = 1,
        [134588] = 5,
        [134590] = 10,
        [134591] = 50,
        [134595] = 50,
        [140222] = 1000,
        [171531] = 3,
        [178570] = 5,
        [211304] = 25,
        [211305] = 100,
        -- none strict
        [134618] = 25,
        [134622] = 3,
        [134623] = 10,
    }

    local sortedGeodes = {}
    for itemId, quantity in pairs(self.geodeQuantity) do
        table.insert(sortedGeodes, {
            id = itemId,
            quantity = quantity,
        })
    end

    table.sort(sortedGeodes, function(a, b)
        return a.quantity < b.quantity
    end)

    self.geodeOrder = {}
    for index, geode in ipairs(sortedGeodes) do
        self.geodeOrder[geode.id] = index
    end

    self.containerIds = {}
    for itemId, _ in pairs(self.provider:GetContainers()) do
        self.containerIds[itemId] = true
    end
    for itemId, _ in pairs(self.provider:GetEventContainers()) do
        self.containerIds[itemId] = true
    end
    for itemId, _ in pairs(self.provider:GetCurrencyContainers()) do
        self.containerIds[itemId] = true
    end
    for itemId, _ in pairs(self.provider:GetFishes()) do
        self.containerIds[itemId] = true
    end

    --for itemId, _ in pairs(self.geodeQuantity) do
    --    self.containerIds[itemId] = true
    --end

    ZO_PreHook(SYSTEMS:GetObject("loot"), "UpdateLootWindow", function(_self, name, actionName, isOwned)
        local name, targetType, actionName, isOwned = GetLootTargetInfo()

        if targetType == INTERACT_TARGET_TYPE_ITEM and self.itemNames[name] == true then
            return true
        end

        return false
    end)

    SLASH_COMMANDS["/open-containers"] = function(cmd)
        if cmd == "" then
            self:openContainers()
        end
        if cmd == "stop" then
            self.stop = true
        end
    end
end

function addon:openContainers()
    self.stop = false
    self.slots = {}
    self.itemNames = {}

    -- ZO_SharedInventoryManager:CreateOrUpdateSlotData
    SHARED_INVENTORY:GenerateFullSlotData(function(itemData)
        itemData.itemId = GetItemId(itemData.bagId, itemData.slotIndex)
        itemData.itemLink = GetItemLink(itemData.bagId, itemData.slotIndex, LINK_STYLE_BRACKETS)
        itemData.order = self.geodeOrder[itemData.itemId] == nil and itemData.stackCount or self.geodeOrder[itemData.itemId]

        if self:isValid(itemData) then
            table.insert(self.slots, itemData)
            self.itemNames[itemData.name] = true
        end

        return false
    end, BAG_BACKPACK)

    table.sort(self.slots, function(a, b)
        return a.order < b.order
    end)

    self:handleSlots()
end

function addon:isValid(slot)
    if self.containerIds[slot.itemId] ~= true then
        return false
    end

    if self.geodeQuantity[slot.itemId] ~= nil then
        local isAccountWide, amount, max = GetCurrencyInfo(CURT_CHAOTIC_CREATIA)
        if (self.geodeQuantity[slot.itemId] + amount) > max then
            return false
        end
    end

    return true
end

function addon:handleSlots()
    for _, slot in ipairs(self.slots) do
        --CHAT_ROUTER:AddSystemMessage(string.format("slot: %s", slot.name))
        if GetNumBagFreeSlots(BAG_BACKPACK) == 0 then
            break
        else
            self:openSlot(slot, slot.stackCount)
            return
        end
    end

    self.slots = {}
    self.itemNames = {}
end

function addon:openSlot(slot, count)
    if count == 0 or not self:isValid(slot) then
        table.remove(self.slots, 1)
        self:handleSlots()
        return
    end
    for i = 1, count do
        local remain, duration = GetItemCooldownInfo(slot.bagId, slot.slotIndex)

        zo_callLater(function()
            self:useSlot(slot, count)
        end, remain + 500)
        return
    end
end

local announcementsColor = ZO_ColorDef.FromInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_ANNOUNCEMENTS)
local succeededColor = ZO_ColorDef.FromInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_SUCCEEDED)
local failedColor = ZO_ColorDef.FromInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_FAILED)
local selectedColor = ZO_ColorDef.FromInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_SELECTED)
local hintColor = ZO_ColorDef.FromInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_HINT)

function addon:useSlot(slot, count)
    self.owner:Log(string.format("Opening %s %s", zo_iconFormat(slot.iconFile, 16, 16), slot.itemLink))
    if IsProtectedFunction("UseItem") then
        CallSecureProtected("UseItem", slot.bagId, slot.slotIndex)
    else
        UseItem(slot.bagId, slot.slotIndex)
    end

    zo_callLater(function()
        self:lootSlot(slot, count)
    end, self:getCooldown(slot.itemId))
end

function addon:getCooldown(itemId)
    if self.provider:GetFishes()[itemId] == true then
        return self.fishCooldown
    end

    return self.cooldown
end

function addon:lootSlot(slot, count)
    --CHAT_ROUTER:AddSystemMessage(slot.name)
    for lootIndex = 1, GetNumLootItems() do
        local lootId, itemName, icon, count, quality, value, isQuest, stolen, lootType = GetLootItemInfo(lootIndex)
        local itemLink = GetLootItemLink(lootId, LINK_STYLE_BRACKETS)

        self.owner:Log(string.format("Looting %s %s x %d", zo_iconFormat(icon, 16, 16), itemLink, count))

        LootItemById(lootId)
    end

    for currencyType = CURT_ITERATION_BEGIN, CURT_ITERATION_END do
        if IsCurrencyValid(currencyType) then
            local unownedCurrency, ownedCurrency = GetLootCurrency(currencyType)

            local isAccountWide, amount, max = GetCurrencyInfo(currencyType)
            local icon = GetCurrencyLootKeyboardIcon(currencyType)
            if (unownedCurrency + ownedCurrency) > 0 and (unownedCurrency + ownedCurrency + amount) < max then
                self.owner:Log(string.format("Looting %s %s: %d", zo_iconFormat(icon, 16, 16), GetCurrencyName(currencyType, false, false), unownedCurrency + ownedCurrency))
                LootCurrency(currencyType)
            end
        end
    end

    EndLooting()

    if self.stop == true then
        self.slots = {}
        self.itemNames = {}
        return
    end

    self:openSlot(slot, count - 1)
end
