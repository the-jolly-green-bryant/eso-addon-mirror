GuildEvents = GuildEvents or {}
GuildEvents.AddonId = "GuildEvents"
-- one event per day
GuildEvents.maxEvents = 7
-- roles
GuildEvents.roleSelected = 0;


------------------------------------------------
--- Utility functions
------------------------------------------------
local function b(v) if v then return "T" else return "F" end end
local function nn(val) if val == nil then return "NIL" else return val end end
local function dbg(msg) if AutoInvite.debug then d("|c999999" .. msg) end end
local function echo(msg) CHAT_SYSTEM.primaryContainer.currentBuffer:AddMessage("|CFFFF00"..msg) end

------------------------------------------------
--- Event handlers
------------------------------------------------
CALLBACK_MANAGER:RegisterCallback("OnGuildSelected", function()
    if GuildEvents.initDone then
        local guildId = GUILD_SELECTOR.guildId
        GuildEventsUI.selectedGuildId = guildId
        GuildEventsUI:GetEvents()
        GuildEventsUI.create:refresh()
    end
end)

function GuildEvents.GuildMotdUpdated(eventCode, guildId)
    if guildId == GuildEventsUI.selectedGuildId then
        GuildEventsUI:GetEvents()
    end
end

function GuildEvents.MemberNoteChanged(eventCode, guildId, DisplayName, newNote)
    if guildId == GuildEventsUI.selectedGuildId then
        GuildEventsUI:GetEvents()
    end
end

function GuildEvents.GroupMemberJoined(eventCode, memberName)
    GuildEventsUI:GetEvents()
end

function GuildEvents.GroupMemberLeft(eventCode, memberName, reason, wasLocalPlayer)
    GuildEventsUI:GetEvents()
end

function GuildEvents.PlayerStatusChanged(eventCode, guildId, DisplayName, oldStatus, newStatus)
    
	-- 1 = Online
    -- 2 = Away
    -- 3 = Do not disturb
    -- 4 = Offline

    if GuildEvents.initDone then
        GuildEventsUI:GetEvents()
    end
end

------------------------------------------------
--- Initialization
------------------------------------------------
function GuildEvents.init()
    if GuildEvents.initDone then return end
    GuildEvents.initDone = true

    ZO_CreateStringId("SI_GUILD_EVENTS", "Events")

    GuildEventsUI.init()
end

------------------------------------------------
--- Events
------------------------------------------------
EVENT_MANAGER:RegisterForEvent(GuildEvents.AddonId, EVENT_ADD_ON_LOADED, GuildEvents.init)
EVENT_MANAGER:RegisterForEvent(GuildEvents.AddonId, EVENT_GUILD_MOTD_CHANGED, GuildEvents.GuildMotdUpdated)
EVENT_MANAGER:RegisterForEvent(GuildEvents.AddonId,  EVENT_GUILD_MEMBER_NOTE_CHANGED, GuildEvents.MemberNoteChanged)
EVENT_MANAGER:RegisterForEvent(GuildEvents.AddonId,  EVENT_GROUP_MEMBER_JOINED, GuildEvents.GroupMemberJoined)
EVENT_MANAGER:RegisterForEvent(GuildEvents.AddonId,  EVENT_GROUP_MEMBER_LEFT, GuildEvents.GroupMemberLeft)
EVENT_MANAGER:RegisterForEvent(GuildEvents.AddonId,  EVENT_GUILD_MEMBER_PLAYER_STATUS_CHANGED, GuildEvents.PlayerStatusChanged)