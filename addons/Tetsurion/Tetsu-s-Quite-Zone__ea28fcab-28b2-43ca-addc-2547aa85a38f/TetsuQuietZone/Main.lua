local ADDON_NAME = "TetsuQuietZone"
TetsuQuietZone = TetsuQuietZone or {}
local T = TetsuQuietZone

T.hiddenCount = 0

local defaultAccountVars = {
    enabled = true,
    filterZone = true,
    filterSay = true,
    filterYell = false,
    mutedGuilds = {},
}

local zoneChannels
local guildChannelToSlot
local hooked = false

local function Vars()
    return T.savedVars
end

local function AddChannel(set, id)
    if type(id) == "number" then
        set[id] = true
    end
end

local function BuildZoneSet()
    local set = {}
    AddChannel(set, CHAT_CHANNEL_ZONE)
    AddChannel(set, CHAT_CHANNEL_ZONE_ENGLISH)
    AddChannel(set, CHAT_CHANNEL_ZONE_FRENCH)
    AddChannel(set, CHAT_CHANNEL_ZONE_GERMAN)
    AddChannel(set, CHAT_CHANNEL_ZONE_JAPANESE)
    AddChannel(set, CHAT_CHANNEL_ZONE_RUSSIAN)
    AddChannel(set, CHAT_CHANNEL_ZONE_SPANISH)
    AddChannel(set, CHAT_CHANNEL_ZONE_CHINESE_S)
    for i = 1, 8 do
        AddChannel(set, _G["CHAT_CHANNEL_ZONE_LANGUAGE_" .. i])
    end
    zoneChannels = set
end

local function BuildGuildChannelMap()
    local map = {}
    for slot = 1, 5 do
        local guildCh = _G["CHAT_CHANNEL_GUILD_" .. slot]
        local officerCh = _G["CHAT_CHANNEL_OFFICER_" .. slot]
        if type(guildCh) == "number" then
            map[guildCh] = slot
        end
        if type(officerCh) == "number" then
            map[officerCh] = slot
        end
    end
    guildChannelToSlot = map
end

local function IsSay(channel)
    return channel == CHAT_CHANNEL_SAY
end

local function IsYell(channel)
    return channel == CHAT_CHANNEL_YELL
end

local function IsZone(channel)
    if not zoneChannels then
        BuildZoneSet()
    end
    return channel and zoneChannels[channel] == true
end

local function ChannelWatched(channel)
    local v = Vars()
    if not v or v.enabled == false then
        return false
    end
    if IsZone(channel) then
        return v.filterZone ~= false
    end
    if IsSay(channel) then
        return v.filterSay ~= false
    end
    if IsYell(channel) then
        return v.filterYell == true
    end
    return false
end

-- Language-independent: client markup always carries :guild: inside |H…|h.
local function HasGuildLink(text)
    if type(text) ~= "string" or text == "" then
        return false
    end
    if text:find("|H%d*:guild:", 1) then
        return true
    end
    if text:find("|Hguild:", 1, true) then
        return true
    end
    return false
end

local function MutedTable()
    local v = Vars()
    if not v then
        return nil
    end
    if type(v.mutedGuilds) ~= "table" then
        v.mutedGuilds = {}
    end
    return v.mutedGuilds
end

function T.IsGuildMuted(guildId)
    if not guildId or guildId == 0 then
        return false
    end
    local muted = MutedTable()
    if not muted then
        return false
    end
    return muted[tostring(guildId)] == true
end

function T.SetGuildMuted(guildId, muted)
    if not guildId or guildId == 0 then
        return
    end
    local t = MutedTable()
    if not t then
        return
    end
    local key = tostring(guildId)
    if muted then
        t[key] = true
    else
        t[key] = nil
    end
end

local function IsMutedGuildChannel(channel)
    if not guildChannelToSlot then
        BuildGuildChannelMap()
    end
    local slot = channel and guildChannelToSlot[channel]
    if not slot then
        return false
    end
    local guildId = GetGuildId(slot)
    return T.IsGuildMuted(guildId)
end

local function ShouldHide(channel, text, isCustomerService)
    if isCustomerService then
        return false
    end
    if IsMutedGuildChannel(channel) then
        return true
    end
    if not ChannelWatched(channel) then
        return false
    end
    return HasGuildLink(text)
end

local function NoteHidden()
    T.hiddenCount = (tonumber(T.hiddenCount) or 0) + 1
end

-- FormatAndAddChatMessage(eventId, ...)
-- EVENT_CHAT_MESSAGE_CHANNEL args: messageType, fromName, text, isFromCS, fromDisplayName
local function OnFormat(_, eventId, ...)
    if eventId ~= EVENT_CHAT_MESSAGE_CHANNEL then
        return false
    end
    local messageType, _, text, isFromCS = ...
    if ShouldHide(messageType, text, isFromCS) then
        NoteHidden()
        return true
    end
    return false
end

local function HookRouter()
    if hooked then
        return
    end
    if not CHAT_ROUTER or not CHAT_ROUTER.FormatAndAddChatMessage then
        return
    end
    ZO_PreHook(CHAT_ROUTER, "FormatAndAddChatMessage", OnFormat)
    hooked = true
end

function T.Start()
    BuildZoneSet()
    BuildGuildChannelMap()
    HookRouter()
end

local function OnAddOnLoaded(_, addonName)
    if addonName ~= ADDON_NAME then return end
    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)

    T.savedVars = ZO_SavedVars:NewAccountWide(
        "TetsuQuietZoneSavedVars",
        1,
        nil,
        defaultAccountVars
    )
    if type(T.savedVars.mutedGuilds) ~= "table" then
        T.savedVars.mutedGuilds = {}
    end

    T.Start()
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_PLAYER_ACTIVATED, function()
        T.Start()
        if not T.settingsRegistered and T.RegisterSettings then
            T.RegisterSettings()
            T.settingsRegistered = true
        end
    end)
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
