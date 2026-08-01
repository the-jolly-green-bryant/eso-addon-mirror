SurveyZoneList.Events = {}

--[[
-- Called when the addon is loaded
--
-- @param number eventCode
-- @param string addonName name of the loaded addon
--]]
function SurveyZoneList.Events.onLoaded(eventCode, addOnName)
    -- The event fires each time *any* addon loads - but we only care about when our own addon loads.
    if addOnName == SurveyZoneList.dirName then
        SurveyZoneList:Initialise()
    end
end

--[[
-- Called after each load screen.
-- When it's the character's first load after login (initial = true), it's always called after <EVENT_ADD_ON_LOADED>
--
-- @param integer eventCode
-- @param boolean initial : true if the user just logged on, false with a UI reload (for example)
--]]
function SurveyZoneList.Events.onLoadScreen(eventCode, initial)
    if SurveyZoneList.ready == false then
        return
    end

    SurveyZoneList.Collect:search()
    SurveyZoneList.ItemSort:updateCurrentZone()
    SurveyZoneList.GUI:refreshAll()
end

--[[
-- Called when a item move in the character bag (filter on event)
--
-- @link https://wiki.esoui.com/EVENT_INVENTORY_SINGLE_SLOT_UPDATE
--
-- @param integer eventCode
-- @param integer bagId The bag id (always character bag because filter on event)
-- @param integer slotIdx The item slot index
-- @param bool bNewItem
-- @param integer itemSoundCategory
-- @param integer inventoryUpdateReason
-- @param integer qt
--]]
function SurveyZoneList.Events.onMoveItem(eventCode, bagId, slotIdx, bNewItem, itemSoundCategory, inventoryUpdateReason, qt)
    local itemLink = GetItemLink(bagId, slotIdx)
    local itemZoneName = ""

    if itemLink == "" then
        itemInfo = SurveyZoneList.Collect:findForSlotIdx(slotIdx)

        if itemInfo ~= nil then
            SurveyZoneList.Collect:removeItemFromList(itemInfo, slotIdx)
            SurveyZoneList.GUI:refreshAll()
        end
    else
        itemZoneName = SurveyZoneList.Collect:readItem(slotIdx)

        if itemZoneName ~= nil then
            SurveyZoneList.Collect:updateItemToList(itemZoneName, slotIdx)
            SurveyZoneList.GUI:refreshAll()
        end
    end
end

--[[
-- Called when the user stop to move the GUI
--]]
function SurveyZoneList.Events.onGuiMoveStop()
    SurveyZoneList.GUI:savePosition()
end

--[[
-- Called when the user use the slash command for "toggle GUI"
--]]
function SurveyZoneList.Events.commandToggleGUI()
    SurveyZoneList.GUI:toggle()
end

--[[
-- Called when the user trigger the keybinds for "toggle GUI"
--]]
function SurveyZoneList.Events.keybindingsToggleGUI()
    SurveyZoneList.GUI:toggle()
end

--[[
-- PostHook on TryHandlingInteraction, called when something can be interacted with it
--]]
function SurveyZoneList.Events.reticleTryHandlingInteraction(interactionPossible, currentFrameTimeSeconds)
    return SurveyZoneList.Interaction:updateInteractContext(interactionPossible)
end

--[[
-- Called whe we do an interaction with something
--]]
function SurveyZoneList.Events.onClientInteract(eventCode, result, interactTargetName)
    if SurveyZoneList.Interaction.lastIsSurvey == true then
        SurveyZoneList.Recolt:setNewSurveyInteraction(true)
    end
end

--[[
-- Called when a loot is received
--]]
function SurveyZoneList.Events.onLootReceived(eventCode, receivedBy, itemName)
    SurveyZoneList.Recolt:lootReceived()
end

--[[
-- Called when a bank is opened
--]]
function SurveyZoneList.Events.onOpenBank(eventCode, bankBag)
    SurveyZoneList.Alerts:setInBank(true)
end

--[[
-- Called when a bank is closed
--]]
function SurveyZoneList.Events.onCloseBank(eventCode, bankBag)
    SurveyZoneList.Alerts:setInBank(false)
end
