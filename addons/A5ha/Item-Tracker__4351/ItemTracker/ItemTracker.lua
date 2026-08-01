local ADDON_NAME = "ItemTracker"
local ItemTracker = { name = ADDON_NAME, Settings = {}, windows = {} }
local trackerFragments = {}
local defaultSavedVariables = {
    trackers = {}, -- [itemId] = {count=0, windowOffsetX=20, windowOffsetY=20, enabled=true, itemLink=""}
}

local clamp = zo_clamp

local function FormatNumber(number)
    local formatted = tostring(number)
    local k = formatted:len() % 3
    if k == 0 then k = 3 end
    return formatted:sub(1, k) .. formatted:sub(k+1):gsub("(%d%d%d)", ",%1")
end

local function CreateTrackerWindow(itemId, itemLink)
    local tracker = ItemTracker.Settings.trackers[itemId]
    if not tracker or ItemTracker.windows[itemId] then return end

    local window = WINDOW_MANAGER:CreateTopLevelWindow("ItemTrackerWindow_" .. itemId)
    window:SetDimensions(60, 30)
    window:SetMouseEnabled(true)
    window:SetMovable(true)
    window:SetClampedToScreen(true)
    
    local x = clamp(tonumber(tracker.windowOffsetX) or 20, 0, GuiRoot:GetWidth() - 60)
    local y = clamp(tonumber(tracker.windowOffsetY) or 20, 0, GuiRoot:GetHeight() - 24)
    window:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, x, y)
    
    window:SetHandler("OnMoveStop", function(self)
        tracker.windowOffsetX = clamp(self:GetLeft(), 0, GuiRoot:GetWidth() - 60)
        tracker.windowOffsetY = clamp(self:GetTop(), 0, GuiRoot:GetHeight() - 24)
    end)
    
    local background = WINDOW_MANAGER:CreateControl("ItemTrackerBG_" .. itemId, window, CT_BACKDROP)
    background:SetAnchorFill()
    background:SetEdgeTexture("ItemTracker/Textures/centerscreen_floating_edge.dds", 256, 256, 8)
    background:SetCenterTexture("ItemTracker/Textures/centerscreen_floating_center.dds")
    background:SetInsets(8, 8, -8, -8)
    background:SetAlpha(0.5)
    local bgColor = ZO_ColorDef:New(0, 0, 0, 1)
    background:SetCenterColor(bgColor:UnpackRGBA())
    background:SetEdgeColor(bgColor:UnpackRGBA())
    
    local icon = WINDOW_MANAGER:CreateControl("ItemTrackerIcon_" .. itemId, window, CT_TEXTURE)
    icon:SetDimensions(24, 24)
    icon:SetAnchor(LEFT, window, LEFT, 6, 0)
    icon:SetTexture(GetItemLinkIcon(itemLink) or "/esoui/art/icons/icon_missing.dds")
    
    local countLabel = WINDOW_MANAGER:CreateControl("ItemTrackerCount_" .. itemId, window, CT_LABEL)
    countLabel:SetDimensions(80, 20)
    countLabel:SetAnchor(LEFT, icon, RIGHT, 2, 0)
    countLabel:SetFont("ZoFontWinH4")
    countLabel:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    
    ItemTracker.windows[itemId] = {window = window, icon = icon, countLabel = countLabel}
    ItemTracker.UpdateTrackerDisplay(itemId)

    local fragmentName = "ItemTrackerFragment_" .. itemId
    local fragment = ZO_SimpleSceneFragment:New(window)
    HUD_SCENE:AddFragment(fragment)
    HUD_UI_SCENE:AddFragment(fragment)
    trackerFragments[itemId] = fragment
end

function ItemTracker.UpdateTrackerDisplay(itemId)
    local tracker = ItemTracker.Settings.trackers[itemId]
    local windowData = ItemTracker.windows[itemId]
    if not windowData or not tracker then return end
    
    local count = tracker.count or 0
    local displayText = FormatNumber(count)
    windowData.countLabel:SetText(displayText)
    
    local digitCount = string.len(tostring(count))
    local baseWidth = 60
    local extension = math.max(0, (digitCount - 1) * 8)
    windowData.window:SetDimensions(baseWidth + extension, 30)
end

function ItemTracker.UpdateItemCounts()
    for itemId, tracker in pairs(ItemTracker.Settings.trackers) do
        if tracker.enabled then
            local backpackCount = 0
            local targetItemId = tonumber(itemId)
            
            for slotIndex = 1, GetNumBagUsedSlots(BAG_BACKPACK) do
                local slotItemLink = GetItemLink(BAG_BACKPACK, slotIndex)
                if slotItemLink ~= "" then
                    local slotItemId = tonumber(GetItemLinkItemId(slotItemLink))
                    if slotItemId == targetItemId then
                        local count = GetSlotStackSize(BAG_BACKPACK, slotIndex) or 1
                        backpackCount = backpackCount + count
                    end
                end
            end
            
            tracker.count = backpackCount
            ItemTracker.UpdateTrackerDisplay(itemId)
        end
    end
end

function ItemTracker.OnPlayerActivated(eventCode)
    ItemTracker.UpdateItemCounts()
    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_PLAYER_ACTIVATED)
end

function ItemTracker.OnAddOnLoaded(event, addonName)
    if addonName ~= ItemTracker.name then return end
    local worldName = GetWorldName()
    ItemTracker.Settings = ZO_SavedVars:NewAccountWide("ItemTracker_SavedVariables", 1, worldName, defaultSavedVariables)

    local trackerCount = 0
    for itemId, tracker in pairs(ItemTracker.Settings.trackers) do
        if tracker.enabled == true and tracker.itemLink and tracker.itemLink ~= "" then
            CreateTrackerWindow(itemId, tracker.itemLink)
            trackerCount = trackerCount + 1
        end
    end

    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_PLAYER_ACTIVATED, ItemTracker.OnPlayerActivated)
    local eventSingleSlotUpdateName = ADDON_NAME .. "SingleSlot"
    EVENT_MANAGER:RegisterForEvent(eventSingleSlotUpdateName, EVENT_INVENTORY_SINGLE_SLOT_UPDATE,
        function(eventCode, bagId, slotId, isNewItem, itemSound, inventoryUpdateReason, stackCountChange)
            ItemTracker.UpdateItemCounts()
        end)
    EVENT_MANAGER:AddFilterForEvent(eventSingleSlotUpdateName, EVENT_INVENTORY_SINGLE_SLOT_UPDATE,
        REGISTER_FILTER_BAG_ID, BAG_BACKPACK,
        REGISTER_FILTER_INVENTORY_UPDATE_REASON, INVENTORY_UPDATE_REASON_DEFAULT,
        REGISTER_FILTER_IS_NEW_ITEM, true)
    
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_OPEN_BANK, ItemTracker.UpdateItemCounts)
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_CLOSE_BANK, ItemTracker.UpdateItemCounts)
    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)

    SLASH_COMMANDS["/itradd"] = function(msg)
        local itemLink = msg:match("|H1[^|%s]+|h[1]?")
        if itemLink then
            local itemId = GetItemLinkItemId(itemLink)
            
            local windowName = "ItemTrackerWindow_" .. itemId
            local existingWindow = GetControl(windowName)
            
            if ItemTracker.Settings.trackers[itemId] then 
                d(GetString(ITR_ADD_EXI))
            elseif existingWindow then
                d(GetString(ITR_ADD_EXI) .. GetString(ITR_RLD_INF))
            else
                ItemTracker.Settings.trackers[itemId] = {
                    count = 0,
                    windowOffsetX = 20, 
                    windowOffsetY = 20,
                    enabled = true,
                    itemLink = itemLink
                }
                CreateTrackerWindow(itemId, itemLink)
                ItemTracker.UpdateItemCounts()
                local itemName = GetItemLinkName(itemLink)
                d(string.format(GetString(ITR_ADD), itemName))
            end
        else
            d(GetString(ITR_ADD_INF))
        end
    end

    SLASH_COMMANDS["/itrdel"] = function(msg)
        local itemLink = msg:match("|H1[^|%s]+|h[1]?")
        if itemLink then
            local itemId = GetItemLinkItemId(itemLink)
            if ItemTracker.Settings.trackers[itemId] then
                if trackerFragments[itemId] then
                    HUD_SCENE:RemoveFragment(trackerFragments[itemId])
                    HUD_UI_SCENE:RemoveFragment(trackerFragments[itemId])
                    trackerFragments[itemId] = nil
                end
                if ItemTracker.windows[itemId] then
                    local window = ItemTracker.windows[itemId].window
                    window:ClearAnchors()
                    window:SetParent(nil)
                    window:SetHidden(true)
                    ItemTracker.windows[itemId] = nil
                end
                ItemTracker.Settings.trackers[itemId] = nil
                d(GetString(ITR_DEL))
            else
                d(GetString(ITR_DEL_NOT))
            end
        else
            d(GetString(ITR_DEL_INF))
        end
    end
    
    SLASH_COMMANDS["/itrclr"] = function()
        for itemId, fragment in pairs(trackerFragments) do
            if fragment then
                HUD_SCENE:RemoveFragment(fragment)
                HUD_UI_SCENE:RemoveFragment(fragment)
            end
        end
        trackerFragments = {}
        
        for itemId, windowData in pairs(ItemTracker.windows) do
            if windowData and windowData.window then
                local window = windowData.window
                window:ClearAnchors()
                window:SetParent(nil)
                window:SetHidden(true)
            end
        end
        ItemTracker.windows = {}
        
        ItemTracker.Settings.trackers = {}
        
        d(GetString(ITR_CLR) .. GetString(ITR_RLD_INF))
    end
    
    SLASH_COMMANDS["/itrhelp"] = function()
        d(GetString(ITR_INF))
    end
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, ItemTracker.OnAddOnLoaded)