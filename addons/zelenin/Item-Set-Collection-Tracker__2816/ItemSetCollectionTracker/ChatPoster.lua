local addon = ZO_Object:Subclass()
itemSetCollectionTrackerChatPoster = addon

function addon:New(...)
    local instance = ZO_Object.New(self)
    instance:initialize(...)
    return instance
end

function addon:initialize(owner)
    self.owner = owner
    self.name = string.format("%sChatPoster", self.owner.name)
    self.displayName = GetDisplayName()
end

function addon:Post(filter)
    local postParts = {}
    local partCount = 5

    filter = filter == nil and function(itemData)
        return true
    end or filter

    local data = SHARED_INVENTORY:GenerateFullSlotData(function(itemData)
        itemData.itemLink = GetItemLink(itemData.bagId, itemData.slotIndex, LINK_STYLE_DEFAULT)
        itemData.itemId = GetItemLinkItemId(itemData.itemLink)
        itemData.isSetCollectionPiece = IsItemLinkSetCollectionPiece(itemData.itemLink)
        itemData.isBound = IsItemBound(itemData.bagId, itemData.slotIndex)
        itemData.isUnlocked = IsItemSetCollectionPieceUnlocked(itemData.itemId)
        itemData.BoPTimeRemainingSeconds = GetItemBoPTimeRemainingSeconds(itemData.bagId, itemData.slotIndex)
        itemData.equipType = GetItemLinkEquipType(itemData.itemLink)
        itemData.locked = IsItemPlayerLocked(itemData.bagId, itemData.slotIndex)

        return self:isValidForPosting(itemData, filter)
    end, BAG_BACKPACK)

    for _, itemData in ipairs(data) do
        if postParts[#postParts] == nil or #postParts[#postParts] == partCount then
            postParts[#postParts + 1] = {}
        end
        local itemLink = itemData.itemLink:gsub("^|H0", "|H1", 1)
        table.insert(postParts[#postParts], itemLink)
    end

    local postLines = {}
    for _, postPart in ipairs(postParts) do
        table.insert(postLines, table.concat(postPart))
    end

    if #postLines > 0 then
        local channel = CHAT_CHANNEL_PARTY
        EVENT_MANAGER:RegisterForEvent(self.name, EVENT_CHAT_MESSAGE_CHANNEL, function(eventCode, channelType, fromName, text, isCustomerService, fromDisplayName)
            if fromDisplayName ~= self.displayName then
                return
            end

            if #postLines > 0 then
                StartChatInput(postLines[1], channel)
                table.remove(postLines, 1)
            else
                EVENT_MANAGER:UnregisterForEvent(self.name, EVENT_CHAT_MESSAGE_CHANNEL)
            end
        end)

        StartChatInput(postLines[1], channel)
        table.remove(postLines, 1)
    end
end

function addon:isValidForPosting(itemData, filter)
    if not (itemData.isSetCollectionPiece and itemData.isBoPTradeable and not itemData.isBound and itemData.BoPTimeRemainingSeconds > 0 and not itemData.locked) then
        return false
    end

    return filter(itemData)
end
