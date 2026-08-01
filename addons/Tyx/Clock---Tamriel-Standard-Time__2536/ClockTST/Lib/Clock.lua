--[[--------------------------------------------
    Project:    Clock - Tamriel Standard Time
    Author:     Arne Rantzen (Tyx) & Phinix
    Created:    2020-02-16
    Updated:    2020-02-16
    License:    GPL-3.0
--------------------------------------------]]--
Clock_TST = Clock_TST or {}
local const = Clock_TST.CONSTANTS()
local eventHandle = const.DISPLAY

local Log
if LibDebugLogger then
    Log = LibDebugLogger(const.NAME)
end

--- Debug output to the console
--- @param ... string variable parameters to be printed as a debug log
function Clock_TST.Debug(...)
    if Log then
        Log:Debug(...)
    else
        d(...)
    end
end

--- Output to the console
--- @param ... string variable parameters to be printed as a log
function Clock_TST.Print(...)
    if Log then
        Log:Info(...)
    else
        CHAT_SYSTEM:AddMessage(...)
    end
end

--- Warning output to the console
--- @param ... string variable parameters to be printed as a log
function Clock_TST.Warn(...)
    if Log then
        Log:Warn(...)
    else
        for i = 1, select("#", ...) do
            -- Print each warning parameter in orange
            CHAT_SYSTEM:AddMessage(zo_strformat("|cFF7900<<1>>|r", select(i, ...)))
        end
    end
end

--- Initialize the Clock TST
--- @param _ number eventId doesn't matter
--- @param addonName string of the addon is Clock
local function OnLoad(_, addonName)
    if addonName ~= const.NAME then return end

    Clock_TST:SetupSettings()
    Clock_TST:SetupBindings()
    Clock_TST:SetupTime()
    Clock_TST:SetupMoon()
    Clock_TST:SetupMenu()

    -- wait for the first loaded event
    EVENT_MANAGER:UnregisterForEvent(eventHandle, EVENT_ADD_ON_LOADED)
end
EVENT_MANAGER:RegisterForEvent(eventHandle, EVENT_ADD_ON_LOADED, OnLoad)