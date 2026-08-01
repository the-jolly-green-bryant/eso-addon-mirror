-- $Revision: 5.5 $
-- Author: Ian (Skyrim Red Shirts)

-- Matches your folder name "SRS_Events"
local MY_ADDON_NAME = "SRS_Events" 

-- 1. SUMMER TIME LOGIC
local function IsBST()
    local date = os.date("!*t") 
    if date.month > 3 and date.month < 10 then return true end
    if date.month == 3 then return (date.day - date.wday) >= 25 end
    if date.month == 10 then return (date.day - date.wday) < 25 end
    return false
end

-- 2. CORE SCHEDULE
local function GetCurrentEvent()
    local date = os.date("!*t") 
    local day = date.wday 
    local weekNum = tonumber(os.date("%V")) or 0
    local isOddWeek = (weekNum % 2 ~= 0)

    local schedule = {
        [1] = "PvP Cyrodiil/IC",
        [2] = "Boss Bashing & Mount Race",
        [3] = "Wolf Pack & Werewolf Duelling",
        [4] = "Normal Trials",
        [5] = isOddWeek and "Duelling" or "Dungeon Racing",
        [6] = isOddWeek and "Exploration" or "Skull Crusher",
        [7] = "Veteran Trials"
    }
    return schedule[day] or "Rest Day"
end

-- 3. TIMER DATA
local function GetEventTimerData()
    local eventName = GetCurrentEvent()
    local date = os.date("!*t")
    local targetHour = IsBST() and 20 or 21 
    
    if date.hour < targetHour then
        local hoursLeft = targetHour - date.hour - 1
        local minsLeft = 60 - date.min
        return string.format("%s in %dh %dm", eventName, hoursLeft, minsLeft), true
    elseif date.hour >= targetHour and date.hour < (targetHour + 3) then
        return string.format("%s (ACTIVE NOW!)", eventName), false
    else
        return "Events finished for today", false
    end
end

-- 4. COPY BOX UI
local function CreateCopyBox(text)
    local wm = GetWindowManager()
    local main = _G["SRSCopyWindow"] or wm:CreateTopLevelWindow("SRSCopyWindow")
    main:SetDimensions(450, 50)
    main:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
    main:SetDrawLayer(DL_OVERLAY)
    main:SetHidden(false)

    local edit = _G["SRSCopyEdit"] or wm:CreateControl("SRSCopyEdit", main, CT_EDITBOX)
    edit:SetAnchorFill()
    edit:SetFont("ZoFontGameLarge")
    edit:SetColor(1, 1, 1, 1)
    edit:SetMaxInputChars(250)
    edit:SetText(text)
    edit:SelectAll()
    edit:TakeFocus()

    edit:SetHandler("OnEnter", function() main:SetHidden(true) end)
    edit:SetHandler("OnEscape", function() main:SetHidden(true) end)
    
    d("|cFF0000[SRS]|r Text ready! Press |cFFFFFFCtrl+C|r then Enter.")
end

-- 5. INITIALIZATION
local function OnPlayerActivated()
    local timerText = GetEventTimerData()
    d("|cFF0000Skyrim Red Shirts Tracker Loaded.|r")
    d("|cFF0000[SRS]|r " .. timerText) 
    EVENT_MANAGER:UnregisterForEvent("SRS_Tracker", EVENT_PLAYER_ACTIVATED)
end

local function OnAddOnLoaded(event, addonName)
    -- Robust check for your folder name
    if addonName:lower() ~= MY_ADDON_NAME:lower() then return end

    -- Define Slash Commands
    SLASH_COMMANDS["/srs"] = function()
        local timerText, isPending = GetEventTimerData()
        if isPending then
            d("|cFF0000[SRS]|r Next Event: |cFFFFFF" .. timerText .. "|r")
        else
            d("|cFF0000[SRS]|r " .. timerText)
        end
    end

    SLASH_COMMANDS["/srsguild"] = function()
        local timerText = GetEventTimerData()
        local msg = "Tonight's SRS Event: " .. timerText
        CreateCopyBox(msg)
    end

    -- Setup welcome message once player is in-game
    EVENT_MANAGER:RegisterForEvent("SRS_Tracker", EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
    
    -- Clean up the loading listener
    EVENT_MANAGER:UnregisterForEvent("SRS_Tracker", EVENT_ADD_ON_LOADED)
end

-- Initialize the process
EVENT_MANAGER:RegisterForEvent("SRS_Tracker", EVENT_ADD_ON_LOADED, OnAddOnLoaded)