local ADDON_NAME = "GuildInviteBlocker"
local EVENT_NAMESPACE = ADDON_NAME .. "Events"

local DEFAULTS = {
    enabled = false,
}

local enabled = false

local function Chat(message)
    CHAT_ROUTER:AddSystemMessage(message)
end

local function StatusMessage()
    if enabled then
        Chat("Guild invite blocker is enabled. Incoming guild invites are auto-declined.")
    else
        Chat("Guild invite blocker is disabled")
    end
end

local function DeclineAllGuildInvites()
    while GetNumGuildInvites() > 0 do
        local guildId = GetGuildInviteInfo(1)
        RejectGuildInvite(guildId)
    end
end

local function OnGuildInviteEvent()
    if enabled then
        DeclineAllGuildInvites()
    end
end

local function RegisterGuildInviteEvents()
    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE, EVENT_GUILD_INVITE_ADDED, OnGuildInviteEvent)
    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE, EVENT_GUILD_INVITES_INITIALIZED, OnGuildInviteEvent)
    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE, EVENT_PLAYER_ACTIVATED, OnGuildInviteEvent)
end

local function UnregisterGuildInviteEvents()
    EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE, EVENT_GUILD_INVITE_ADDED)
    EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE, EVENT_GUILD_INVITES_INITIALIZED)
    EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE, EVENT_PLAYER_ACTIVATED)
end

local function SaveEnabled()
    GuildInviteBlocker_SavedVars = GuildInviteBlocker_SavedVars or ZO_SavedVars:NewAccountWide("GuildInviteBlocker_SavedVars", 1, nil, DEFAULTS)
    GuildInviteBlocker_SavedVars.enabled = enabled
end

local function SetEnabled(newEnabled)
    enabled = newEnabled
    SaveEnabled()

    if enabled then
        RegisterGuildInviteEvents()
        DeclineAllGuildInvites()
        Chat("Guild invite blocker enabled.")
    else
        UnregisterGuildInviteEvents()
        Chat("Guild invite blocker disabled.")
    end
end

local function ParseSlashCommand(option)
    option = zo_strlower(zo_strtrim(option or ""))

    if option == "" or option == "status" then
        StatusMessage()
        return
    end

    if option == "on" or option == "enable" then
        if not enabled then
            SetEnabled(true)
        else
            Chat("Guild invite blocker is already enabled.")
        end
        return
    end

    if option == "off" or option == "disable" then
        if enabled then
            SetEnabled(false)
        else
            Chat("Guild invite blocker is already disabled.")
        end
        return
    end

    if option == "toggle" then
        SetEnabled(not enabled)
        return
    end

    Chat("Usage: /giblock [on|off|toggle|status]")
end

local function OnAddOnLoaded(_, addonName)
    if addonName ~= ADDON_NAME then
        return
    end

    EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE, EVENT_ADD_ON_LOADED)

    GuildInviteBlocker_SavedVars = ZO_SavedVars:NewAccountWide("GuildInviteBlocker_SavedVars", 1, nil, DEFAULTS)
    enabled = GuildInviteBlocker_SavedVars.enabled

    SLASH_COMMANDS["/giblock"] = ParseSlashCommand

    if enabled then
        RegisterGuildInviteEvents()
        -- Decline any invites that arrived before the addon finished loading.
        zo_callLater(DeclineAllGuildInvites, 0)
    end

    Chat("Guild Invite Blocker loaded. Type |cFFFFFF|h/giblock|r for help.")
end

EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
