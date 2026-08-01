SetCollectionMarker = SetCollectionMarker or {}
local SCM = SetCollectionMarker
SCM.Whisper = SCM.Whisper or {}

---------------------------------------------------------------------
--[[
When a player whispers us with item links, store the item links for
some amount of time. When we initiate a trade with the player, either
automatically add the items or show a button that will add those
items to the trade window.
Once the item is traded, remove it from the list, in case they trade
again. We also need to deal with not putting duplicate items, and
checking that player's list for duplicate items.
]]

---------------------------------------------------------------------
-- Common
---------------------------------------------------------------------
--[[
wantedItems = {
    ["@Kyzeragon"] = {
        items = {
            [id] = trait?,
        },
        timeWhispered = 1284481,
    }
}

Can also be keyed by character name
]]
local wantedItems = {}

function SCM.Whisper.GetWantedItems()
    return wantedItems
end

---------------------------------------------------------------------
-- Item Searching
---------------------------------------------------------------------
-- Returns: {[id] = trait}
--          nil if none
local function GetRecipientWantedItems(name)
    -- Check both the display name and the character name
    local data = wantedItems[name]
    if (not data) then return end

    -- Clean struct if over an hour ago
    local age = GetGameTimeSeconds() - data.timeWhispered
    if (age > 360) then
        wantedItems[name] = nil
        return
    end

    -- Clean struct if there are no items
    local itemCount = 0
    for _, _ in pairs(data.items) do
        return data.items
    end

    wantedItems[name] = nil
    return
end

-- Returns: {slotIndex, slotIndex,} , itemsString
--          {} if none
local function GetMatchingItems(name, allowBoP)
    local wanted = GetRecipientWantedItems(name)
    local resultItems = ""
    if (not wanted) then
        -- None of us are wanted
        return {}, ""
    end

    -- Go through bag to find matching items
    local matches = {}
    local bagCache = SHARED_INVENTORY:GetOrCreateBagCache(BAG_BACKPACK)
    for _, item in pairs(bagCache) do
        local itemLink = GetItemLink(item.bagId, item.slotIndex, LINK_STYLE_BRACKETS)
        local itemId = GetItemLinkItemId(itemLink)
        if (wanted[itemId]) then
            if (IsItemBound(item.bagId, item.slotIndex)) then
                -- Bound already, add tooltip
                resultItems = string.format("%s\n%s (Bound)", resultItems, itemLink)
            elseif (IsItemPlayerLocked(item.bagId, item.slotIndex)) then
                -- Locked, add tooltip
                resultItems = string.format("%s\n%s (Locked)", resultItems, itemLink)
            elseif (IsItemBoPAndTradeable(item.bagId, item.slotIndex)) then
                -- BoP Tradeable
                if (not allowBoP) then
                    -- Cannot be mailed, add tooltip
                    resultItems = string.format("%s\n%s (BoP)", resultItems, itemLink)
                else
                    -- Can be traded
                    if (not IsDisplayNameInItemBoPAccountTable(item.bagId, item.slotIndex, string.gsub(name, "@", ""))) then
                        -- But cannot be traded with this player
                        resultItems = string.format("%s\n%s (BoP untradeable)", resultItems, itemLink)
                    else
                        -- Tradeable, add to list and tooltip
                        resultItems = string.format("%s\n%s", resultItems, itemLink)
                        table.insert(matches, item.slotIndex)
                    end
                end
            else
                -- TODO: this might add doubles?
                -- Add to list and tooltip
                resultItems = string.format("%s\n%s", resultItems, itemLink)
                table.insert(matches, item.slotIndex)
            end
        end
    end

    return matches, resultItems
end
SCM.Whisper.GetMatchingItems = GetMatchingItems

---------------------------------------------------------------------
-- Chatting
---------------------------------------------------------------------
local function UpdateUIs()
    SCM.Trade.UpdateTradeButton()
    SCM.Mail.UpdateMailUI()
end

-- EVENT_CHAT_MESSAGE_CHANNEL (*[ChannelType|#ChannelType]* _channelType_, *string* _fromName_, *string* _text_, *bool* _isCustomerService_, *string* _fromDisplayName_)
local function OnWhisper(_, channelType, fromName, text, _, fromDisplayName)
    if (channelType ~= CHAT_CHANNEL_WHISPER) then return end

    -- It's possible that some data is already saved in character name
    -- Use that if already existing, otherwise use @ name
    local name
    if (fromDisplayName and not wantedItems[fromName]) then
        name = fromDisplayName
    else
        name = fromName
    end

    local data = wantedItems[name] or {}
    local items = data.items or {}

    -- Non-greedy matches. normally it would just be numbers... but Group Loot Notifier inserts :by:<name> at the end for some reason...
    for itemLink in string.gmatch(text, "(|H%d:item:.-|h|h)") do
        -- Senchal Defender's Ring
        -- |H1:item:154836:363:50:0:0:0:0:0:0:0:0:0:0:0:0:95:0:0:0:0:0|h|h
        if (IsItemLinkSetCollectionPiece(itemLink)) then
            local id = GetItemLinkItemId(itemLink)
            local trait = GetItemLinkTraitType(itemLink)
            items[id] = trait
        end
    end

    data.items = items
    data.timeWhispered = GetGameTimeSeconds()
    wantedItems[name] = data
    UpdateUIs()
end

---------------------------------------------------------------------
-- Initialization
---------------------------------------------------------------------
function SCM.Whisper.Initialize()
    EVENT_MANAGER:RegisterForEvent(SCM.name .. "Whisper", EVENT_CHAT_MESSAGE_CHANNEL, OnWhisper)

    -- The EVENT_INVENTORY_SLOT_LOCKED events don't work for this, what are they for?
    EVENT_MANAGER:RegisterForEvent(SCM.name .. "Lock", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, function(_, bagId, _, _, _, inventoryUpdateReason)
        if (inventoryUpdateReason == INVENTORY_UPDATE_REASON_PLAYER_LOCKED and bagId == BAG_BACKPACK) then
            UpdateUIs()
        end
    end)

    SCM.Trade.Initialize()
    SCM.Mail.Initialize()
end

