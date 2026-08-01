-- TTDungeon.lua
-- Main addon logic and functionality

-- Initialize addon namespace
TTDungeon = TTDungeon or {}
TTDungeon.name    = "TTDungeon"
TTDungeon.version = "2.0" 

-- Default saved variables configuration
-- These values are used when the addon is first installed
local defaultSavedVars = {
    offsetX         = 200,          -- UI window X position
    offsetY         = 200,          -- UI window Y position
    isUIHidden      = false,        -- Whether UI is hidden
    backgroundAlpha = 0.5,          -- Background transparency (0-1)
    displayMode     = "Always",     -- When to show UI: "Always", "OnlyInDungeon", "Manual"
    expandedHeight  = 300,          -- Height when expanded
    minimizedHeight = 80,           -- Height when minimized
    debugEnabled    = false,        -- Enable debug messages
    invertScroll    = true,         -- Invert scroll wheel direction
    lockUI          = false,        -- Lock UI position
    uiScale         = 1.0,          -- UI scale factor
    language        = "en",         -- Interface language ("en" or "de")
}

-- UI state tracking (runtime only - not saved)
TTDungeon.wasManuallyMinimized = false    -- Track if user manually minimized
TTDungeon.isMinimized          = false    -- Current minimized state
TTDungeon.manualDungeonMode    = false    -- Manual dungeon selection active
TTDungeon.selectedDungeonId    = nil      -- Manually selected dungeon ID

-- Daily Pledges System
TTDungeon.dailyPledges = {}

-- Custom dropdown state
TTDungeon.dropdownOpen = false             -- Is dropdown menu open
TTDungeon.dropdownMenu = nil               -- Dropdown menu control reference

-- Debug function for logging messages when debug mode is enabled
local function Debug(msg)
    if TTDungeon.savedVars and TTDungeon.savedVars.debugEnabled then
        d("[TTDungeon Debug] " .. tostring(msg))
    end
end
TTDungeon.Debug = Debug

-- Set active language data based on saved preference
-- Loads the appropriate dungeon information tables for the selected language
function TTDungeon.SetLanguageData()
    -- Handle case where savedVars isn't loaded yet
    if not TTDungeon.savedVars then
        Debug("SetLanguageData called but savedVars is nil. Defaulting to English.")
        TTDungeon.BaseDungeonInfo = TTDungeon.BaseDungeonInfo_en or {}
        TTDungeon.DLCDungeonInfo = TTDungeon.DLCDungeonInfo_en or {}
        return
    end

    local languageCode = TTDungeon.savedVars.language or "en"

    -- Normalize language code and handle legacy "Deutsch" value for backwards compatibility
    local useGerman = false
    if languageCode == "de" or languageCode == "Deutsch" then
        useGerman = true
        -- Update legacy value to modern format
        if languageCode == "Deutsch" then
             TTDungeon.savedVars.language = "de"
        end
    end

    -- Load appropriate language data
    if useGerman then
        -- Check if German data exists
        local baseDeExists = TTDungeon.BaseDungeonInfo_de ~= nil
        local dlcDeExists = TTDungeon.DLCDungeonInfo_de ~= nil

        if baseDeExists and dlcDeExists then
            TTDungeon.BaseDungeonInfo = TTDungeon.BaseDungeonInfo_de
            TTDungeon.DLCDungeonInfo = TTDungeon.DLCDungeonInfo_de
        else
            Debug("WARNING: German dungeon data (_de tables) not found! Falling back to English.")
            TTDungeon.BaseDungeonInfo = TTDungeon.BaseDungeonInfo_en or {}
            TTDungeon.DLCDungeonInfo = TTDungeon.DLCDungeonInfo_en or {}
        end
    else
        -- Default to English
        TTDungeon.BaseDungeonInfo = TTDungeon.BaseDungeonInfo_en or {}
        TTDungeon.DLCDungeonInfo = TTDungeon.DLCDungeonInfo_en or {}
    end

    -- Update tab labels based on selected language
    if TTDungeon.tabs and TTDungeon.tabs.encBtn then
        local currentLangCode = TTDungeon.savedVars.language or "en"
        
        -- Define tab labels for each language
        local encText = currentLangCode == "de" and "Bosse" or "Enc"    -- Bosses/Encounters
        local setText = currentLangCode == "de" and "Sets" or "Sets"    -- Sets (same in both)
        local achText = currentLangCode == "de" and "Erf." or "Ach"     -- Erfolge/Achievements
        
        -- Update tab button labels
        if TTDungeon.tabs.encBtn.label then TTDungeon.tabs.encBtn.label:SetText(encText) end
        if TTDungeon.tabs.setBtn.label then TTDungeon.tabs.setBtn.label:SetText(setText) end
        if TTDungeon.tabs.achBtn.label then TTDungeon.tabs.achBtn.label:SetText(achText) end
        
        -- Refresh tab layout
        if TTDungeon.UpdateTabLayout then
            TTDungeon.UpdateTabLayout()
        end
    end

    -- Update dungeon selector placeholder text
    if TTDungeon.UpdateDungeonSelector then
        TTDungeon.UpdateDungeonSelector()
    end
    
    -- Rebuild dropdown menu if it's currently open
    if TTDungeon.dropdownOpen and TTDungeon.PopulateDropdownMenu then
        Debug("Language changed while dropdown is open - rebuilding dropdown menu")
        TTDungeon.PopulateDropdownMenu()
    end
    
    -- Update all UI texts to reflect new language
    if TTDungeon.UpdateUIContent then
        TTDungeon.UpdateUIContent()
    end
end

-- Get all dungeons from both base game and DLC, sorted alphabetically by name
-- Returns array of dungeon objects with zoneId, name, data, and isBase flag
function TTDungeon.GetAllDungeons()
    local dungeons = {}
    
    -- Add base game dungeons
    if TTDungeon.BaseDungeonInfo then
        for zoneId, data in pairs(TTDungeon.BaseDungeonInfo) do
            if data and data.name then
                table.insert(dungeons, {
                    zoneId = zoneId,
                    name = data.name,
                    data = data,
                    isBase = true
                })
            end
        end
    else
        Debug("Warning: BaseDungeonInfo not loaded!")
    end
    
    -- Add DLC dungeons
    if TTDungeon.DLCDungeonInfo then
        for zoneId, data in pairs(TTDungeon.DLCDungeonInfo) do
            if data and data.name then
                table.insert(dungeons, {
                    zoneId = zoneId,
                    name = data.name,
                    data = data,
                    isBase = false
                })
            end
        end
    else
        Debug("Warning: DLCDungeonInfo not loaded!")
    end
    
    -- Sort dungeons alphabetically by name
    table.sort(dungeons, function(a, b) return a.name < b.name end)
    
    Debug("GetAllDungeons found " .. #dungeons .. " dungeons")
    return dungeons
end

-- Hide the dropdown menu and reset its visual state
function TTDungeon.HideDropdownMenu()
    if TTDungeon.dropdownMenu then
        TTDungeon.dropdownMenu:SetHidden(true)
        TTDungeon.dropdownOpen = false
        
        -- Reset dropdown arrow to down position
        if TTDungeon.dropdownArrow then
            TTDungeon.dropdownArrow:SetTexture("/esoui/art/buttons/scrollbar_downarrow_up.dds")
            TTDungeon.dropdownArrow:SetColor(0.8, 0.8, 0.8, 1)
        end
        
        -- Reset button border color
        if TTDungeon.dungeonSelectorButton then
            local bg = TTDungeon.dungeonSelectorButton:GetNamedChild("BG")
            if bg then
                bg:SetEdgeColor(0.5, 0.5, 0.5, 1)
            end
        end
        
        -- Reset scroll position to top
        if TTDungeon.dropdownScroll then
            TTDungeon.dropdownScroll.offsetY = 0
            TTDungeon.ClampDropdownScrollOffset(TTDungeon.dropdownScroll)
        end
        
        -- Reset scrollbar position
        if TTDungeon.dropdownScrollBar then
            TTDungeon.dropdownScrollBar:ClearAnchors()
            TTDungeon.dropdownScrollBar:SetAnchor(TOPRIGHT, TTDungeon.dropdownMenu, TOPRIGHT, -3, 10)
        end
    end
end

-- Show or hide the dungeon selector dropdown menu
-- Does not show if player is currently in a dungeon
function TTDungeon.ShowDungeonSelector()
    Debug("ShowDungeonSelector called")
    if not TTDungeon.dungeonSelectorButton then 
        Debug("No dungeonSelectorButton found!")
        return 
    end
    
    -- Check if player is currently in a dungeon
    local zoneIndex = GetUnitZoneIndex("player")
    if zoneIndex and zoneIndex > 0 then
        local currentZoneId = GetZoneId(zoneIndex)
        if currentZoneId > 0 then
            -- Don't show dropdown if in a recognized dungeon
            if (TTDungeon.BaseDungeonInfo and TTDungeon.BaseDungeonInfo[currentZoneId]) or
               (TTDungeon.DLCDungeonInfo and TTDungeon.DLCDungeonInfo[currentZoneId]) then
                Debug("In dungeon - not showing dropdown")
                return
            end
        end
    end
    
    -- Toggle dropdown visibility
    if TTDungeon.dropdownOpen then
        Debug("Dropdown is open - closing it")
        TTDungeon.HideDropdownMenu()
        return
    end
    
    -- Create dropdown menu if it doesn't exist
    if not TTDungeon.dropdownMenu then
        Debug("Creating dropdown menu")
        TTDungeon.CreateDropdownMenu()
    end
    
    -- Populate and show dropdown
    Debug("Populating dropdown menu")
    TTDungeon.PopulateDropdownMenu()
    
    -- Position dropdown below selector button
    TTDungeon.dropdownMenu:ClearAnchors()
    TTDungeon.dropdownMenu:SetAnchor(TOPLEFT, TTDungeon.dungeonSelectorButton, BOTTOMLEFT, 5, -1)
    TTDungeon.dropdownMenu:SetHidden(false)
    TTDungeon.dropdownOpen = true
    Debug("Dropdown should now be visible")
    
    -- Update visual state to show dropdown is open
    if TTDungeon.dropdownArrow then
        TTDungeon.dropdownArrow:SetTexture("/esoui/art/buttons/scrollbar_uparrow_up.dds")
        TTDungeon.dropdownArrow:SetColor(1, 1, 1, 1)
    end
    local bg = TTDungeon.dungeonSelectorButton:GetNamedChild("BG")
    if bg then
        bg:SetEdgeColor(1, 0.8, 0, 1)  -- Golden border when open
    end
end

-- Create the dropdown menu control with scrollable content
function TTDungeon.CreateDropdownMenu()
    Debug("CreateDropdownMenu called")
    local MAX_VISIBLE_ITEMS = 10  -- Maximum items visible without scrolling
    local ITEM_HEIGHT = 25        -- Height of each dropdown item
    
    -- Main dropdown container
    local dropdown = CreateControl("TTDungeon_DropdownMenu", GuiRoot, CT_TOPLEVELCONTROL)
    dropdown:SetDimensions(TTDungeon.dungeonSelectorButton:GetWidth() - 10, MAX_VISIBLE_ITEMS * ITEM_HEIGHT + 10)
    dropdown:SetClampedToScreen(true)
    dropdown:SetMouseEnabled(true)
    dropdown:SetHidden(true)
    dropdown:SetDrawLayer(DL_OVERLAY)
    dropdown:SetDrawLevel(100)
    dropdown:SetTopmost(true)
    
    -- Dropdown background
    local bg = CreateControl(nil, dropdown, CT_BACKDROP)
    bg:SetAnchorFill(dropdown)
    bg:SetCenterColor(0.05, 0.05, 0.05, 0.95)
    bg:SetEdgeTexture("EsoUI/Art/Tooltips/UI-Border.dds", 128, 16, 4)
    bg:SetEdgeColor(0.7, 0.7, 0.7, 1)
    
    -- Scroll container for dropdown items
    local scroll = CreateControl(nil, dropdown, CT_SCROLL)
    scroll:SetAnchor(TOPLEFT, dropdown, TOPLEFT, 5, 5)
    scroll:SetDimensions(dropdown:GetWidth() - 10, dropdown:GetHeight() - 10)
    scroll:SetMouseEnabled(true)
    scroll.offsetY = 0
    
    -- Visual scrollbar indicator
    local scrollBar = CreateControl(nil, dropdown, CT_TEXTURE)
    scrollBar:SetDimensions(3, 50)
    scrollBar:SetAnchor(TOPRIGHT, dropdown, TOPRIGHT, -3, 10)
    scrollBar:SetTexture("/esoui/art/miscellaneous/scrollbox_elevator.dds")
    scrollBar:SetColor(0.6, 0.6, 0.6, 0.7)
    scrollBar:SetHidden(true)  -- Hidden by default, shown when content is scrollable
    TTDungeon.dropdownScrollBar = scrollBar
    
    -- Mouse wheel scroll handler
    scroll:SetHandler("OnMouseWheel", function(self, delta)
        Debug("Dropdown scroll: " .. tostring(delta))
        local step = ITEM_HEIGHT
        -- Apply scroll direction preference
        if TTDungeon.savedVars.invertScroll then
            self.offsetY = self.offsetY + (delta * step)
        else
            self.offsetY = self.offsetY - (delta * step)
        end
        TTDungeon.ClampDropdownScrollOffset(self)
        
        -- Update scrollbar position based on scroll percentage
        if TTDungeon.dropdownScrollBar and not TTDungeon.dropdownScrollBar:IsHidden() then
            local scrollPercent = 0
            if self.scrollChild then
                local maxOffset = self.scrollChild:GetHeight() - self:GetHeight()
                if maxOffset > 0 then
                    scrollPercent = math.abs(self.offsetY) / maxOffset
                end
            end
            local scrollRange = dropdown:GetHeight() - 20 - scrollBar:GetHeight()
            local scrollTop = 10 + (scrollRange * scrollPercent)
            scrollBar:ClearAnchors()
            scrollBar:SetAnchor(TOPRIGHT, dropdown, TOPRIGHT, -3, scrollTop)
        end
    end)
    
    -- Scroll child to contain all dropdown items
    local scrollChild = CreateControl(nil, scroll, CT_CONTROL)
    scrollChild:SetAnchor(TOPLEFT, scroll, TOPLEFT, 0, 0)
    scrollChild:SetWidth(scroll:GetWidth())
    scroll.scrollChild = scrollChild
    
    -- Store references
    TTDungeon.dropdownMenu = dropdown
    TTDungeon.dropdownScroll = scroll
    TTDungeon.dropdownScrollChild = scrollChild
    
    Debug("Dropdown menu created successfully")
    
    -- Register global mouse click to close dropdown when clicking outside
    local function OnGlobalMouseDown(eventCode, button)
        if button == MOUSE_BUTTON_INDEX_LEFT and TTDungeon.dropdownOpen then
            local mouseX, mouseY = GetUIMousePosition()
            local left, top, right, bottom = dropdown:GetScreenRect()
            local buttonLeft, buttonTop, buttonRight, buttonBottom = TTDungeon.dungeonSelectorButton:GetScreenRect()
            
            -- Check if click is outside both dropdown and selector button
            if not (mouseX >= left and mouseX <= right and mouseY >= top and mouseY <= bottom) and
               not (mouseX >= buttonLeft and mouseX <= buttonRight and mouseY >= buttonTop and mouseY <= buttonBottom) then
                TTDungeon.HideDropdownMenu()
            end
        end
    end
    
    EVENT_MANAGER:RegisterForEvent("TTDungeon_DropdownClick", EVENT_GLOBAL_MOUSE_DOWN, OnGlobalMouseDown)
end

-- Clamp the scroll offset to ensure content stays within bounds
function TTDungeon.ClampDropdownScrollOffset(scrollControl)
    if not scrollControl or not scrollControl.scrollChild then return end
    local scChild = scrollControl.scrollChild
    local cH = scrollControl:GetHeight()      -- Container height
    local sH = scChild:GetHeight()           -- Content height
    
    if sH <= cH then
        -- Content fits in container, no scroll needed
        scrollControl.offsetY = 0
    else
        -- Clamp scroll to valid range
        local minOffset = -(sH - cH)
        if scrollControl.offsetY > 0 then
            scrollControl.offsetY = 0
        elseif scrollControl.offsetY < minOffset then
            scrollControl.offsetY = minOffset
        end
    end
    
    -- Apply scroll offset
    scChild:ClearAnchors()
    scChild:SetAnchor(TOPLEFT, scrollControl, TOPLEFT, 0, scrollControl.offsetY)
end

-- Populate dropdown menu with all available dungeons
-- Daily pledge dungeons are highlighted in gold
function TTDungeon.PopulateDropdownMenu()
    Debug("PopulateDropdownMenu called")
    local scrollChild = TTDungeon.dropdownScrollChild
    if not scrollChild then 
        Debug("No scrollChild found!")
        return 
    end
    
    -- Clear existing dropdown items
    for i = scrollChild:GetNumChildren() - 1, 0, -1 do
        local child = scrollChild:GetChild(i)
        if child then
            child:SetHidden(true)
            child:SetParent(nil)
        end
    end
    
    local ITEM_HEIGHT = 25
    local offsetY = 0
    local dungeons = TTDungeon.GetAllDungeons()
    Debug("Found " .. #dungeons .. " dungeons")
    
    -- Create a dropdown item for a dungeon
    local function CreateDropdownItem(text, dungeonData)
        local item = CreateControl(nil, scrollChild, CT_BUTTON)
        item:SetDimensions(scrollChild:GetWidth(), ITEM_HEIGHT)
        item:SetAnchor(TOPLEFT, scrollChild, TOPLEFT, 0, offsetY)
        item:SetMouseEnabled(true)
        item:SetFont("ZoFontGame")
        item:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
        
        -- Hover background
        local itemBg = CreateControl(nil, item, CT_BACKDROP)
        itemBg:SetAnchorFill(item)
        itemBg:SetCenterColor(0, 0, 0, 0)
        itemBg:SetEdgeColor(0, 0, 0, 0)
        item.bg = itemBg
        
        -- Check if this dungeon is a daily pledge
        local isPledge = false
        if dungeonData and dungeonData.data then
            isPledge = TTDungeon.IsDailyPledge(dungeonData.data)
        end
        
        -- Set text color based on pledge status and selection
        if isPledge then
            item:SetNormalFontColor(1, 0.84, 0, 1) -- Gold for pledges
            if dungeonData and TTDungeon.selectedDungeonId == dungeonData.zoneId then
                itemBg:SetCenterColor(0.3, 0.25, 0, 0.4)  -- Selected pledge background
                item:SetNormalFontColor(1, 1, 0.2, 1)      -- Brighter gold
            end
        else
            if dungeonData and TTDungeon.selectedDungeonId == dungeonData.zoneId then
                item:SetNormalFontColor(1, 0.8, 0, 1)      -- Selected non-pledge
                itemBg:SetCenterColor(0.2, 0.15, 0, 0.3)
            else
                item:SetNormalFontColor(0.8, 0.8, 0.8, 1) -- Normal text
            end
        end
        
        -- Add pledge icon for daily pledges
        if isPledge then
            local pledgeIcon = CreateControl(nil, item, CT_TEXTURE)
            pledgeIcon:SetDimensions(16, 16)
            pledgeIcon:SetAnchor(LEFT, item, LEFT, 2, 0)
            pledgeIcon:SetTexture("esoui/art/icons/quest_key_001.dds")
            item:SetText("      " .. text)  -- Extra spacing for icon
        else
            item:SetText("  " .. text)
        end
        
        -- Mouse hover handlers
        item:SetHandler("OnMouseEnter", function()
            if isPledge then
                if TTDungeon.selectedDungeonId ~= dungeonData.zoneId then
                    item:SetNormalFontColor(1, 1, 0.5, 1)
                    itemBg:SetCenterColor(0.3, 0.25, 0, 0.5)
                end
            else
                if TTDungeon.selectedDungeonId ~= dungeonData.zoneId then
                    item:SetNormalFontColor(1, 1, 1, 1)
                    itemBg:SetCenterColor(0.2, 0.2, 0.2, 0.5)
                end
            end
        end)
        
        item:SetHandler("OnMouseExit", function()
            if isPledge then
                if TTDungeon.selectedDungeonId == dungeonData.zoneId then
                    item:SetNormalFontColor(1, 1, 0.2, 1)
                    itemBg:SetCenterColor(0.3, 0.25, 0, 0.4)
                else
                    item:SetNormalFontColor(1, 0.84, 0, 1)
                    itemBg:SetCenterColor(0, 0, 0, 0)
                end
            else
                if TTDungeon.selectedDungeonId == dungeonData.zoneId then
                    item:SetNormalFontColor(1, 0.8, 0, 1)
                    itemBg:SetCenterColor(0.2, 0.15, 0, 0.3)
                else
                    item:SetNormalFontColor(0.8, 0.8, 0.8, 1)
                    itemBg:SetCenterColor(0, 0, 0, 0)
                end
            end
        end)
        
        -- Click handler - select dungeon
        item:SetHandler("OnClicked", function()
            Debug("Dungeon selected: " .. dungeonData.name)
            TTDungeon.manualDungeonMode = true
            TTDungeon.selectedDungeonId = dungeonData.zoneId
            
            TTDungeon.UpdateDungeonSelector()
            TTDungeon.UpdateUIContent()
            TTDungeon.HideDropdownMenu()
            
            -- Auto-expand UI if minimized
            if TTDungeon.isMinimized then
                TTDungeon.wasManuallyMinimized = false
                TTDungeon.ToggleMinimized()
            end
        end)
        
        offsetY = offsetY + ITEM_HEIGHT
    end
    
    -- Create dropdown items for all dungeons
    for _, dungeon in ipairs(dungeons) do
        local displayName = dungeon.name
        if not dungeon.isBase then
            displayName = displayName .. " (DLC)"
        end
        CreateDropdownItem(displayName, dungeon)
    end
    
    -- Set scroll child height based on content
    scrollChild:SetHeight(offsetY)
    TTDungeon.ClampDropdownScrollOffset(TTDungeon.dropdownScroll)
    
    -- Show/hide scrollbar based on content height
    if TTDungeon.dropdownScrollBar then
        if offsetY > TTDungeon.dropdownScroll:GetHeight() then
            TTDungeon.dropdownScrollBar:SetHidden(false)
        else
            TTDungeon.dropdownScrollBar:SetHidden(true)
        end
    end
    
    Debug("Dropdown populated with " .. offsetY/ITEM_HEIGHT .. " items")
end

-- Update the dungeon selector button text
-- Shows selected dungeon name or placeholder text
function TTDungeon.UpdateDungeonSelector()
    if not TTDungeon.dungeonSelectorButton then return end
    
    -- Set default placeholder text based on language
    local text = TTDungeon.savedVars.language == "de" and "  Verlies wählen..." or "  Select Dungeon..."
    
    -- If a dungeon is selected, show its name
    if TTDungeon.selectedDungeonId then
        local dungeons = TTDungeon.GetAllDungeons()
        for _, dungeon in ipairs(dungeons) do
            if dungeon.zoneId == TTDungeon.selectedDungeonId then
                text = "  " .. dungeon.name
                break
            end
        end
    end
    
    TTDungeon.dungeonSelectorButton:SetText(text)
    
    -- Update dropdown menu width to match button
    if TTDungeon.dropdownMenu then
        TTDungeon.dropdownMenu:SetWidth(TTDungeon.dungeonSelectorButton:GetWidth() - 10)
        if TTDungeon.dropdownScroll and TTDungeon.dropdownScrollChild then
            TTDungeon.dropdownScroll:SetWidth(TTDungeon.dropdownMenu:GetWidth() - 10)
            TTDungeon.dropdownScrollChild:SetWidth(TTDungeon.dropdownScroll:GetWidth())
        end
    end
end

-- Reset manual dungeon selection and return to auto-detection mode
function TTDungeon.ResetManualDungeonSelection()
    TTDungeon.manualDungeonMode = false
    TTDungeon.selectedDungeonId = nil
    
    -- Reset selector button text
    if TTDungeon.dungeonSelectorButton then
        local text = TTDungeon.savedVars.language == "de" and "  Verlies wählen..." or "  Select Dungeon..."
        TTDungeon.dungeonSelectorButton:SetText(text)
    end
    
    -- Close dropdown if open
    if TTDungeon.dropdownOpen then
        TTDungeon.HideDropdownMenu()
    end
    
    Debug("Manual dungeon selection reset")
end

-- Handle UI lock state - enable/disable moving the window
function TTDungeon.HandleLockUI(lockValue)
    if not TTDungeon.uiControl then return end
    TTDungeon.uiControl:SetMouseEnabled(not lockValue)
    TTDungeon.uiControl:SetMovable(not lockValue)
end

-- Update UI scale
function TTDungeon.UpdateScale(scaleValue)
    if TTDungeon.uiControl then
        TTDungeon.uiControl:SetScale(scaleValue)
    end
end

-- Clamp scroll offset for content containers
-- Ensures scroll position stays within valid bounds
function TTDungeon.ClampScrollOffset(scrollContainer)
    local sc = scrollContainer.scrollChild
    if not sc then return end
    local containerH = scrollContainer:GetHeight()
    local childH     = sc:GetHeight()
    
    if childH <= containerH then
        -- Content fits in container
        scrollContainer.offsetY = 0
    else
        -- Calculate valid scroll range
        local minOffset = -(childH - containerH)
        if scrollContainer.offsetY > 0 then
            scrollContainer.offsetY = 0
        elseif scrollContainer.offsetY < minOffset then
            scrollContainer.offsetY = minOffset
        end
    end
    
    -- Apply scroll offset
    sc:ClearAnchors()
    sc:SetAnchor(TOPLEFT, scrollContainer, TOPLEFT, 0, scrollContainer.offsetY)
end

-- Calculate daily pledges based on known cycles
-- Three pledge givers each have their own rotation cycle
function TTDungeon.CalculateDailyPledges()
    -- Pledge cycle 1 - Maj al-Ragath (Undaunted Enclave)
    local cycle1 = {
        2, 300, 5, 303, 6, 316, 4, 18, 3, 308, 7, 22
    }

    -- Pledge cycle 2 - Glirion the Redbeard (Undaunted Enclave)
    local cycle2 = {
        16, 322, 9, 12, 14, 11, 17, 317, 10, 13, 15, 8
    }

    -- Pledge cycle 3 - Urgarlag Chief-bane (DLC dungeons)
    local cycle3 = {
        289, 293, 288, 295, 324, 368, 420, 418, 426, 428, 435, 433,
        494, 496, 503, 505, 507, 509, 591, 593, 595, 597, 599, 601,
        608, 610, 613, 615, 638, 640, 642, 644
    }

    -- Reference point: March 27, 2025, 12:00 UTC
    local startTime = 1743080400
    local startIndices = {11, 11, 15}  -- Starting positions in each cycle

    -- Calculate days since reference point
    local nextUpdateTime = GetTimeStamp() + GetTimeUntilNextDailyLoginRewardClaimS()
    local days = math.floor((nextUpdateTime - startTime) / 86400)

    -- Calculate current index in cycle
    local function getCycleIndex(startIdx, elapsedDays, cycleLength)
        local rawIndex = startIdx + elapsedDays
        local idx = (rawIndex - 1) % cycleLength + 1
        return idx
    end

    -- Reset and populate daily pledges
    TTDungeon.dailyPledges = {}
    table.insert(TTDungeon.dailyPledges, cycle1[getCycleIndex(startIndices[1], days, #cycle1)])
    table.insert(TTDungeon.dailyPledges, cycle2[getCycleIndex(startIndices[2], days, #cycle2)])
    table.insert(TTDungeon.dailyPledges, cycle3[getCycleIndex(startIndices[3], days, #cycle3)])
end

-- Check if a dungeon is one of today's daily pledges
function TTDungeon.IsDailyPledge(data)
    if not data then return false end

    local normalId = tonumber(data.normalId) or 0

    -- Check against calculated daily pledges
    for _, pledgeId in ipairs(TTDungeon.dailyPledges) do
        local numericPledgeId = tonumber(pledgeId) or 0
        if normalId == numericPledgeId then
            return true
        end
    end

    return false
end

-- Get quest status for a dungeon
-- Returns: -1 (completed), 0 (available), 1 (active)
function TTDungeon.GetDungeonQuestStatus(questIdToCheck)
    if not questIdToCheck or questIdToCheck <= 0 then
        return 0
    end

    -- Ensure required API functions exist
    if not GetQuestName or not GetNumJournalQuests or not GetJournalQuestName then
        Debug("Required API functions missing!")
        return 0
    end

    -- Check if quest is completed
    local _, questStatus
    local success = pcall(function() _, questStatus = GetCompletedQuestInfo(questIdToCheck) end)

    if success and questStatus == 5 then
        return -1  -- Quest completed
    end

    -- Get quest name for comparison
    local questName = ""
    success = pcall(function() questName = GetQuestName(questIdToCheck) end)

    if not success or not questName or questName == "" then
        return 0
    end

    -- Search active quests in journal
    local numQuests = 0
    success = pcall(function() numQuests = GetNumJournalQuests() end)

    if not success or numQuests == 0 then
        return 0
    end

    -- Check each active quest
    for i = 1, numQuests do
        local journalQuestName = ""
        success = pcall(function() journalQuestName = GetJournalQuestName(i) end)

        if success and journalQuestName == questName then
            return 1  -- Quest is active
        end
    end

    return 0  -- Quest is available but not active
end

-- Check if a dungeon quest is currently active
function TTDungeon.IsDungeonQuestActive(questIdToCheck)
    local status = TTDungeon.GetDungeonQuestStatus(questIdToCheck)
    return (status == 1)
end

-- Get current dungeon data based on zone or manual selection
-- Returns: data (table), isVet (boolean), zoneId (number)
function TTDungeon.GetCurrentDungeonData()
    -- Check current player zone
    local zoneIndex = GetUnitZoneIndex("player")
    local currentZoneId = 0
    local isVet = false
    
    if zoneIndex and zoneIndex > 0 then
        currentZoneId = GetZoneId(zoneIndex)
        isVet = IsUnitUsingVeteranDifficulty("player")
    end
    
    -- Check if player is in a recognized dungeon
    local inDungeon = false
    if currentZoneId > 0 then
        if TTDungeon.BaseDungeonInfo and TTDungeon.BaseDungeonInfo[currentZoneId] then
            inDungeon = true
        elseif TTDungeon.DLCDungeonInfo and TTDungeon.DLCDungeonInfo[currentZoneId] then
            inDungeon = true
        end
    end
    
    -- Return current dungeon data if in one
    if inDungeon then
        local data = nil
        if TTDungeon.BaseDungeonInfo and TTDungeon.BaseDungeonInfo[currentZoneId] then
            data = TTDungeon.BaseDungeonInfo[currentZoneId]
        elseif TTDungeon.DLCDungeonInfo and TTDungeon.DLCDungeonInfo[currentZoneId] then
            data = TTDungeon.DLCDungeonInfo[currentZoneId]
        end
        return data, isVet, currentZoneId
    end
    
    -- Check manual selection if not in dungeon
    if TTDungeon.manualDungeonMode and TTDungeon.selectedDungeonId then
        if TTDungeon.BaseDungeonInfo and TTDungeon.BaseDungeonInfo[TTDungeon.selectedDungeonId] then
            return TTDungeon.BaseDungeonInfo[TTDungeon.selectedDungeonId], false, TTDungeon.selectedDungeonId
        end
        
        if TTDungeon.DLCDungeonInfo and TTDungeon.DLCDungeonInfo[TTDungeon.selectedDungeonId] then
            return TTDungeon.DLCDungeonInfo[TTDungeon.selectedDungeonId], false, TTDungeon.selectedDungeonId
        end
    end
    
    return nil, false, 0
end

-- Hide all boss detail windows
function TTDungeon.HideAllBossDetailWindows()
    if TTDungeon.HideBossDetailWindows then
        TTDungeon.HideBossDetailWindows()
    end
end

-- Update UI visibility based on display mode and current state
function TTDungeon.UpdateUIVisibility()
    local sv = TTDungeon.savedVars
    if not TTDungeon.uiFragment or not sv then return end

    local data, _, _ = TTDungeon.GetCurrentDungeonData()
    local recognizedDungeon = (data ~= nil)

    -- Determine if UI should be visible
    local wantVisible = false
    if sv.displayMode == "Always" then
        wantVisible = true
    elseif sv.displayMode == "OnlyInDungeon" then
        wantVisible = recognizedDungeon or TTDungeon.manualDungeonMode
    else -- Manual mode
        wantVisible = not sv.isUIHidden
    end

    -- Get required scenes
    local hudScene   = SCENE_MANAGER:GetScene("hud")
    local huduiScene = SCENE_MANAGER:GetScene("hudui")

    if not hudScene or not huduiScene then
        Debug("Error: HUD or HUDUI scene not found.")
        return
    end

    -- Add or remove fragment from scenes
    if wantVisible then
        if not hudScene:HasFragment(TTDungeon.uiFragment) then hudScene:AddFragment(TTDungeon.uiFragment) end
        if not huduiScene:HasFragment(TTDungeon.uiFragment) then huduiScene:AddFragment(TTDungeon.uiFragment) end
        if TTDungeon.uiControl then TTDungeon.uiControl:SetHidden(false) end
    else
        if hudScene:HasFragment(TTDungeon.uiFragment) then hudScene:RemoveFragment(TTDungeon.uiFragment) end
        if huduiScene:HasFragment(TTDungeon.uiFragment) then huduiScene:RemoveFragment(TTDungeon.uiFragment) end
        TTDungeon.HideAllBossDetailWindows()
        if TTDungeon.uiControl then TTDungeon.uiControl:SetHidden(true) end
    end
end

-- Update UI content with current dungeon information
function TTDungeon.UpdateUIContent()
    if not TTDungeon.dungeonLabel then
        return
    end

    local data, isVet, zoneId = TTDungeon.GetCurrentDungeonData()
    
    -- Check if player is in a dungeon
    local inDungeon = false
    local zoneIndex = GetUnitZoneIndex("player")
    if zoneIndex and zoneIndex > 0 then
        local currentZoneId = GetZoneId(zoneIndex)
        if currentZoneId > 0 then
            if (TTDungeon.BaseDungeonInfo and TTDungeon.BaseDungeonInfo[currentZoneId]) or
               (TTDungeon.DLCDungeonInfo and TTDungeon.DLCDungeonInfo[currentZoneId]) then
                inDungeon = true
            end
        end
    end
    
    -- Toggle between dropdown and label based on dungeon status
    if inDungeon then
        -- Hide dropdown, show label when in dungeon
        if TTDungeon.dungeonSelectorButton then
            TTDungeon.dungeonSelectorButton:SetHidden(true)
        end
        TTDungeon.dungeonLabel:SetHidden(false)
        
        -- Close dropdown if open
        if TTDungeon.dropdownOpen then
            TTDungeon.HideDropdownMenu()
        end
    else
        -- Show dropdown, hide label when not in dungeon
        if TTDungeon.dungeonSelectorButton then
            TTDungeon.dungeonSelectorButton:SetHidden(false)
            TTDungeon.UpdateDungeonSelector()
        end
        TTDungeon.dungeonLabel:SetHidden(true)
    end
    
    if data then
        -- Update dungeon info label when in dungeon
        if inDungeon then
            local dungeonName = data.name or (TTDungeon.savedVars.language == "de" and "Unbekanntes Verlies" or "Unknown Dungeon")
            local diffColor = isVet and "|c800080" or "|c0000FF"  -- Purple for vet, blue for normal
            local difficultyText = isVet and "Veteran" or "Normal"

            -- Daily pledge icon
            local pledgeIcon = ""
            if TTDungeon.IsDailyPledge(data) then
                pledgeIcon = "|t20:20:esoui/art/icons/quest_key_001.dds|t "
            end

            -- Quest status icon
            local questIcon = ""
            if data.questID and data.questID > 0 then
                local questStatus = TTDungeon.GetDungeonQuestStatus(data.questID)
                if questStatus == 0 then
                    questIcon = "|cFF0000(!)|r "  -- Red for available quest
                elseif questStatus == 1 then
                    questIcon = "|cFFFF00(!)|r "  -- Yellow for active quest
                end
            end

            -- Format complete dungeon label
            TTDungeon.dungeonLabel:SetText(
                string.format("%s%s%s (%s%s|r)", questIcon, pledgeIcon, dungeonName, diffColor, difficultyText)
            )
        end
        
        -- Update header height
        if TTDungeon.UpdateHeaderHeight then
            TTDungeon.UpdateHeaderHeight()
        end

        -- Enable minimize button
        TTDungeon.minimizeButton:SetMouseEnabled(true)
        TTDungeon.minimizeButton:SetEnabled(true)

        -- Auto-expand if entering dungeon (unless manually minimized)
        if TTDungeon.isMinimized and not TTDungeon.wasManuallyMinimized and inDungeon then
            TTDungeon.ToggleMinimized()
        end

        -- Clear manual selection when entering dungeon
        if inDungeon then
            TTDungeon.ResetManualDungeonSelection()
        end

        -- Populate tab content
        if TTDungeon.PopulateSetsTab then
            if data.sets and #data.sets > 0 then 
                TTDungeon.PopulateSetsTab(data.sets)
            else 
                if TTDungeon.ClearSetsTab then TTDungeon.ClearSetsTab() end 
            end
        end
        if TTDungeon.UpdateAchievements then 
            TTDungeon.UpdateAchievements(data) 
        end
        if TTDungeon.PopulateEncounters then 
            TTDungeon.PopulateEncounters(data, zoneId) 
        end

    else
        -- No dungeon data available
        if TTDungeon.ClearSetsTab then TTDungeon.ClearSetsTab() end
        if TTDungeon.UpdateAchievements then TTDungeon.UpdateAchievements(nil) end
        if TTDungeon.PopulateEncounters then TTDungeon.PopulateEncounters(nil, nil) end

        -- Auto-minimize when leaving dungeon (unless manually selected)
        if not TTDungeon.isMinimized and not TTDungeon.manualDungeonMode then
            TTDungeon.wasManuallyMinimized = false
            TTDungeon.ToggleMinimized()
        end
        TTDungeon.minimizeButton:SetMouseEnabled(true)
        TTDungeon.minimizeButton:SetEnabled(true)
        TTDungeon.HideAllBossDetailWindows()
    end

    -- Show encounters tab when expanded with data
    if not TTDungeon.isMinimized and data then
        TTDungeon.ShowTab("enc")
    end
end

-- Show specified tab and hide others
function TTDungeon.ShowTab(tabKey)
    if not TTDungeon.encountersContainer or not TTDungeon.setsContainer or not TTDungeon.achContainer or not TTDungeon.tabs then
        Debug("Error: UI containers or tabs not initialized.")
        return
    end

    -- Hide all content containers
    TTDungeon.encountersContainer:SetHidden(true)
    TTDungeon.setsContainer:SetHidden(true)
    TTDungeon.achContainer:SetHidden(true)

    -- Reset all tab buttons to normal state
    for _, tabBtn in ipairs(TTDungeon.allTabs or {}) do
        if tabBtn then
            tabBtn:SetState(BSTATE_NORMAL, false)
            if tabBtn.label then tabBtn.label:SetColor(1,1,1,1) end
            if tabBtn.bg then 
                tabBtn.bg:SetCenterColor(0,0,0,0) 
                tabBtn.bg:SetEdgeColor(0,0,0,0) 
            end
        end
    end

    -- Show selected tab content and highlight button
    if tabKey == "enc" then 
        TTDungeon.encountersContainer:SetHidden(false) 
        TTDungeon.HighlightTab(TTDungeon.tabs.encBtn)
    elseif tabKey == "sets" then 
        TTDungeon.setsContainer:SetHidden(false) 
        TTDungeon.HighlightTab(TTDungeon.tabs.setBtn)
    elseif tabKey == "ach" then 
        TTDungeon.achContainer:SetHidden(false) 
        TTDungeon.HighlightTab(TTDungeon.tabs.achBtn)
    end
end

-- Highlight the active tab button
function TTDungeon.HighlightTab(tabBtn)
    if not tabBtn then return end
    tabBtn:SetState(BSTATE_PRESSED, true)
    if tabBtn.label then tabBtn.label:SetColor(1,0.8,0.2,1) end  -- Golden text
    if tabBtn.bg then 
        tabBtn.bg:SetCenterColor(0.3,0.3,0.3,0.3) 
        tabBtn.bg:SetEdgeColor(0.5,0.5,0.5,0.5) 
    end
end

-- Toggle UI visibility (for keybind/slash command)
function TTDungeon.ToggleUI()
    local sv = TTDungeon.savedVars
    if sv then
        if sv.displayMode == "Manual" then
            -- In manual mode, toggle saved visibility state
            sv.isUIHidden = not sv.isUIHidden
        else
            -- In other modes, temporarily toggle visibility
            local currentState = TTDungeon.uiControl and not TTDungeon.uiControl:IsHidden()
            sv.isUIHidden = currentState
        end
        TTDungeon.UpdateUIVisibility()
    end
end

-- Placeholder functions (implemented in other files)
function TTDungeon.PopulateSetsTab(setsData) end
function TTDungeon.ClearSetsTab() end
function TTDungeon.UpdateAchievements(dungeonData) end
function TTDungeon.PopulateEncounters(data, zoneId) end
function TTDungeon.CreateBossDetailUI() end
function TTDungeon.HideBossDetailWindows() end

-- Toggle between minimized and expanded state
function TTDungeon.ToggleMinimized()
    if not TTDungeon.uiControl or not TTDungeon.minimizeButton then return end
    local ui = TTDungeon.uiControl
    local sv = TTDungeon.savedVars
    if not sv then return end

    if TTDungeon.isMinimized then
        -- Expand the UI
        ui:ClearAnchors()
        ui:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, sv.offsetX, sv.offsetY)
        ui:SetHeight(sv.expandedHeight)
        if TTDungeon.contentPanel then
            if TTDungeon.UpdateHeaderHeight then
                TTDungeon.UpdateHeaderHeight()
            end
            TTDungeon.contentPanel:SetHidden(false)
        end
        TTDungeon.minimizeButton:SetText("-")
        TTDungeon.isMinimized = false
        TTDungeon.ShowTab("enc")  -- Show encounters tab by default
    else
        -- Minimize the UI
        ui:ClearAnchors()
        ui:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, sv.offsetX, sv.offsetY)
        ui:SetHeight(sv.minimizedHeight)
        if TTDungeon.contentPanel then
            TTDungeon.contentPanel:SetHeight(0)
            TTDungeon.contentPanel:SetHidden(true)
        end
        TTDungeon.minimizeButton:SetText("+")
        TTDungeon.isMinimized = true
    end
end

-- Handle zone changes and player activation
function TTDungeon.OnZoneOrActivation()
    -- Ensure player is fully loaded
    if not IsPlayerActivated() then
        zo_callLater(TTDungeon.OnZoneOrActivation, 500)
        return
    end

    -- Update UI after short delay to ensure zone data is loaded
    zo_callLater(function()
        TTDungeon.SetLanguageData()
        TTDungeon.UpdateUIVisibility()
        TTDungeon.UpdateUIContent()
    end, 100)
end

-- Initialize addon on load
local function OnAddOnLoaded(event, addonName)
    if addonName ~= TTDungeon.name then return end
    EVENT_MANAGER:UnregisterForEvent(TTDungeon.name, EVENT_ADD_ON_LOADED)

    -- Load saved variables
    TTDungeon.savedVars = ZO_SavedVars:NewAccountWide("TTDungeonSavedVars", 1, nil, defaultSavedVars)
    Debug("SavedVars loaded. Language=" .. tostring(TTDungeon.savedVars.language) .. ", displayMode=" .. tostring(TTDungeon.savedVars.displayMode))

    -- Reset manual selection on startup
    TTDungeon.manualDungeonMode = false
    TTDungeon.selectedDungeonId = nil
    Debug("Manual dungeon selection reset on startup")

    -- Initialize settings menu
    if TTDungeon.InitSettingsMenu then 
        TTDungeon:InitSettingsMenu()
    else 
        Debug("Fallback: No real settings menu defined.") 
        function TTDungeon:InitSettingsMenu() end 
        TTDungeon:InitSettingsMenu() 
    end

    -- Create main UI
    TTDungeon.CreateMainUI()
    
    -- Load language-specific data
    TTDungeon.SetLanguageData()

    -- Create boss detail UI windows
    if TTDungeon.CreateBossDetailUI then 
        TTDungeon.CreateBossDetailUI()
    else 
        Debug("TTDungeon.CreateBossDetailUI is missing => BOSS DETAIL WINDOWS WON'T WORK!") 
    end

    -- Apply initial settings
    TTDungeon.HandleLockUI(TTDungeon.savedVars.lockUI)
    TTDungeon.UpdateScale(TTDungeon.savedVars.uiScale)
    TTDungeon.CalculateDailyPledges()

    -- Register game events
    EVENT_MANAGER:RegisterForEvent(TTDungeon.name, EVENT_PLAYER_ACTIVATED, TTDungeon.OnZoneOrActivation)
    EVENT_MANAGER:RegisterForEvent(TTDungeon.name, EVENT_ZONE_UPDATE, TTDungeon.OnZoneOrActivation)
    
    -- Daily pledges update
    EVENT_MANAGER:RegisterForEvent(TTDungeon.name, EVENT_DAILY_LOGIN_REWARD_UPDATE, function()
        Debug("Daily login reward updated -> recalculating pledges")
        TTDungeon.CalculateDailyPledges()
        TTDungeon.SetLanguageData()
        if TTDungeon.uiControl and not TTDungeon.uiControl:IsHidden() then
            TTDungeon.UpdateUIContent()
        end
    end)
    
    -- Quest tracking events
    EVENT_MANAGER:RegisterForEvent(TTDungeon.name, EVENT_QUEST_ADDED, function()
        Debug("Quest was added -> updating UI")
        zo_callLater(TTDungeon.UpdateUIContent, 100)
    end)

    EVENT_MANAGER:RegisterForEvent(TTDungeon.name, EVENT_QUEST_REMOVED, function()
        Debug("Quest was removed -> updating UI")
        zo_callLater(TTDungeon.UpdateUIContent, 100)
    end)

    EVENT_MANAGER:RegisterForEvent(TTDungeon.name, EVENT_QUEST_COMPLETE, function()
        Debug("Quest was completed -> updating UI")
        zo_callLater(TTDungeon.UpdateUIContent, 100)
    end)

    EVENT_MANAGER:RegisterForEvent(TTDungeon.name, EVENT_QUEST_ADVANCED, function()
        Debug("Quest has advanced -> updating UI")
        zo_callLater(TTDungeon.UpdateUIContent, 100)
    end)

    -- Register slash commands
    SLASH_COMMANDS["/ttd"]       = function() TTDungeon.ToggleUI() end
    SLASH_COMMANDS["/ttdungeon"] = function() TTDungeon.ToggleUI() end

    Debug("TTDungeon loaded. Version=" .. TTDungeon.version)
end

-- Register addon loaded event
EVENT_MANAGER:RegisterForEvent(TTDungeon.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)