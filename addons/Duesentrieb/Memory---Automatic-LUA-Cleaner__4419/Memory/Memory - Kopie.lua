------------------------------------------------------------------------
-- MEMORY - SIMPLE ADDON TO CLEAN YOUR LUA MEMORY FROM UNUSED GARBAGE --
------------------------------------------------------------------------
-- /script Memory.SV.bEnableEventMessage = false / true

Memory = {
    name    = "Memory",
    author  = "@Duesentrieb",
    version = "20260228-0001",
    chat    = "|cFF7F00[Memory]|r",

    -- STATE VARIABLES
    bIsLoaded    = false,
    bCleanQueued = false,

    -- EVENT DEFINITIONS FOR DYNAMIC HANDLING
    -- TODO: INVENTORY
    eventList = {
        ["Bank"]      = EVENT_CLOSE_BANK,
        ["GBank"]     = EVENT_CLOSE_GUILD_BANK,
        ["Store"]     = EVENT_CLOSE_STORE,
        ["Trade"]     = EVENT_CLOSE_TRADING_HOUSE,
        ["Craft"]     = EVENT_END_CRAFTING_STATION_INTERACT,
        ["Activated"] = EVENT_PLAYER_ACTIVATED,
        ["Combat"]    = EVENT_PLAYER_COMBAT_STATE,
        ["LowMem"]    = EVENT_LUA_LOW_MEMORY,
    },

    -- DEFAULT SAVED VARIABLES
    default = {
        bEnableAddon        = true,
        bEnableClean        = true,
        nDelayInfo         = 60,
        nDelayClean         = 600,
        bEnableInfoMessage = false,
        bEnableCleanMessage = true,
        bEnableEventMessage = false,
    },

    -- SAVED VARIABLES CONFIGURATION
    SV         = {},
    nSVVersion = 2,
    strSVName  = "MemoryVariables",
}

local M  = Memory
local EM = EVENT_MANAGER

----------------------------------
-- HELPER: GET LUA MEMORY IN MB --
----------------------------------
local function GetLuaMB()
    return math.floor(collectgarbage("count") / 1024 + 0.5)
end

----------------------------------
-- FORMAT AND PRINT CHAT OUTPUT --
----------------------------------
function Memory.PrintStatus(strDelta, bSilent)
    if bSilent then return end
    local strAddOn = string.format("|c7FFF7FFlow: %.1fMB|r", GetTotalUserAddOnMemoryPoolUsageMB())
    local strLua   = string.format("|c7FFFFFLua: %iMB|r", GetLuaMB())
    d(string.format("%s %s %s %s", M.chat, strAddOn, strLua, strDelta or ""))
end

------------------------------------
-- CHECK AND PRINT CURRENT MEMORY --
------------------------------------
function Memory.DoInfo(bForce, bSilent)
    if not bForce then
        if not M.SV.bEnableAddon or not M.SV.bEnableInfoMessage then return end
    end
    Memory.PrintStatus("", bSilent)
end

--------------------------------------------
-- CLEAN THE MEMORY BY COLLECTING GARBAGE --
--------------------------------------------
function Memory.DoClean(bForce, bSilent)
    if not bForce then
        if not M.SV.bEnableAddon or not M.SV.bEnableClean then return end
        if IsUnitInCombat("player") or IsUnitDead("player") then return end
    end

    local nOldCount = GetLuaMB()

    -- TWO RUNS FOR THOROUGH CLEANING
    collectgarbage("collect")
    collectgarbage("collect")

    local nNewCount = GetLuaMB()
    local nDelta    = math.max(0, nOldCount - nNewCount)
    local strDelta  = ""

    if nDelta > 0 then
        strDelta = string.format("|cFF7F00→ %iMB CLEANED!|r", nDelta)
    end

    if bForce or (nDelta > 0 and M.SV.bEnableCleanMessage) then
        Memory.PrintStatus(strDelta, bSilent)
    end
end

--------------------------
-- EVENT_LUA_LOW_MEMORY --
--------------------------
function Memory.OnLuaLowMemory()
    d(M.chat .. " |cFF0000WARNING: LUA MEMORY LOW!|r")
    Memory.DoClean(true, true) -- Silent emergency clean
end

------------------
-- ENABLE ADDON --
------------------
function Memory.EnableAddon(bSilent)
    -- DYNAMIC EVENT REGISTRATION
    for strSuffix, eventId in pairs(M.eventList) do
        EM:RegisterForEvent(M.name .. strSuffix, eventId, function(eventCode, ...)

            if eventId == EVENT_LUA_LOW_MEMORY then
                Memory.OnLuaLowMemory()
                return
            end

            if eventId == EVENT_PLAYER_COMBAT_STATE then
                local bInCombat = ...
                if bInCombat then return end
            end

            -- TRIGGER DEBOUNCED CLEAN ON ALLOWED EVENTS
            if not M.bCleanQueued then
                M.bCleanQueued = true
                local nDelay = (eventId == EVENT_PLAYER_ACTIVATED or eventId == EVENT_PLAYER_COMBAT_STATE) and 5000 or 2500
                zo_callLater(function()
                    M.bCleanQueued = false
                    Memory.DoClean(false, not M.SV.bEnableEventMessage)
                end, nDelay)
            end
        end)
    end

    -- START SEPARATE UPDATE LOOPS
    EM:UnregisterForUpdate(M.name .. "InfoLoop")
    EM:UnregisterForUpdate(M.name .. "CleanLoop")

    if M.SV.bEnableInfoMessage then
        EM:RegisterForUpdate(M.name .. "InfoLoop", M.SV.nDelayInfo * 1000, function() Memory.DoInfo(false, false) end)
    end

    if M.SV.bEnableClean then
        EM:RegisterForUpdate(M.name .. "CleanLoop", M.SV.nDelayClean * 1000, function() Memory.DoClean(false, false) end)
    end

    if not bSilent then
        local strInfo = M.SV.bEnableInfoMessage and string.format("|c7FFF7F[Info %is]|r", M.SV.nDelayInfo) or "|cFFFF7F[Info OFF]|r"
        local strClean = M.SV.bEnableCleanMessage and string.format("|c7FFF7F[Clean %is]|r", M.SV.nDelayClean) or "|cFFFF7F[Clean OFF]|r"
        d(string.format("%s |c00FF00Enabled|r %s %s", M.chat, strInfo, strClean))
    end

    M.bIsLoaded = true
end

-------------------
-- DISABLE ADDON --
-------------------
function Memory.DisableAddon(bSilent)
    for index, value in pairs(M.eventList) do
        EM:UnregisterForEvent(M.name .. index)
    end

    EM:UnregisterForUpdate(M.name .. "InfoLoop")
    EM:UnregisterForUpdate(M.name .. "CleanLoop")

    if not bSilent then
        d(M.chat .. " |cFF0000Disabled|r")
    end
end

---------------------------------------------------
-- SLASH COMMAND: /memory [info_sec] [clean_sec] --
---------------------------------------------------
SLASH_COMMANDS["/memory"] = function(data)
    data = data and string.lower(data) or ""

    if data == "help" then
        d(M.chat .. " |cFFFFFFHelp / Parameters:|r")
        d("|cFFFF00/memory|r |cFFFFFF→ Toggle Addon ON/OFF|r")

        d("|cFFFF00/memory info|r |cFFFFFF→ Force Info Message (1x)|r")
        d("|cFFFF00/memory clean|r |cFFFFFF→ Force Memory Clean (1x)|r")
        d("|cFFFF00/memory event|r |cFFFFFF→ Toggle Event Messages ON/OFF|r")

        d("|cFFFF00/memory [n]|r |cFFFFFF→ Set info interval in seconds (0 = OFF)|r")
        d("|cFFFF00/memory [n] [m]|r |cFFFFFF→ Set info and clean intervals in seconds (0 = OFF)|r")
        d(M.chat .. " |cFFFFFFExample:|r")
        d("|cFFFF00/memory 0 600|r |cFFFFFF→ Info OFF, Clean every 10 mins|r")
        return
    end

    if data == "info" then
        M.DoInfo(true, false)
        return
    end

    if data == "clean" then
        M.DoClean(true, false)
        return
    end

    if data == "event" then
        M.SV.bEnableEventMessage = not M.SV.bEnableEventMessage
        local strEvent = M.SV.bEnableEventMessage and "|c7FFF7FEvent Messages ON|r" or "|cFFFF7FEvent Messages OFF|r"
        d(string.format("%s %s", M.chat, strEvent))
        return
    end

    local arg1, arg2 = data:match("^(%d+)%s*(%d*)$")
    local nInfo = tonumber(arg1)
    local nClean = tonumber(arg2)

    if not nInfo then
        M.SV.bEnableAddon = not M.SV.bEnableAddon
        if M.SV.bEnableAddon then
            Memory.EnableAddon(false)
        else
            Memory.DisableAddon(false)
        end
        return
    end

    -- APPLY PARAMETERS
    M.SV.bEnableAddon = true

    if nInfo == 0 then
        M.SV.bEnableInfoMessage = false
    else
        M.SV.bEnableInfoMessage = true
        M.SV.nDelayInfo = math.max(1, math.min(nInfo, 600))
    end

    if nClean then
        if nClean == 0 then
            M.SV.bEnableClean = false
            M.SV.bEnableCleanMessage = false
        else
            M.SV.bEnableClean = true
            M.SV.bEnableCleanMessage = true
            M.SV.nDelayClean = math.max(10, math.min(nClean, 3600))
        end
    end

    -- RESTART TO APPLY TIMERS CLEANLY
    Memory.DisableAddon(true)
    Memory.EnableAddon(false)
end

------------------------------------------
-- INITIALIZE THE SV AND START / ENABLE --
------------------------------------------
function Memory.Initialize()
    M.SV = ZO_SavedVars:NewAccountWide(M.strSVName, M.nSVVersion, GetWorldName(), M.default)

    -- Hello Baertram! :-)
    -- Thanks for stopping by! Are you looking for saved variables, GetWorldName() and version dependencies?
    -- I got ya! :-D
    -- We as a community really appreciate your eye for those technical details and your constant help!
    -- As it turns out, this little add-on is so simple that it doesn't use any of those features - Sorry! :-D
    -- But it's hand-coded with love! <3
    -- Thanks for your amazing work for the community and see ya next time!
    -- Daniel
    -- Edit: Changed my mind about SV.. ^_^

    if M.SV.bEnableAddon then
        zo_callLater(function()
            Memory.EnableAddon(true)
            Memory.DoClean(false, false)
        end, 10000)
    else
        zo_callLater(function()
            d(M.chat .. " |cFF0000Currently Disabled!|r Type |cFF7F00/memory|r |cFFFFFFto enable.|r")
        end, 10000)
    end
end

----------------------------------------
-- LOAD / UNREGISTER AFTER GAME START --
----------------------------------------
function Memory.OnAddOnLoaded(eventCode, strAddonName)
    if strAddonName == M.name then
        EM:UnregisterForEvent(M.name .. "AddOnLoaded", EVENT_ADD_ON_LOADED)
        Memory.Initialize()
    end
end

-- INITIAL REGISTRATION
EM:RegisterForEvent(M.name .. "AddOnLoaded", EVENT_ADD_ON_LOADED, M.OnAddOnLoaded)