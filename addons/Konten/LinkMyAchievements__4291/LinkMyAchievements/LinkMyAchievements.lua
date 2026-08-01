local ADDON_NAME = "LinkMyAchievements"
local FAKE_DATE_MAX = GetTimeStamp()

local achievementLinks = {
    vRG  = { id = 2987, release = 1622332800 }, -- May 30, 2021
    vSS  = { id = 2435, release = 1558310400 }, -- May 20, 2019
    vMoL = { id = 1368, release = 1457040000 }, -- March 4, 2016
    vHoF = { id = 1810, release = 1496707200 }, -- June 6, 2017
    vAS  = { id = 2077, release = 1510012800 }, -- November 7, 2017
    vCR  = { id = 2133, release = 1526860800 }, -- May 21, 2018
    vKA  = { id = 2734, release = 1590451200 }, -- May 26, 2020
    vDSR = { id = 3244, release = 1655769600 }, -- June 21, 2022
    vSE  = { id = 3560, release = 1685923200 }, -- June 5, 2023
    vLC  = { id = 4015, release = 1718668800 }, -- June 18, 2024
    vOC  = { id = 4268, release = 1748822400 }, -- June 2, 2025
}

local function GetPreferredChatChannel()
    if IsUnitGrouped("player") then
        return CHAT_CHANNEL_PARTY
    elseif GetGuildId(1) ~= 0 then
        return CHAT_CHANNEL_GUILD_1
    else
        return CHAT_CHANNEL_SAY
    end
end

local function PostToChat(text)
    local channel = GetPreferredChatChannel()
    if channel then
        StartChatInput(text, channel)
    else
        d(string.format("[%s] Unable to determine chat channel.", ADDON_NAME))
    end
end

local function GetRandomTimestamp(min, max)
    return math.random(min, max)
end

local function HandleLinkCommand(arg)
    if not arg or arg == "" then
        d(string.format("[%s] Usage: /link <trial> or /link list", ADDON_NAME))
        return
    end

    arg = string.lower(arg)  -- normalize user input (case-insensitive)

    if arg == "list" then
        local keys = {}
        for key in pairs(achievementLinks) do
            table.insert(keys, key)
        end
        d(string.format("[%s] Available trials: %s", ADDON_NAME, table.concat(keys, ", ")))
        return
    end

    local data
    for key, info in pairs(achievementLinks) do
        if string.lower(key) == arg then
            data = info
            break
        end
    end

    if not data then
        d(string.format("[%s] Unknown trial '%s'. Use /link list.", ADDON_NAME, arg))
        return
    end

    local id = data.id
    local completed = IsAchievementComplete(id)
    local timestamp

    if completed then
        timestamp = GetAchievementTimestamp(id)
        if not timestamp or timestamp == 0 then
            timestamp = GetTimeStamp()
        end
    else
        timestamp = GetRandomTimestamp(data.release, FAKE_DATE_MAX)
    end

    local link = string.format("|H1:achievement:%d:1:%d|h|h", id, timestamp)
    local message = string.format("%s", link)

    PostToChat(message)
end


local function OnAddOnLoaded(event, addonName)
    if addonName ~= ADDON_NAME then return end
    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)

    math.randomseed(GetTimeStamp())
    SLASH_COMMANDS["/link"] = HandleLinkCommand

    d(string.format("[%s] Loaded. Type /link list to view supported trials.", ADDON_NAME))
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
