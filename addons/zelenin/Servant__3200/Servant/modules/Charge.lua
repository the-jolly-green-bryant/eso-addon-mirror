local class = ZO_InitializingObject:Subclass()
servantCharge = class

servantCharge.soulGemId = 33271
servantCharge.crownSoulGemId = 61080

function class:Initialize(owner)
    self.owner = owner
    self.name = string.format("%sCharge", self.owner.name)

    self.chargeItemHandler = LibHandler:LimiterWithDependency(function(bagId, slotIndex)
        if self.owner.eventHandler:IsAlive() then
            self:chargeItem(bagId, slotIndex)
        end
    end, 1000, true)
    self.ChargeAllHandler = LibHandler:Limiter(function()
        self:ChargeAll()
    end, 1000, true)
    self.playerAliveHandler = function()
        self.ChargeAllHandler:Trigger()
    end

    self:Start(self.owner.settings.data.charge)
end

function class:Start(turnOn)
    if turnOn then
        self:start()
    else
        self:stop()
    end
end

function class:start()
    self:ChargeAll()

    self.owner.eventHandler:RegisterCallback("PLAYER_ALIVE", self.playerAliveHandler)

    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, function(eventCode, bagId, slotId, isNewItem, itemSoundCategory, inventoryUpdateReason, stackCountChange, triggeredByCharacterName, triggeredByDisplayName, isLastUpdateForMessage)
        self.chargeItemHandler:Trigger(function()
            return bagId .. "/" .. slotId
        end, bagId, slotId)
    end)
    EVENT_MANAGER:AddFilterForEvent(self.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_BAG_ID, BAG_WORN)
    EVENT_MANAGER:AddFilterForEvent(self.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_INVENTORY_UPDATE_REASON, INVENTORY_UPDATE_REASON_ITEM_CHARGE)

    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_SOUL_GEM_ITEM_CHARGE_FAILURE, function(eventCode, reason)
        self.owner:Error(string.format("%s.", GetString("SI_SOULGEMITEMCHARGINGREASON", reason)))
    end)
end

function class:stop()
    self.owner.eventHandler:UnregisterCallback("PLAYER_ALIVE", self.playerAliveHandler)
    EVENT_MANAGER:UnregisterForEvent(self.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE)
    EVENT_MANAGER:UnregisterForEvent(self.name, EVENT_SOUL_GEM_ITEM_CHARGE_FAILURE)
end

function class:ChargeAll()
    local bagId = BAG_WORN
    for slotIndex in ZO_IterateBagSlots(bagId) do
        if IsItemChargeable(bagId, slotIndex) then
            self.chargeItemHandler:Trigger(function()
                return bagId .. "/" .. slotIndex
            end, bagId, slotIndex)
        end
    end
end

function class:chargeItem(bagId, slotIndex)
    local charges, maxCharges = GetChargeInfoForItem(bagId, slotIndex)
    if (100 * charges / maxCharges) > self.owner.settings.data.minCharge then
        return
    end

    local soulGem = self:getSoulGem()
    if soulGem then
        self.owner:Log(string.format("Charging %s…", GetItemLink(bagId, slotIndex, LINK_STYLE_BRACKETS)))
        ChargeItemWithSoulGem(bagId, slotIndex, soulGem.bag, soulGem.index)
    else
        self.owner:Error(string.format("No soul gems."))
    end
end

function class:getSoulGem()
    local soulGem = nil
    local crownSoulGem = nil

    local items = PLAYER_INVENTORY:GenerateListOfVirtualStackedItems(INVENTORY_BACKPACK, function(bagId, slotIndex)
        local itemId = GetItemId(bagId, slotIndex)
        return itemId == self.soulGemId or itemId == self.crownSoulGemId
    end)
    for itemInstanceId, itemData in pairs(items) do
        local itemId = GetItemId(itemData.bag, itemData.index)
        if itemId == self.soulGemId then
            soulGem = itemData
        end
        if itemId == self.crownSoulGemId then
            crownSoulGem = itemData
        end
    end

    return GetSetting(SETTING_TYPE_IN_WORLD, IN_WORLD_UI_SETTING_DEFAULT_SOUL_GEM) == 0 and (soulGem or crownSoulGem) or (crownSoulGem or soulGem)
end
