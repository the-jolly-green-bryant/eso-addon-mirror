SimplePlayTime = {}
SimplePlayTime.name = "SimplePlayTime"
SimplePlayTimeVars = SimplePlayTimeVars or {}

local currentView = GetWorldName()

-- Fixed Time Calculation: Removes faulty Month division to align perfectly with raw hours
local function FormatTimeDetailed(sIn)
    if not sIn or sIn <= 0 then return "0s" end
    
    local w = math.floor(sIn / 604800)
    local d = math.floor((sIn % 604800) / 86400)
    local h = math.floor((sIn % 86400) / 3600)
    local m_t = math.floor((sIn % 3600) / 60)
    local s_t = math.floor(sIn % 60)

    local p = {}
    if w > 0 then table.insert(p, w .. "w") end
    if d > 0 then table.insert(p, d .. "d") end
    if h > 0 then table.insert(p, h .. "h") end
    if m_t > 0 then table.insert(p, m_t .. "m") end -- 'm' is now strictly minutes
    if s_t > 0 or #p == 0 then table.insert(p, s_t .. "s") end
    return table.concat(p, " ")
end

local function SaveCurrentPlayTime()
    local ts = GetSecondsPlayed()
    local cn = GetUnitName("player")
    local sn = GetWorldName()
    local dateStr = GetDateStringFromTimestamp(GetTimeStamp())
    
    if not SimplePlayTimeVars[sn] then SimplePlayTimeVars[sn] = { ["Characters"] = {} } end
    
    SimplePlayTimeVars[sn].Characters[cn] = { 
        ["seconds"] = ts,
        ["readable"] = string.format("%.2f hours", ts / 3600),
        ["lastUpdated"] = dateStr
    }

    local totalSeconds = 0
    for _, data in pairs(SimplePlayTimeVars[sn].Characters) do
        totalSeconds = totalSeconds + (data.seconds or 0)
    end
    SimplePlayTimeVars[sn].TotalServerTime = string.format("Total: %.2f hours", totalSeconds / 3600)
end

function SimplePlayTime.OnMoveStop()
    SimplePlayTimeVars.WindowPos = { 
        left = SimplePlayTimeWindow:GetLeft(), 
        top = SimplePlayTimeWindow:GetTop()
    }
end

function SimplePlayTime.UpdateUI()
    local window = SimplePlayTimeWindow
    if not window or window:IsHidden() then return end
    
    local scroll = SimplePlayTimeWindowListHolderScroll
    local scrollChild = scroll:GetNamedChild("Contents") or scroll
    SimplePlayTimeWindowServerToggle:SetText("View " .. ((currentView == "EU Megaserver") and "NA" or "EU"))
    
    if not scrollChild.NameLabel then
        scrollChild.NameLabel = WINDOW_MANAGER:CreateControl("$(parent)Names", scrollChild, CT_LABEL)
        scrollChild.NameLabel:SetFont("ZoFontGameLargeBold")
        scrollChild.NameLabel:SetAnchor(TOPLEFT, scrollChild, TOPLEFT, 0, 0)
        
        scrollChild.HourLabel = WINDOW_MANAGER:CreateControl("$(parent)Hours", scrollChild, CT_LABEL)
        scrollChild.HourLabel:SetFont("ZoFontGameLargeBold")
        scrollChild.HourLabel:SetAnchor(TOPLEFT, scrollChild, TOPLEFT, 190, 0) 
        scrollChild.HourLabel:SetColor(0.8, 0.8, 0.8, 1)

        scrollChild.TimeLabel = WINDOW_MANAGER:CreateControl("$(parent)Times", scrollChild, CT_LABEL)
        scrollChild.TimeLabel:SetFont("ZoFontGameLargeBold")
        scrollChild.TimeLabel:SetAnchor(TOPLEFT, scrollChild, TOPLEFT, 260, 0) 
        scrollChild.TimeLabel:SetColor(0, 1, 0, 1)
    end

    local nOut = "|cFFEEAA" .. string.upper(currentView) .. "|r\n----------------\n"
    local hOut = "\n\n"
    local tOut = "\n\n"
    local total = 0
    local sorted = {}

    if SimplePlayTimeVars[currentView] and SimplePlayTimeVars[currentView].Characters then
        for nameKey, dataTable in pairs(SimplePlayTimeVars[currentView].Characters) do 
            if dataTable and dataTable.seconds then
                table.insert(sorted, {n = nameKey, s = dataTable.seconds}) 
                total = total + dataTable.seconds
            end
        end
    end
    
    table.sort(sorted, function(a,b) return a.n < b.n end)
    for i = 1, #sorted do
        nOut = nOut .. sorted[i].n .. "\n"
        hOut = hOut .. math.floor(sorted[i].s / 3600) .. "h\n"
        tOut = tOut .. FormatTimeDetailed(sorted[i].s) .. "\n"
    end
    
    nOut = nOut .. "----------------\n|cFFEEAAAccount Total:|r"
    hOut = hOut .. "\n|cFFFF00" .. math.floor(total / 3600) .. "h|r"
    tOut = tOut .. "\n|cFFFF00" .. FormatTimeDetailed(total) .. "|r"
    
    scrollChild.NameLabel:SetText(nOut)
    scrollChild.HourLabel:SetText(hOut)
    scrollChild.TimeLabel:SetText(tOut)
end

function SimplePlayTime.ToggleServerView()
    currentView = (currentView == "EU Megaserver") and "NA Megaserver" or "EU Megaserver"
    SimplePlayTime.UpdateUI()
end

function SimplePlayTime.ToggleWindow()
    if not SimplePlayTimeWindow then return end
    SimplePlayTimeWindow:SetHidden(not SimplePlayTimeWindow:IsHidden())
    if not SimplePlayTimeWindow:IsHidden() then 
        SaveCurrentPlayTime()
        SimplePlayTime.UpdateUI() 
    end
end

local function OnAddOnLoaded(eventCode, addonName)
    if addonName ~= SimplePlayTime.name then return end
    SLASH_COMMANDS["/playtime"] = SimplePlayTime.ToggleWindow
    ZO_CreateStringId("SI_BINDING_NAME_SIMPLE_PLAY_TIME_TOGGLE_WINDOW", "Toggle PlayTime Window")
    SimplePlayTimeVars = SimplePlayTimeVars or {}

    EVENT_MANAGER:RegisterForEvent(SimplePlayTime.name .. "_Activated", EVENT_PLAYER_ACTIVATED, function()
        SaveCurrentPlayTime()
        if SimplePlayTimeVars.WindowPos then
            SimplePlayTimeWindow:ClearAnchors()
            SimplePlayTimeWindow:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, SimplePlayTimeVars.WindowPos.left, SimplePlayTimeVars.WindowPos.top)
        end
        EVENT_MANAGER:UnregisterForEvent(SimplePlayTime.name .. "_Activated", EVENT_PLAYER_ACTIVATED)
    end)

    EVENT_MANAGER:RegisterForEvent(SimplePlayTime.name .. "_Deactivated", EVENT_PLAYER_DEACTIVATED, SaveCurrentPlayTime)
    EVENT_MANAGER:UnregisterForEvent(SimplePlayTime.name .. "_Loaded", EVENT_ADD_ON_LOADED)
end

EVENT_MANAGER:RegisterForEvent(SimplePlayTime.name .. "_Loaded", EVENT_ADD_ON_LOADED, OnAddOnLoaded)