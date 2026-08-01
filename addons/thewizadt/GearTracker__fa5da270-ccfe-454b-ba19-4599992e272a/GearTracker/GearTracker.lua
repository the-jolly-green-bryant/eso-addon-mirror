-- GearTracker v2.48 (Empty Search & Toggle Fix)
local ADDON = { name = "GearTracker" }

local SV, resultsWindow, scrollChild, questWindow, questLabel
local searchResults = {} 
local scrollOffset = 0
local activeFilterType = "ALL" 
local searchText = "" 

local TABLE_INSERT = table.insert
local STR_LOWER = string.lower
local STR_FIND = string.find

local MAX_DAILY_QUESTS = 100

-----------------------------------------------------------
-- 1. HELPERS, STYLE & QUEST RESET LOGIC
-----------------------------------------------------------
local function GetStickerStatus(link)
    if not link or link == "" then return "" end
    if not GetItemLinkSetCollectionId then return "" end
    local hasSet = GetItemLinkSetInfo(link, false)
    if not hasSet then return "" end

    local setId = GetItemLinkSetCollectionId(link)
    local slot = GetItemLinkSetCollectionSlot(link)
    if setId and setId > 0 and slot then
        if not IsItemSetCollectionSlotUnlocked(setId, slot) then
            return "|cFF00FF[NEW!]|r " 
        end
    end
    return ""
end

local function GetLiveWeightTag(item)
    if not item then return "" end
    if item.weight and item.weight ~= "" then 
        if item.weight == "L" or item.weight == "M" or item.weight == "H" or item.weight == "Shield" then
            return string.format("|cFF9900[%s]|r ", item.weight) 
        end
        return string.format("|c888888[%s]|r ", item.weight)
    end
    return ""
end

local function UpdateQuestMiniUI()
    if not questWindow or not questLabel or not SV then return end
    
    local completed = SV.dailyQuestsCompleted or 0
    local statusColor = "00FF00"
    if completed >= MAX_DAILY_QUESTS then statusColor = "FF2222"
    elseif completed >= 85 then statusColor = "FF9900"
    end

    local fontString = string.format("$(MEDIUM_FONT)|%d|soft-shadow-thin", SV.questFontSize or 20)
    questLabel:SetFont(fontString)
    questLabel:SetText(string.format("|cFFD700Daily Quests:|r |c%s%d|r/%d", statusColor, completed, MAX_DAILY_QUESTS))
end

local function MoveQuestWindow()
    if not questWindow or not SV then return end
    questWindow:ClearAnchors()
    questWindow:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, SV.questX or 400, SV.questY or 100)
    
    -- Toggle fix: Only show if enabled
    if SV.showQuestTrackerUI == false then
        questWindow:SetHidden(true)
    else
        questWindow:SetHidden(false)
    end
    
    UpdateQuestMiniUI()
end

local function CheckDailyReset()
    if not SV then return end
    local currentDay = math.floor(GetTimeStamp() / 86400)
    if SV.lastQuestResetDay ~= currentDay then
        SV.dailyQuestsCompleted = 0
        SV.lastQuestResetDay = currentDay
    end
    UpdateQuestMiniUI()
end

-----------------------------------------------------------
-- 2. UI LOGIC & FILTER ENGINE
-----------------------------------------------------------
local function MoveResultsWindow()
    if not resultsWindow or not SV then return end
    if resultsWindow.ClearAnchors then resultsWindow:ClearAnchors() end
    if resultsWindow.SetAnchor then resultsWindow:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, SV.posX, SV.posY) end
    
    local lineHeight = (SV.fontSize or 24) + 15
    -- FIXED: Use the colon operator (:) to correctly call the SetHeight method on the resultsWindow object
    if resultsWindow.SetHeight then resultsWindow:SetHeight((lineHeight * (SV.visibleCount + 1)) + 40) end
end

local function RefreshLabelSetup()
    if not resultsWindow then return end
    scrollChild = { controls = {} }
    for i = 1, (SV.visibleCount + 1) do
        local lblName = "GT_ItemLabel_" .. i
        local lbl = WINDOW_MANAGER:GetControlByName(lblName) or WINDOW_MANAGER:CreateControl(lblName, resultsWindow, CT_LABEL)
        if lbl.SetHidden then lbl:SetHidden(false) end
        if lbl.SetWidth then lbl:SetWidth(1100) end
        if lbl.SetWrapMode then lbl:SetWrapMode(TEXT_WRAP_MODE_WRAP) end 
        scrollChild.controls[i] = lbl
    end
end

local function UpdateResultsUI()
    if not resultsWindow or not scrollChild or not SV then return end
    
    local fontSize = SV.fontSize or 24
    local lineHeight = fontSize + 15 
    local fontString = string.format("$(MEDIUM_FONT)|%d|soft-shadow-thin", fontSize)

    for i, lbl in ipairs(scrollChild.controls) do
        if lbl.SetFont then lbl:SetFont(fontString) end
        if lbl.SetHeight then lbl:SetHeight(lineHeight) end
        if lbl.ClearAnchors then lbl:ClearAnchors() end
        if lbl.SetAnchor then lbl:SetAnchor(TOPLEFT, resultsWindow, TOPLEFT, 25, 20 + (i-1) * lineHeight) end
        
        if i == 1 then
            local header = string.format("|cFFFF00[FILTER: %s]|r", activeFilterType)
            if searchText ~= "" then header = header .. string.format(" |c00FFCC\"%s\"|r", searchText) end
            if lbl.SetText then lbl:SetText(string.format("%s (Found: %d) |c888888[Sync: %s]|r", header, #searchResults, SV.lastScan)) end
            lbl.itemLink = nil
        else
            local dataIndex = scrollOffset + (i - 1)
            local itemData = searchResults[dataIndex]
            
            if itemData then
                if lbl.SetText then lbl:SetText(itemData.text) end
                lbl.itemLink = itemData.link 
            else
                if lbl.SetText then lbl:SetText("") end
                lbl.itemLink = nil
            end
        end
    end
end

local function ApplyInventoryFilter()
    searchResults = {}
    scrollOffset = 0
    
    -- EMPTY STATE FIX: Clear window if nothing is searched
    if (searchText == "" or searchText == nil) and activeFilterType == "ALL" then
        UpdateResultsUI()
        return
    end
    
    if not SV or not SV.chars then return end
    local query = STR_LOWER(searchText)

    for char, data in pairs(SV.chars) do
        if type(data) == "table" then
            for _, loc in ipairs({"equipped", "bag"}) do
                local itemGroup = data[loc] or {}
                for _, item in ipairs(itemGroup) do
                    if activeFilterType == "ALL" or item.type == activeFilterType then
                        local nameMatch = (query == "") or STR_FIND(STR_LOWER(item.name or ""), query, 1, true) or STR_FIND(STR_LOWER(item.trait or ""), query, 1, true) or STR_FIND(STR_LOWER(char), query, 1, true)
                        if nameMatch then
                            local sticker = GetStickerStatus(item.link)
                            local weightTag = GetLiveWeightTag(item)
                            TABLE_INSERT(searchResults, {
                                link = item.link,
                                text = string.format("|cBBBBBB[%s]|r |c00CCFF%s|r: %s%s%s |c888888(%s)|r", char, loc:upper(), weightTag, sticker, item.link, item.trait)
                            })
                        end
                    end
                end
            end
        end
    end

    for _, item in ipairs(SV.bank or {}) do
        if activeFilterType == "ALL" or item.type == activeFilterType then
            local nameMatch = (query == "") or STR_FIND(STR_LOWER(item.name or ""), query, 1, true) or STR_FIND(STR_LOWER(item.trait or ""), query, 1, true)
            if nameMatch then
                local sticker = GetStickerStatus(item.link)
                local weightTag = GetLiveWeightTag(item)
                TABLE_INSERT(searchResults, {
                    link = item.link,
                    text = string.format("|cFFD700[BANK]|r %s%s%s |c888888(%s)|r", weightTag, sticker, item.link, item.trait)
                })
            end
        end
    end

    UpdateResultsUI()
end

local function CreateResultsWindow()
    if resultsWindow then return end
    local win = WINDOW_MANAGER:CreateTopLevelWindow("GearTracker_ResultsWindow")
    if win.SetWidth then win:SetWidth(1150) end
    if win.SetClampedToScreen then win:SetClampedToScreen(true) end
    if win.SetHidden then win:SetHidden(true) end 
    
    local bg = WINDOW_MANAGER:CreateControl(nil, win, CT_BACKDROP)
    if bg then
        if bg.SetAnchorFill then bg:SetAnchorFill() end
        if bg.SetCenterColor then bg:SetCenterColor(0, 0, 0, 0.9) end
        if bg.SetEdgeColor then bg:SetEdgeColor(0.4, 0.4, 0.4, 1) end
        if bg.SetEdgeTexture then bg:SetEdgeTexture("", 1, 1, 1) end
    end
    
    resultsWindow = win
    RefreshLabelSetup()
    MoveResultsWindow()
end

local function CreateQuestMiniUI()
    if questWindow then return end
    
    local win = WINDOW_MANAGER:CreateTopLevelWindow("GearTracker_QuestMiniWindow")
    win:SetDimensions(260, 50)
    win:SetMovable(false)
    win:SetClampedToScreen(true)
    
    local bg = WINDOW_MANAGER:CreateControl(nil, win, CT_BACKDROP)
    bg:SetAnchorFill()
    bg:SetCenterColor(0, 0, 0, 0.6)
    bg:SetEdgeColor(0.3, 0.3, 0.3, 0.8)
    bg:SetEdgeTexture("", 1, 1, 1)
    
    local lbl = WINDOW_MANAGER:CreateControl("GearTracker_QuestMiniLabel", win, CT_LABEL)
    lbl:SetAnchor(CENTER, win, CENTER, 0, 0)
    lbl:SetColor(1, 1, 1, 1)
    
    questWindow = win
    questLabel = lbl
end

-----------------------------------------------------------
-- 3. SCANNING LOGIC
-----------------------------------------------------------
local function ScanBagContents(bagId, storageTarget)
    if not GetBagSize or not GetItemLink then return end
    for slot = 0, GetBagSize(bagId) - 1 do
        local link = GetItemLink(bagId, slot)
        if link ~= "" then
            local itemType = GetItemLinkItemType(link)
            local equipType = GetItemLinkEquipType(link)
            local internalCategory = nil
            local weightType = ""

            if itemType == ITEMTYPE_WEAPON then 
                internalCategory = "WEAPON"
                weightType = "Weapon"
                
            elseif equipType == EQUIP_TYPE_NECK or equipType == EQUIP_TYPE_RING or itemType == ITEMTYPE_JEWELRY then
                internalCategory = "JEWELRY"
                weightType = "Jewelry"
                
            elseif itemType == ITEMTYPE_ARMOR then 
                internalCategory = "ARMOR"
                
                if equipType == EQUIP_TYPE_OFF_HAND then
                    weightType = "Shield"
                else
                    local armorRating = GetItemLinkArmorRating(link) or 0
                    
                    if equipType == EQUIP_TYPE_CHEST or equipType == EQUIP_TYPE_LEGS then
                        if armorRating > 2000 then weightType = "H"
                        elseif armorRating > 1100 then weightType = "M"
                        else weightType = "L" end
                    elseif equipType == EQUIP_TYPE_HEAD or equipType == EQUIP_TYPE_SHOULDERS or equipType == EQUIP_TYPE_FEET then
                        if armorRating > 1700 then weightType = "H"
                        elseif armorRating > 950 then weightType = "M"
                        else weightType = "L" end
                    else 
                        if armorRating > 1000 then weightType = "H"
                        elseif armorRating > 600 then weightType = "M"
                        else weightType = "L" end
                    end
                end
            end

            if internalCategory then
                TABLE_INSERT(storageTarget, {
                    link = link, 
                    name = zo_strformat("<<1>>", GetItemLinkName(link)), 
                    trait = GetString("SI_ITEMTRAITTYPE", GetItemLinkTraitInfo(link)),
                    type = internalCategory,
                    weight = weightType 
                })
            end
        end
    end
end

_G.AutoScanCharacter = function()
    if not SV or not GetUnitName then return end
    local char = zo_strformat("<<1>>", GetUnitName("player"))
    
    SV.chars[char] = { equipped = {}, bag = {} }
    SV.lastScan = GetTimeString()
    
    ScanBagContents(BAG_WORN, SV.chars[char].equipped)
    ScanBagContents(BAG_BACKPACK, SV.chars[char].bag)

    if IsBankOpen and IsBankOpen() then
        SV.bank = {}
        ScanBagContents(BAG_BANK, SV.bank)
        if IsESOPlusSubscriber and IsESOPlusSubscriber() then
            ScanBagContents(BAG_SUBSCRIBER_BANK, SV.bank)
        end
    end
end

-----------------------------------------------------------
-- 4. SETTINGS PANEL (UNIFIED SCROLL)
-----------------------------------------------------------
local function CreateLAMPanel()
    if not LibAddonMenu2 then return end
    
    local panelData = { 
        type = "panel", 
        name = ADDON.name .. "_Setting", 
        displayName = "|cFFFF00[|r |cFFFFFFGEAR TRACKER|r |cFFFF00]|r", 
        author = "|c00FFCCthewiz|r |c888888&|r ", 
        version = "|c00FF002.48|r",
        registerForRefresh = true,
    }

    local function SafeResetProgress()
        SV.dailyQuestsCompleted = 0  
        UpdateQuestMiniUI()
        if COMPASS_FRAME and COMPASS_FRAME.UpdateSubtitles then
            COMPASS_FRAME:UpdateSubtitles()
        end
    end

    local function SafeGlobalScan()
        _G.AutoScanCharacter()
        ApplyInventoryFilter()
        if resultsWindow and resultsWindow.SetHidden then resultsWindow:SetHidden(false) end
    end

    local function SafeDismiss()
        if resultsWindow and resultsWindow.SetHidden then 
            resultsWindow:SetHidden(true) 
        end
    end

    local function SafePurge()
        SV.chars = {}
        SV.bank = {}
        _G.AutoScanCharacter()
        ApplyInventoryFilter()
    end
    
    local optionsData = {
        {
            type = "submenu",
            name = "|t32:32:EsoUI/Art/LFG/LFG_icon_index_search.dds|t |cFFFF00OPEN GEARTRACKER DASHBOARD|r",
            tooltip = "Click to enter your unified controls panel.",
            controls = {
                {
                    type = "description",
                    text = "|cFFD700[ 1. DAILY QUEST TRACKER ]|r",
                    width = "full",
                },
                {
                    type = "checkbox",
                    name = "Show Mini HUD Tracker Window",
                    tooltip = "Toggle the visibility of the compact floating daily quest box on your gameplay UI screen.",
                    getFunc = function() return SV.showQuestTrackerUI end,
                    setFunc = function(v) SV.showQuestTrackerUI = v; MoveQuestWindow() end,
                    width = "full",
                },
                {
                    type = "slider",
                    name = "HUD Tracker Font Size",
                    min = 14, max = 30, step = 1,
                    getFunc = function() return SV.questFontSize or 20 end,
                    setFunc = function(v) SV.questFontSize = v; UpdateQuestMiniUI() end,
                    width = "full",
                },
                {
                    type = "slider",
                    name = "HUD Tracker Position X",
                    min = 0, max = 2500, step = 10,
                    getFunc = function() return SV.questX or 400 end,
                    setFunc = function(v) SV.questX = v; MoveQuestWindow() end,
                    width = "half",
                },
                {
                    type = "slider",
                    name = "HUD Tracker Position Y",
                    min = 0, max = 1500, step = 10,
                    getFunc = function() return SV.questY or 100 end,
                    setFunc = function(v) SV.questY = v; MoveQuestWindow() end,
                    width = "half",
                },
                {
                    type = "button",
                    name = "Reset Quest Counter Progress",
                    func = function() SafeResetProgress() end,
                    callback = function() SafeResetProgress() end,
                    width = "full",
                },
                {
                    type = "description",
                    text = "\n|cFFD700[ 2. LIVE INVENTORY MATCH FILTERS ]|r",
                    width = "full",
                },
                {
                    type = "editbox",
                    name = "Search Text Query String",
                    tooltip = "Filter item sets, specific traits, or character profiles.",
                    getFunc = function() return searchText end,
                    setFunc = function(text) 
                        searchText = text
                        ApplyInventoryFilter()
                        if resultsWindow and resultsWindow.SetHidden then resultsWindow:SetHidden(false) end
                    end,
                    isMultiline = false,
                    width = "full",
                },
                {
                    type = "dropdown",
                    name = "Filter Gear Selection Type",
                    choices = {"ALL", "ARMOR", "WEAPON", "JEWELRY"},
                    getFunc = function() return activeFilterType end,
                    setFunc = function(value) 
                        activeFilterType = value
                        ApplyInventoryFilter()
                        if resultsWindow and resultsWindow.SetHidden then resultsWindow:SetHidden(false) end
                    end,
                    width = "full",
                },
                {
                    type = "button",
                    name = "|c44FF44Execute Master Overlay Scan Update|r",
                    func = function() SafeGlobalScan() end,
                    callback = function() SafeGlobalScan() end,
                    width = "full",
                },
                {
                    type = "button",
                    name = "Next Display Result Page",
                    func = function() scrollOffset = (scrollOffset + SV.visibleCount < #searchResults) and (scrollOffset + SV.visibleCount) or 0; UpdateResultsUI() end,
                    callback = function() scrollOffset = (scrollOffset + SV.visibleCount < #searchResults) and (scrollOffset + SV.visibleCount) or 0; UpdateResultsUI() end,
                    width = "half",
                },
                {
                    type = "button",
                    name = "|cFF6666Close Active UI Window|r",
                    func = function() SafeDismiss() end,
                    callback = function() SafeDismiss() end,
                    width = "half",
                },
                {
                    type = "description",
                    text = "\n|cFFD700[ 3. OVERLAY SCALE & WINDOW BOUNDS ]|r",
                    width = "full",
                },
                {
                    type = "slider",
                    name = "Font Scale Sizing Values",
                    min = 16, max = 36, step = 1,
                    getFunc = function() return SV.fontSize or 24 end,
                    setFunc = function(v) 
                        SV.fontSize = v 
                        MoveResultsWindow()
                        UpdateResultsUI() 
                    end,
                    width = "full",
                },
                {
                    type = "slider",
                    name = "Horizontal Plane Location Offset (X)",
                    min = 0, max = 2500, step = 10,
                    getFunc = function() return SV.posX end,
                    setFunc = function(v) SV.posX = v; MoveResultsWindow() end,
                    width = "half",
                },
                {
                    type = "slider",
                    name = "Vertical Plane Location Offset (Y)",
                    min = 0, max = 1500, step = 10,
                    getFunc = function() return SV.posY end,
                    setFunc = function(v) SV.posY = v; MoveResultsWindow() end,
                    width = "half",
                },
                {
                    type = "slider",
                    name = "Display Rows per Individual Page",
                    min = 1, max = 15, step = 1,
                    getFunc = function() return SV.visibleCount end,
                    setFunc = function(v) SV.visibleCount = v; RefreshLabelSetup(); MoveResultsWindow(); UpdateResultsUI() end,
                    width = "full",
                },
                {
                    type = "description",
                    text = "\n|cFFD700[ 4. LOCAL ACCOUNT DATA REPOSITORY ]|r",
                    width = "full",
                },
                {
                    type = "description",
                    text = function()
                        local names = {}
                        for n in pairs(SV.chars) do TABLE_INSERT(names, n) end
                        table.sort(names)
                        
                        local grid = "|c66CCFF--- TRACKED CHARACTERS ---|r\n\n"
                        for i = 1, #names, 2 do
                            local n1 = names[i]
                            if type(SV.chars[n1]) == "table" then
                                local count1 = #(SV.chars[n1].bag or {}) + #(SV.chars[n1].equipped or {})
                                local line = string.format("|c00FF00•|r %-18s |c888888(%d)|r", n1, count1)
                                
                                if names[i+1] and type(SV.chars[names[i+1]]) == "table" then
                                    local n2 = names[i+1]
                                    local count2 = #(SV.chars[n2].bag or {}) + #(SV.chars[n2].equipped or {})
                                    line = line .. string.format("    |c00FF00•|r %-18s |c888888(%d)|r", n2, count2)
                                end
                                grid = grid .. line .. "\n"
                            end
                        end

                        local bankCount = (SV.bank and #SV.bank) or 0
                        local bankStatus = bankCount > 0 and string.format("|c00CCFFActive|r |c888888(%d items)|r", bankCount) or "|cFF3333Not Scanned|r"
                        local footer = string.format("\n|c66CCFF--- ACCOUNT DATA ---|r\n|cBBBBBBBank Status:|r %s\n|cBBBBBBLast Update:|r |cFFFFFF%s|r", bankStatus, SV.lastScan)
                        
                        return (grid ~= "|c66CCFF--- TRACKED CHARACTERS ---|r\n\n" and grid or "No character data found.\n") .. footer
                    end,
                    width = "full",
                },
                {
                    type = "button",
                    name = "|cFF2222Purge Saved Inventory Matrices|r",
                    warning = "Deletes all database information collected for all characters!",
                    func = function() SafePurge() end,
                    callback = function() SafePurge() end,
                    width = "full",
                },
            }
        }
    }
    
    LibAddonMenu2:RegisterAddonPanel(ADDON.name .. "_Panel", panelData)
    LibAddonMenu2:RegisterOptionControls(ADDON.name .. "_Panel", optionsData)
end

-----------------------------------------------------------
-- 5. INITIALIZATION & REGISTRATIONS
-----------------------------------------------------------
EVENT_MANAGER:RegisterForEvent(ADDON.name, EVENT_ADD_ON_LOADED, function(_, name)
    if name ~= ADDON.name then return end
    
    SV = ZO_SavedVars:NewAccountWide("GearTrackerSV", 1, nil, {
        chars = {}, bank = {}, fontSize = 24, posX = 300, posY = 200, visibleCount = 8, lastScan = "Never",
        dailyQuestsCompleted = 0, lastQuestResetDay = 0, showQuestTrackerUI = true, questFontSize = 20, questX = 400, questY = 100
    })

    if not SV.chars or type(SV.chars) ~= "table" then
        SV.chars = {}
    else
        for k, v in pairs(SV.chars) do
            if type(v) ~= "table" then
                SV.chars[k] = nil
            end
        end
    end
    if not SV.bank or type(SV.bank) ~= "table" then SV.bank = {} end

    CreateResultsWindow()
    CreateQuestMiniUI()
    
    _G.AutoScanCharacter()
    ApplyInventoryFilter() 
    CreateLAMPanel()
    MoveQuestWindow()
    
    if SCENE_MANAGER and SCENE_MANAGER.GetScene then
        local settingsScene = SCENE_MANAGER:GetScene("optionsCustomization")
        if settingsScene and settingsScene.RegisterCallback then
            settingsScene:RegisterCallback("StateChange", function(oldState, newState)
                if newState == SCENE_HIDDEN and resultsWindow and resultsWindow.SetHidden then
                    resultsWindow:SetHidden(true)
                end
            end)
        end
    end
end)

EVENT_MANAGER:RegisterForEvent(ADDON.name, EVENT_QUEST_REMOVED, function(_, isCompleted, journalIndex, questName, zoneName, poiQuest)
    -- Only increment if the quest was actually completed (not abandoned)
    if isCompleted then
        if not SV then return end
        CheckDailyReset()
        SV.dailyQuestsCompleted = (SV.dailyQuestsCompleted or 0) + 1
        UpdateQuestMiniUI()
    end
end)

EVENT_MANAGER:RegisterForEvent(ADDON.name, EVENT_OPEN_BANK, function() _G.AutoScanCharacter() end)