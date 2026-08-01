-------------------------------------------------------------------------------
-- Grumpys Simple Playtime - Console
-------------------------------------------------------------------------------
GrumpysSimplePlayTime = {}
GrumpysSimplePlayTime.name = "GrumpysSimplePlayTimeConsole"
GrumpysSimplePlaytime = GrumpysSimplePlaytime or {}

-------------------------------------------------------------------------------
-- Helper Functions
-------------------------------------------------------------------------------

-- Fixed Time Calculation: Capped at Weeks for absolute consistency
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
    if m_t > 0 then table.insert(p, m_t .. "m") end
    if s_t > 0 or #p == 0 then table.insert(p, s_t .. "s") end
    return table.concat(p, " ")
end

local function SavePlayTime()
    local ts = GetSecondsPlayed()
    local cn = GetUnitName("player")
    local sn = GetWorldName()
    local dateStr = GetDateStringFromTimestamp(GetTimeStamp())
    
    if not GrumpysSimplePlaytime[sn] then GrumpysSimplePlaytime[sn] = { ["Characters"] = {} } end
    
    GrumpysSimplePlaytime[sn].Characters[cn] = { 
        ["seconds"] = ts,
        ["readable"] = string.format("%.2f hours", ts / 3600),
        ["lastUpdated"] = dateStr
    }

    local totalSeconds = 0
    for _, data in pairs(GrumpysSimplePlaytime[sn].Characters) do
        totalSeconds = totalSeconds + (data.seconds or 0)
    end
    GrumpysSimplePlaytime[sn].TotalServerTime = string.format("Total: %.2f hours", totalSeconds / 3600)
end

-------------------------------------------------------------------------------
-- Chat Output Function
-------------------------------------------------------------------------------

function GrumpysSimplePlayTime.PrintToChat()
    local sn = GetWorldName()
    if not GrumpysSimplePlaytime[sn] or not GrumpysSimplePlaytime[sn].Characters then
        d("|cFF0000[PlayTime]|r No data recorded for this megaserver yet.")
        return
    end

    d("|cFFEEAA[Simple PlayTime - " .. string.upper(sn) .. "]|r")
    
    local total = 0
    local sorted = {}

    for name, data in pairs(GrumpysSimplePlaytime[sn].Characters) do
        table.insert(sorted, {n = name, s = data.seconds})
        total = total + (data.seconds or 0)
    end
    
    table.sort(sorted, function(a,b) return a.n < b.n end)

    for _, char in ipairs(sorted) do
        local hours = math.floor(char.s / 3600)
        d(string.format("|cFFFFFF%s:|r |c00FF00%dh|r (%s)", char.n, hours, FormatTimeDetailed(char.s)))
    end
    
    d("--------------------------")
    d("|cFFEEAAAccount Total:|r |cFFFF00" .. FormatTimeDetailed(total) .. " (" .. math.floor(total/3600) .. "h)|r")
end

-------------------------------------------------------------------------------
-- Initialization
-------------------------------------------------------------------------------

local function OnAddOnLoaded(eventCode, addonName)
    if addonName ~= "GrumpysSimplePlayTimeConsole" then return end
    
    SLASH_COMMANDS["/playtime"] = GrumpysSimplePlayTime.PrintToChat
    
    EVENT_MANAGER:RegisterForEvent(GrumpysSimplePlayTime.name, EVENT_PLAYER_ACTIVATED, SavePlayTime)
    EVENT_MANAGER:RegisterForEvent(GrumpysSimplePlayTime.name, EVENT_PLAYER_DEACTIVATED, SavePlayTime)
    
    EVENT_MANAGER:UnregisterForEvent(GrumpysSimplePlayTime.name, EVENT_ADD_ON_LOADED)
end

EVENT_MANAGER:RegisterForEvent(GrumpysSimplePlayTime.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)