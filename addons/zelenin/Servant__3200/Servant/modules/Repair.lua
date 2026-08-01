local class = ZO_InitializingObject:Subclass()
servantRepair = class

servantRepair.repairKitId = 44879
servantRepair.crownRepairKitIds = { 61079, 135113 }

function class:Initialize(owner)
    self.owner = owner
    self.name = string.format("%sRepair", self.owner.name)

    self.condition = false

    self.repairItemHandler = LibHandler:LimiterWithDependency(function(bagId, slotIndex)
        if self.owner.eventHandler:IsAlive() then
            self:repairItem(bagId, slotIndex)
        end
    end, 1000, true)
    self.RepairAllHandler = LibHandler:Limiter(function()
        self:RepairAll()
    end, 1000, true)
    self.playerAliveHandler = function()
        self.RepairAllHandler:Trigger()
    end

    self:Start(self.owner.settings.data.repair)
end

function class:Start(turnOn)
    if turnOn then
        self:start()
    else
        self:stop()
    end
end

function class:start()
    self:RepairAll()

    self.owner.eventHandler:RegisterCallback("PLAYER_ALIVE", self.playerAliveHandler)

    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, function(eventCode, bagId, slotId, isNewItem, itemSoundCategory, inventoryUpdateReason, stackCountChange, triggeredByCharacterName, triggeredByDisplayName, isLastUpdateForMessage)
        self.repairItemHandler:Trigger(function()
            return bagId .. "/" .. slotId
        end, bagId, slotId)
    end)
    EVENT_MANAGER:AddFilterForEvent(self.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_BAG_ID, BAG_WORN)
    EVENT_MANAGER:AddFilterForEvent(self.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_INVENTORY_UPDATE_REASON, INVENTORY_UPDATE_REASON_DURABILITY_CHANGE)

    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_ITEM_REPAIR_FAILURE, function(eventCode, reason)
        self.owner:Error(string.format("%s.", GetString("SI_ITEMREPAIRREASON", reason)))
    end)
end

function class:stop()
    self.owner.eventHandler:UnregisterCallback("PLAYER_ALIVE", self.playerAliveHandler)
    EVENT_MANAGER:UnregisterForEvent(self.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE)
    EVENT_MANAGER:UnregisterForEvent(self.name, EVENT_ITEM_REPAIR_FAILURE)
end

function class:RepairAll()
    if self:tryRepairByCrownRepairKit() then
        return
    end

    local bagId = BAG_WORN
    for slotIndex in ZO_IterateBagSlots(bagId) do
        if DoesItemHaveDurability(bagId, slotIndex) then
            self.repairItemHandler:Trigger(function()
                return bagId .. "/" .. slotIndex
            end, bagId, slotIndex)
        end
    end
end

function class:repairItem(bagId, slotIndex)
    if self:tryRepairByCrownRepairKit() then
        return
    end

    local condition = GetItemCondition(bagId, slotIndex)
    if condition > self.owner.settings.data.minCondition then
        return
    end

    local repairKit = self:getRepairKit()
    if repairKit then
        self.owner:Log(string.format("Repairing %s…", GetItemLink(bagId, slotIndex, LINK_STYLE_BRACKETS)))
        RepairItemWithRepairKit(bagId, slotIndex, repairKit.bag, repairKit.index)
    else
        self.owner:Error(string.format("No repair kits."))
    end
end

function class:getRepairKit()
    local repairKit = nil

    local items = PLAYER_INVENTORY:GenerateListOfVirtualStackedItems(INVENTORY_BACKPACK, function(bagId, slotIndex)
        local itemId = GetItemId(bagId, slotIndex)
        return itemId == self.repairKitId
    end)
    for itemInstanceId, itemData in pairs(items) do
        local itemId = GetItemId(itemData.bag, itemData.index)
        if itemId == self.repairKitId then
            repairKit = itemData
        end
    end

    return repairKit
end

function class:getCrownRepairKit()
    local itemIds = {}
    for _, itemId in ipairs(self.crownRepairKitIds) do
        itemIds[itemId] = true
    end

    local repairKit = nil

    local items = PLAYER_INVENTORY:GenerateListOfVirtualStackedItems(INVENTORY_BACKPACK, function(bagId, slotIndex)
        local itemId = GetItemId(bagId, slotIndex)
        return itemIds[itemId] == true
    end)
    for itemInstanceId, itemData in pairs(items) do
        local itemId = GetItemId(itemData.bag, itemData.index)
        if itemIds[itemId] == true then
            repairKit = itemData
        end
    end

    return repairKit
end

function class:getAvgCondition()
    local condition = 0
    local slots = 0

    local bagId = BAG_WORN
    for slotIndex in ZO_IterateBagSlots(bagId) do
        if DoesItemHaveDurability(bagId, slotIndex) then
            condition = condition + GetItemCondition(bagId, slotIndex)
            slots = slots + 1
        end
    end

    return condition / slots
end

function class:tryRepairByCrownRepairKit()
    if self.owner.settings.data.crownRepairKits == true then
        local repairKit = self:getCrownRepairKit()
        if repairKit then
            local avgCondition = self:getAvgCondition()
            if avgCondition < self.owner.settings.data.minAvgCondition then
                self:checkCondition(repairKit.bag, repairKit.index)
                return true
            end
        end
    end

    return false
end

function class:checkCondition(bagId, slotIndex)
    if self.condition == true then
        return
    end

    self.condition = true

    LibHandler:Condition(
        function()
            return self:readyToUse(bagId, slotIndex)
        end,
        function()
            local result =  self:use(bagId, slotIndex)
            self.condition = false
            return result
        end,
        200
    )
end

function class:readyToUse(bagId, slotIndex)
    local playerState = self.owner.eventHandler:IsAlive() and
        not self.owner.eventHandler:IsBlocking() and
        not self.owner.eventHandler:IsRunning() and
        not self.owner.eventHandler:IsStunned() and
        not self.owner.eventHandler:InCombat() and
        not self.owner.eventHandler:IsMounted()

    if not playerState then
        return false
    end

    local remain, duration = GetItemCooldownInfo(bagId, slotIndex)
    if remain > 0 and duration > 0 then
        return false
    end

    return true
end

function class:use(bagId, slotIndex)
    self.owner:Log(string.format("Repairing by %s…", GetItemLink(bagId, slotIndex, LINK_STYLE_BRACKETS)))

    if IsProtectedFunction("UseItem") then
        CallSecureProtected("UseItem", bagId, slotIndex)
    else
        UseItem(bagId, slotIndex)
    end
end
