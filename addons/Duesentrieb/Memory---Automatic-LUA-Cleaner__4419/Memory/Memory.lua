------------------------------------------------------------------------
-- MEMORY - SIMPLE ADDON TO CLEAN YOUR LUA MEMORY FROM UNUSED GARBAGE --
------------------------------------------------------------------------

Memory = {
    name    = "Memory",
    author  = "@Duesentrieb",
    version = "20260304-0001",
    chat    = "|cFF7F00[Memory]|r",

    -- STATE VARIABLES
    bIsLoaded    = false,
    bCleanQueued = false,

    -- EVENT DEFINITIONS FOR DYNAMIC HANDLING
    eventList = {
        ["Bank"]      = EVENT_CLOSE_BANK,
        ["GBank"]     = EVENT_CLOSE_GUILD_BANK,
        ["Store"]     = EVENT_CLOSE_STORE,
        ["Trade"]     = EVENT_CLOSE_TRADING_HOUSE,
        ["Craft"]     = EVENT_END_CRAFTING_STATION_INTERACT,
        ["Activated"] = EVENT_PLAYER_ACTIVATED,
        ["Combat"]    = EVENT_PLAYER_COMBAT_STATE,
    },

    -- DEFAULT SAVED VARIABLES
    default = {
        bEnableAddon                = true,
        -- INFO
        nDelayInfo                  = 10,
        bEnableInfoMessage          = false,
        --TIMER CLEAN
        bEnableTimerClean           = true,
        nDelayClean                 = 300,
        bEnableTimerCleanMessage    = false,
        -- EVENT CLEAN
        bEnableEventClean           = true,
        bEnableEventCleanMessage    = false,
    },

    -- SAVED VARIABLES CONFIGURATION
    SV         = {},
    nSVVersion = 3,
    strSVName  = "MemoryVariables",
}

local M  = Memory
local EM = EVENT_MANAGER
local LAM2 = LibAddonMenu2

----------------------------------
-- HELPER: GET LUA MEMORY IN MB --
----------------------------------
function Memory.GetLuaMB()
    return math.floor(collectgarbage("count") / 1024 + 0.5)
end

----------------------------------
-- FORMAT AND PRINT CHAT OUTPUT --
----------------------------------
function Memory.PrintStatus(strDelta, bSilent)
    if bSilent then return end
    local strAddOn = string.format("|c7FFF7FFlow: %.1fMB|r", GetTotalUserAddOnMemoryPoolUsageMB())
    local strLua   = string.format("|c7FFFFFLua: %iMB|r", Memory.GetLuaMB())
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
        if not M.SV.bEnableAddon then return end 
        if IsUnitInCombat("player") or IsUnitDead("player") then return end
    end

    local nOldCount = Memory.GetLuaMB()

    -- TWO RUNS FOR THOROUGH CLEANING
    collectgarbage("collect")
    collectgarbage("collect")

    local nNewCount = Memory.GetLuaMB()
    local nDelta    = math.max(0, nOldCount - nNewCount)
    local strDelta  = ""

    if nDelta > 0 then
        strDelta = string.format("|cFF7F00→ %iMB CLEANED!|r", nDelta)
    end

    -- PRINT ONLY IF FORCED OR IF DELTA > 0 AND NOT SILENT
    if bForce or (nDelta > 0 and not bSilent) then
        Memory.PrintStatus(strDelta, false)
    end
end

--------------------------
-- EVENT_LUA_LOW_MEMORY --
--------------------------
function Memory.OnLuaLowMemory()
    d(M.chat .. " |cFF0000WARNING: LUA MEMORY LOW!|r")
    Memory.DoClean(true, true) -- SILENT EMERGENCY CLEAN
end

------------------
-- ENABLE ADDON --
------------------
function Memory.EnableAddon(bSilent)
    -- EMERGENCY LOW MEMORY EVENT (ALWAYS ACTIVE IF ADDON IS ON)
    EM:RegisterForEvent(M.name .. "LowMem", EVENT_LUA_LOW_MEMORY, Memory.OnLuaLowMemory)

    -- DYNAMIC EVENT REGISTRATION (ONLY IF ENABLED)
    -- value = eventId
    if M.SV.bEnableEventClean then
        for key, value in pairs(M.eventList) do
            EM:RegisterForEvent(M.name .. key, value, function(eventCode, ...)

                if value == EVENT_PLAYER_COMBAT_STATE then
                    local bInCombat = ...
                    if bInCombat then return end
                end

                -- TRIGGER DEBOUNCED CLEAN ON ALLOWED EVENTS
                if not M.bCleanQueued then
                    M.bCleanQueued = true
                    local nDelay = (value == EVENT_PLAYER_ACTIVATED or value == EVENT_PLAYER_COMBAT_STATE) and 5000 or 2500
                    zo_callLater(function()
                        M.bCleanQueued = false
                        local bShouldBeSilent = not M.SV.bEnableEventCleanMessage
                        Memory.DoClean(false, bShouldBeSilent)
                    end, nDelay)
                end
            end)
        end
    end

    -- START SEPARATE UPDATE LOOPS
    EM:UnregisterForUpdate(M.name .. "InfoLoop")
    EM:UnregisterForUpdate(M.name .. "CleanLoop")

    if M.SV.bEnableInfoMessage then
        EM:RegisterForUpdate(M.name .. "InfoLoop", M.SV.nDelayInfo * 1000, function()
            Memory.DoInfo(false, false)
        end)
    end

    if M.SV.bEnableTimerClean then
        EM:RegisterForUpdate(M.name .. "CleanLoop", M.SV.nDelayClean * 1000, function()
            Memory.DoClean(false, not M.SV.bEnableTimerCleanMessage)
        end)
    end

    if not bSilent then
        d(M.chat .. " |c00FF00Enabled|r")
    end

    M.bIsLoaded = true
end

-------------------
-- DISABLE ADDON --
-------------------
function Memory.DisableAddon(bSilent)
    for key, value in pairs(M.eventList) do
        EM:UnregisterForEvent(M.name .. key)
    end

    -- UNREGISTER EMERGENCY EVENT
    EM:UnregisterForEvent(M.name .. "LowMem")

    EM:UnregisterForUpdate(M.name .. "InfoLoop")
    EM:UnregisterForUpdate(M.name .. "CleanLoop")

    if not bSilent then
        d(M.chat .. " |cFF0000Disabled|r")
    end
end

---------------------------------------------------
-- SLASH COMMANDS                                --
---------------------------------------------------
SLASH_COMMANDS["/memory"] = function(data)
    local cmd = data and string.lower(string.match(data, "%S+")) or ""

    -- PRINT HELP
    if cmd == "help" then
        d(M.chat .. " |cFFFFFFHelp / Parameters:|r")
        d("|cFFFF00/memory|r |cFFFFFF→ Toggle Addon ON/OFF|r")
        d("|cFFFF00/memory menu|r |cFFFFFF→ Open Settings Menu|r")
        d("|cFFFF00/memory info|r |cFFFFFF→ Force Info Message (1x)|r")
        d("|cFFFF00/memory clean|r |cFFFFFF→ Force Memory Clean (1x)|r")
        return
    end

    -- OPEN SETTINGS MENU
    if cmd == "menu" then
        LAM2:OpenToPanel(Memory.varAddonPanel)
        return
    end

    -- 1x INFO (FORCED)
    if cmd == "info" then
        M.DoInfo(true, false)
        return
    end

    -- 1x CLEAN (FORCED)
    if cmd == "clean" then
        M.DoClean(true, false)
        return
    end

    -- TOGGLE ADDON
    if cmd == "" then
        M.SV.bEnableAddon = not M.SV.bEnableAddon
        if M.SV.bEnableAddon then
            Memory.EnableAddon(false)
        else
            Memory.DisableAddon(false)
        end
        return
    end

    d(M.chat .. " |cFFFFFFUnknown command. Type|r |cFFFF00/memory help|r")
end

--------------------------
-- CREATE SETTINGS MENU --
--------------------------
function Memory.CreateSettingsWindow()
    local panelData = {
        type = "panel",
        name = "Memory",
        displayName = "|cFF7F00Memory|r |cFFFFFFAutomatic LUA Cleaner|r",
        author = "|cFF7F00"..Memory.author .. "|r |cFFFFFF[EU]|r",
        version = "|cFF7F00"..Memory.version .. "|r",
        registerForRefresh = true,
        registerForDefaults = true,
    }

    local optionsData = {
        {
            type = "checkbox",
            name = "MASTERSWITCH (Turns the entire addon ON/OFF)",
            tooltip = "Enables or disables all features of the addon.",
            getFunc = function() return Memory.SV.bEnableAddon end,
            setFunc = function(value)
                Memory.SV.bEnableAddon = value
                if value == true then
                    Memory.EnableAddon(false)
                else
                    Memory.DisableAddon(false)
                end
            end,
            default = Memory.default.bEnableAddon,
            width = "full"
        },
        {
            type = "header",
            name = "|cFF7F00INFO Message|r"
        },
        {
            type = "checkbox",
            name = "Write INFO Message in Chat:",
            getFunc = function() return Memory.SV.bEnableInfoMessage end,
            setFunc = function(value) 
                Memory.SV.bEnableInfoMessage = value
                Memory.DisableAddon(true)
                if Memory.SV.bEnableAddon then Memory.EnableAddon(true) end
            end,
            disabled = function() return not Memory.SV.bEnableAddon end,
            default = Memory.default.bEnableInfoMessage,
            width = "full"
        },
        {
            type = "slider",
            name = "Delay INFO Message (Seconds):",
            min = 0,
            max = 60,
            step = 1,
            getFunc = function() return Memory.SV.nDelayInfo end,
            setFunc = function(value) 
                Memory.SV.nDelayInfo = value
                Memory.DisableAddon(true)
                if Memory.SV.bEnableAddon then Memory.EnableAddon(true) end
            end,
            disabled = function() return not Memory.SV.bEnableAddon end,
            default = Memory.default.nDelayInfo,
            width = "full"
        },
        {
            type = "header",
            name = "|cFF7F00Automatic Cleaning: [TIMER]|r"
        },
        {
            type = "checkbox",
            name = "Enable TIMER Cleaning:",
            getFunc = function() return Memory.SV.bEnableTimerClean end,
            setFunc = function(value) 
                Memory.SV.bEnableTimerClean = value
                Memory.DisableAddon(true)
                if Memory.SV.bEnableAddon then Memory.EnableAddon(true) end
            end,
            disabled = function() return not Memory.SV.bEnableAddon end,
            default = Memory.default.bEnableTimerClean,
            width = "full"
        },
        {
            type = "checkbox",
            name = "Write TIMER Cleaning in Chat:",
            getFunc = function() return Memory.SV.bEnableTimerCleanMessage end,
            setFunc = function(value) Memory.SV.bEnableTimerCleanMessage = value end,
            disabled = function() return not Memory.SV.bEnableAddon end,
            default = Memory.default.bEnableTimerCleanMessage,
            width = "full"
        },
        {
            type = "slider",
            name = "Delay TIMER Cleaning (Seconds):",
            min = 10,
            max = 600,
            step = 10,
            getFunc = function() return Memory.SV.nDelayClean end,
            setFunc = function(value) 
                Memory.SV.nDelayClean = value
                Memory.DisableAddon(true)
                if Memory.SV.bEnableAddon then Memory.EnableAddon(true) end
            end,
            disabled = function() return not Memory.SV.bEnableAddon end,
            default = Memory.default.nDelayClean,
            width = "full"
        },
        {
            type = "header",
            name = "|cFF7F00Automatic Cleaning: [EVENTS]|r"
        },
        {
            type = "checkbox",
            name = "Enable EVENT Cleaning:",
            getFunc = function() return Memory.SV.bEnableEventClean end,
            setFunc = function(value) 
                Memory.SV.bEnableEventClean = value
                Memory.DisableAddon(true)
                if Memory.SV.bEnableAddon then Memory.EnableAddon(true) end
            end,
            disabled = function() return not Memory.SV.bEnableAddon end,
            default = Memory.default.bEnableEventClean,
            width = "full"
        },
        {
            type = "checkbox",
            name = "Write EVENT Cleaning in Chat:",
            getFunc = function() return Memory.SV.bEnableEventCleanMessage end,
            setFunc = function(value) Memory.SV.bEnableEventCleanMessage = value end,
            disabled = function() return not Memory.SV.bEnableAddon end,
            default = Memory.default.bEnableEventCleanMessage,
            width = "full"
        },
        {
            type = "button",
            name = "WRITE INFO (1x)",
            func = function() Memory.DoInfo(true, false) end,
            disabled = function() return not Memory.SV.bEnableAddon end,
            width = "half"
        },
        {
            type = "button",
            name = "|cFF7F00CLEAN NOW (1x)|r",
            func = function() Memory.DoClean(true, false) end,
            disabled = function() return not Memory.SV.bEnableAddon end,
            width = "half"
        },
        {
            type = "divider"
        },
        {
            type = "description",
            text = "If you enjoy |cFF7F00Memory|r, consider sharing your feedback or supporting its development. Your input and contributions are greatly appreciated!",
            width = "full"
        },
        {
            type = "button",
            name = "Feedback / Donate",
            tooltip = "Opens a mail to send feedback or donate to the author. <3",
            func = function()
                SCENE_MANAGER:Show('mailSend')
                zo_callLater(function()
                    ZO_MailSendToField:SetText(Memory.author)
                    ZO_MailSendSubjectField:SetText("Memory Addon")
                    ZO_MailSendBodyField:TakeFocus()
                end, 250)
            end,
            width = "half"
        }
    }
    Memory.varAddonPanel = LAM2:RegisterAddonPanel(Memory.name .. "Menu", panelData)
    LAM2:RegisterOptionControls(Memory.name .. "Menu", optionsData)
end

------------------------------------------
-- INITIALIZE THE SV AND START / ENABLE --
------------------------------------------
function Memory.Initialize()
    M.SV = ZO_SavedVars:NewAccountWide(M.strSVName, M.nSVVersion, GetWorldName(), M.default)

    Memory.CreateSettingsWindow()

    if M.SV.bEnableAddon then
        zo_callLater(function()
            Memory.EnableAddon(true)
            Memory.DoClean(false, true)
        end, 10000)
    else
        zo_callLater(function()
            d(M.chat .. " |cFF0000Currently Disabled!|r |cFFFFFFType /memory to enable.|r")
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