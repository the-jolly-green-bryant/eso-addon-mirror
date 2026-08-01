-- NORCalendar.lua — Event/MOTD parsing module for NOR Guild Tools

local Addon = NORGuildTools
Addon.Calendar = Addon.Calendar or {}
local Cal = Addon.Calendar

------------------------------------------------------------
-- Extract event details from the guild MOTD
------------------------------------------------------------
function Cal.GetEventDetails(sectionHeader, prefix)
    local guildId = 13021 -- NOR guild ID

    if not guildId then
        return "|cFF0000Error: Guild not found.|r"
    end

    local motd = GetGuildMotD(guildId)
    if not motd or motd == "" then
        return "|cFF0000Error: MOTD is empty.|r"
    end

    -- Capture text after the header until the next '++'
    local pattern = sectionHeader .. "(.-)%+%+"
    local sectionText = string.match(motd, pattern)

    if not sectionText then
        return "|cFF0000No details found for " .. sectionHeader .. ".|r"
    end

    -- Highlight time expressions like "3pm EST"
    sectionText = string.gsub(sectionText, "(%d+%s*[pP][mM]%s*EST)", "|c00FF00%1|r")

    -- Highlight Discord channels (#channel)
    sectionText = string.gsub(sectionText, "(#%S+)", "|c9999FF%1|r")

    -- Add icon and prefix
    local iconTag = "|t34:34:/NORGuildTools/Textures/norlogodds.dds|t"
    return "|c3366CC" .. iconTag .. " " .. prefix .. " " .. iconTag .. "|r\n"
        .. "|c3399FF" .. sectionHeader .. "|r\n"
        .. sectionText
end

------------------------------------------------------------
-- Slash commands for quick access
------------------------------------------------------------
SLASH_COMMANDS["/nor_trial"] = function()
    d(Cal.GetEventDetails("New OutRiders Trials:", "New OutRiders Trial:"))
end

SLASH_COMMANDS["/nor_event"] = function()
    d(Cal.GetEventDetails("New OutRiders Events:", "New OutRiders Event:"))
end
