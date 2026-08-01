WritStylePrice.Events = {}

--[[
-- Called when the addon is loaded
--
-- @link https://wiki.esoui.com/EVENT_ADD_ON_LOADED
--
-- @param int eventCode
-- @param string addonName name of the loaded addon
--]]
function WritStylePrice.Events.onLoaded(eventCode, addOnName)
    -- The event fires each time *any* addon loads - but we only care about when our own addon loads.
    if addOnName == WritStylePrice.dirName then
        WritStylePrice:Initialise()
    end
end

--[[
-- Called when there is a load screen.
-- Do the collect if necessary.
--
-- @link https://wiki.esoui.com/EVENT_PLAYER_ACTIVATED
--
-- @param int eventCode
-- @param bool initial
--]]
function WritStylePrice.Events.onLoadScreen(eventCode, initial)
    if WritStylePrice.ready == false then
        return
    end

    local CollectStatus = WritStylePrice.Collect.status

    -- When reloadui, initial=false :/
    if CollectStatus.savedListReaded == false then
        WritStylePrice.async:Call(function()
            WritStylePrice.Collect:readSavedList()
            WritStylePrice.Collect:readCharBag()
            WritStylePrice.Collect:readBank()
            WritStylePrice.Collect:readHouseBanks()
        end)
    else
        if IsOwnerOfCurrentHouse() == true and CollectStatus.houseCollected == false then
            WritStylePrice.async:Call(function()
                WritStylePrice.Collect:readHouseBanks()
            end)
        end
    end
end

--[[
-- Called when the keybind is used
--]]
function WritStylePrice.Events.keybindingsToggle()
    if WritStylePrice.ready == false then
        d("WritStylePrice : Sorry, the addon is not yet fully loaded.")
        return
    end

    WritStylePrice.GUI:toggle()
end

--[[
-- Called when the slash command is used
--]]
function WritStylePrice.Events.toggleGUI()
    if WritStylePrice.ready == false then
        d("WritStylePrice : Sorry, the addon is not yet fully loaded.")
        return
    end

    WritStylePrice.GUI:toggle()
end

--[[
-- Called when the GUI is closed by the top-right cross
--]]
function WritStylePrice.Events.GuiClose()
    WritStylePrice.GUI:hide()
end

--[[
-- Called when the GUI o longer moved to save the current position
--]]
function WritStylePrice.Events.onGuiMoveStop()
    WritStylePrice.GUI:savePosition()
end

--[[
-- Called when the bank is opened to collect it if necessary
--
-- @link https://wiki.esoui.com/EVENT_OPEN_BANK
--
-- @param int eventCode
-- @param int bagId
--]]
function WritStylePrice.Events.onOpenBank(eventCode, bagId)
    if WritStylePrice.ready == false then
        return
    end

    -- House bank (chest) trigger this event too
    if bagId ~= BAG_BANK and bagId ~= BAG_SUBSCRIBER_BANK then
        return
    end

    if WritStylePrice.Collect.status.bankCollected == false then
        WritStylePrice.async:Call(function()
            WritStylePrice.Collect:readBank()
        end)
    end
end

--[[
-- Called when a new item is looted, when an item move between bags, or is used.
--
-- @link https://wiki.esoui.com/EVENT_INVENTORY_SINGLE_SLOT_UPDATE
--
-- @param int eventCode
-- @param int bagId
-- @param int slotIdx
-- @param bool bNewItem
-- @param int itemSoundCategory
-- @param int inventoryUpdateReason
-- @param int qt
--]]
function WritStylePrice.Events.onMoveItem(eventCode, bagId, slotIdx, bNewItem, itemSoundCategory, inventoryUpdateReason, qt)
    local bagItemList = WritStylePrice.Collect:obtainBagItemList(bagId)

    -- Not followed bag
    if bagItemList == nil then
        return
    end

    WritStylePrice.Collect:readItemSlot(bagId, slotIdx, bagItemList)

    if WritStylePrice.GUI:getIsHidden() == false then
        WritStylePrice.GUI:refreshList()
    end
end
