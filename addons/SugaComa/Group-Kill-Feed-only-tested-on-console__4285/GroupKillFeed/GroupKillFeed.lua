-- GroupKillFeed.lua
-- Author: SugaComa
-- Version: 1.3.5
-- PvP kill feed filtered to only you and your group (console safe)

GroupKillFeed = GroupKillFeed or {}
GroupKillFeed.name = "GroupKillFeed"
GroupKillFeed.version = "1.3.5"

-- Default state
GroupKillFeed.enabled = true

--------------------------------------------------------
-- Utility: Safe print to chat (no prefixes)
--------------------------------------------------------
local function Print(msg)
    if CHAT_SYSTEM and CHAT_SYSTEM.AddMessage then
        CHAT_SYSTEM:AddMessage(tostring(msg))
    else
        d(tostring(msg))
    end
end

--------------------------------------------------------
-- Utility: Faction Colors (Pastel shades)
--------------------------------------------------------
local FACTION_COLORS = {
    [ALLIANCE_ALDMERI_DOMINION]     = "|cE6E68A", -- pastel yellow
    [ALLIANCE_DAGGERFALL_COVENANT] = "|c8AAAE6", -- pastel blue
    [ALLIANCE_EBONHEART_PACT]      = "|cE68A8A", -- pastel red
    [ALLIANCE_NONE]                = "|cFFFFFF", -- fallback white
}

--------------------------------------------------------
-- Utility: Strip @ from display names
--------------------------------------------------------
local function CleanName(name)
    if not name or name == "" then return "Unknown" end
    if string.sub(name, 1, 1) == "@" then
        return string.sub(name, 2)
    end
    return name
end

--------------------------------------------------------
-- Utility: Group or Player Check
--------------------------------------------------------
local function IsMeOrGroup(displayName)
    if not displayName or displayName == "" then return false end
    if displayName == CleanName(GetUnitDisplayName("player")) then
        return true
    end
    for i = 1, GetGroupSize() do
        local tag = GetGroupUnitTagByIndex(i)
        if tag and DoesUnitExist(tag) then
            if CleanName(GetUnitDisplayName(tag)) == displayName then
                return true
            end
        end
    end
    return false
end

--------------------------------------------------------
-- Utility: Get refined location (POI > Zone fallback)
--------------------------------------------------------
local function GetRefinedLocation()
    local location = GetPlayerLocationName()
    if not location or location == "" then
        location = GetUnitZone("player")
    end
    if not location or location == "" then
        location = "Unknown Location"
    end
    return location
end

--------------------------------------------------------
-- Slash Commands
--------------------------------------------------------
SLASH_COMMANDS["/gkfon"] = function()
    GroupKillFeed.enabled = true
    Print("|c00FF00Kill feed ON|r")
end

SLASH_COMMANDS["/gkfoff"] = function()
    GroupKillFeed.enabled = false
    Print("|cFF0000Kill feed OFF|r")
end

SLASH_COMMANDS["/gkfstatus"] = function()
    local state = GroupKillFeed.enabled and "|c00FF00ON|r" or "|cFF0000OFF|r"
    Print("Kill feed is currently " .. state)
end

-- Test command: /gkfdeath [optional location]
SLASH_COMMANDS["/gkfdeath"] = function(text)
    local playerName     = CleanName(GetUnitDisplayName("player"))
    local playerAlliance = GetUnitAlliance("player")
    local playerColor    = FACTION_COLORS[playerAlliance] or "|cFFFFFF"
    local gkfColor       = "|cC68AE6" -- purple fake killer

    local location = text and text ~= "" and text or GetRefinedLocation()
    if not location or location == "" then location = "Unknown Location" end

    local msg = string.format("%sYou|r died to %sGKF|r near %s", 
        playerColor, gkfColor, location)
    Print(msg)
end

--------------------------------------------------------
-- Recurrence tracker (prevents double posts)
--------------------------------------------------------
local g_killRecurrenceTracker = ZO_RecurrenceTracker:New(5000, 5000)

--------------------------------------------------------
-- Message Builder (can be overridden by FunKillFeed)
--------------------------------------------------------
function GroupKillFeed.BuildMessage(killerDisplayName, killerAlliance, victimDisplayName, victimAlliance, location)
    local playerName     = CleanName(GetUnitDisplayName("player"))
    local playerAlliance = GetUnitAlliance("player")
    local playerColor    = FACTION_COLORS[playerAlliance] or "|cFFFFFF"

    local killerColor = FACTION_COLORS[killerAlliance] or "|cFFFFFF"
    local victimColor = FACTION_COLORS[victimAlliance] or "|cFFFFFF"

    if killerDisplayName == playerName then
        return playerColor .. "You|r killed " .. victimColor .. victimDisplayName .. "|r near " .. location
    elseif victimDisplayName == playerName then
        return playerColor .. "You|r died to " .. killerColor .. killerDisplayName .. "|r near " .. location
    else
        return killerColor .. killerDisplayName .. "|r → " .. victimColor .. victimDisplayName .. "|r near " .. location
    end
end

--------------------------------------------------------
-- Main event: PvP kill feed
--------------------------------------------------------
local function OnKillFeed(_, killLocation, killerDisplayName, killerCharacterName, killerAlliance, killerRank,
                          victimDisplayName, victimCharacterName, victimAlliance, victimRank, isKillLocation)

    if not GroupKillFeed.enabled then return end

    killerDisplayName = CleanName(killerDisplayName)
    victimDisplayName = CleanName(victimDisplayName)

    -- Deduplicate local vs killLocation events
    local messageKeySuffix = string.format("%s___%s", killerDisplayName, victimDisplayName)
    local messageKeyLocal = "L" .. messageKeySuffix
    local messageKeyKillLocation = "B" .. messageKeySuffix

    if isKillLocation then
        if g_killRecurrenceTracker:RemoveValue(messageKeyLocal) ~= nil then return end
        g_killRecurrenceTracker:AddValue(messageKeyKillLocation)
    else
        if g_killRecurrenceTracker:RemoveValue(messageKeyKillLocation) ~= nil then return end
        g_killRecurrenceTracker:AddValue(messageKeyLocal)
    end

    -- Filter: only you or group
    local killerRelevant = IsMeOrGroup(killerDisplayName)
    local victimRelevant = IsMeOrGroup(victimDisplayName)
    if not (killerRelevant or victimRelevant) then return end

    -- Location
    local location = killLocation
    if not location or location == "" then
        location = GetRefinedLocation()
    end

    -- Message
    local msg = GroupKillFeed.BuildMessage(
        killerDisplayName, killerAlliance, 
        victimDisplayName, victimAlliance, 
        location
    )

    Print(msg)
end

--------------------------------------------------------
-- On Addon Loaded
--------------------------------------------------------
local function OnAddonLoaded(_, addonName)
    if addonName ~= GroupKillFeed.name then return end

    EVENT_MANAGER:RegisterForEvent(GroupKillFeed.name, EVENT_PVP_KILL_FEED_DEATH, OnKillFeed)
    EVENT_MANAGER:UnregisterForEvent(GroupKillFeed.name, EVENT_ADD_ON_LOADED)

    Print("GroupKillFeed v" .. GroupKillFeed.version .. " active (solo & group).")
end

--------------------------------------------------------
-- Status Command
--------------------------------------------------------
SLASH_COMMANDS["/gkfstatus"] = function()
    local gkfLoaded = (GroupKillFeed ~= nil)
    local funLoaded = (FunKillFeed ~= nil)
    local funEnabled = (funLoaded and FunKillFeed.enabled)

    local gkfStatus = gkfLoaded and "|c00FF00LOADED|r" or "|cFF0000MISSING|r"
    local funStatus
    if not funLoaded then
        funStatus = "|cFF0000NOT INSTALLED|r"
    elseif funEnabled then
        funStatus = "|c00FF00ENABLED|r"
    else
        funStatus = "|cFF0000DISABLED|r"
    end

    d("GroupKillFeed status:")
    d(string.format("• GroupKillFeed: %s", gkfStatus))
    d(string.format("• FunKillFeed: %s", funStatus))

    if funLoaded and funEnabled then
        d("|cAAAAFFFunKillFeed active — expect chaos and giggles.|r")
    elseif funLoaded and not funEnabled then
        d("|c888888FunKillFeed installed but currently muted.|r")
    end
end

EVENT_MANAGER:RegisterForEvent(GroupKillFeed.name, EVENT_ADD_ON_LOADED, OnAddonLoaded)
