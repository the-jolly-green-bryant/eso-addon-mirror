local addon = ZO_Object:Subclass()
itemSetCollectionTrackerBind = addon

function addon:New(...)
    local instance = ZO_Object.New(self)
    instance:initialize(...)
    return instance
end

function addon:initialize(owner)
    self.owner = owner
    self.name = string.format("%sBind", self.owner.name)

    self.slots = {}

    self:eventHandler(self.owner.settings.data.autoBind)
end

function addon:eventHandler(bind)
    EVENT_MANAGER:UnregisterForEvent(self.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE)

    if bind then
        EVENT_MANAGER:RegisterForEvent(self.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, function(eventCode, bagId, slotId, isNewItem, itemSoundCategory, inventoryUpdateReason, stackCountChange, triggeredByCharacterName, triggeredByDisplayName)
            if isNewItem == false then
                return
            end

            local itemLink = GetItemLink(bagId, slotId, LINK_STYLE_DEFAULT)
            if not IsItemLinkSetCollectionPiece(itemLink) or IsItemSetCollectionPieceUnlocked(GetItemLinkItemId(itemLink)) then
                return
            end

            local hasSet, setName, numBonuses, numNormalEquipped, maxEquipped, setId, numPerfectedEquipped = GetItemLinkSetInfo(itemLink, false)
            local slot = GetItemLinkItemSetCollectionSlot(itemLink)

            local uniqueSlot = string.format("%d:%d", setId, Id64ToString(slot))
            if not self.slots[uniqueSlot] then
                self.slots[uniqueSlot] = true
                BindItem(bagId, slotId)
            end
        end)
        EVENT_MANAGER:AddFilterForEvent(self.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_IS_NEW_ITEM, true)
        EVENT_MANAGER:AddFilterForEvent(self.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_BAG_ID, BAG_BACKPACK)
    end
end
