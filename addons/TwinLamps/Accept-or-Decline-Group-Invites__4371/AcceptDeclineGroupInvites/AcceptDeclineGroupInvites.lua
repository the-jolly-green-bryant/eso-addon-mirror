local ADDON_NAME = "AcceptDeclineGroupInvites"
local ADGI = {}
ADGI.name = ADDON_NAME

------------------------------------------------------------
-- SavedVars defaults
------------------------------------------------------------
ADGI.defaults = {
    enabled = true,
    autoDecline = false,
    zones = {
        cyro = true,
        ic = true,
        pve = false,
    },
    filters = {
        friends = true,
        guildAny = true,
        guildSpecific = false,
        anybody = false,
        nobody = false,
    },
    guildFilters = {},
    chatFeedback = true,
}

------------------------------------------------------------
-- Utility: Chat
------------------------------------------------------------
local function Msg(text)
    if ADGI.saved and ADGI.saved.chatFeedback then
        d("|c88CCFF[ADGI]|r " .. text)
    end
end

local function NormalizeName(name)
    if not name or name == "" then return "" end
    name = zo_strformat("<<1>>", name):gsub("%s+", ""):gsub("^@", ""):lower()
    return name
end

------------------------------------------------------------
-- Utility: Zone check
------------------------------------------------------------
local function IsInAllowedZone()
    local zoneId = GetZoneId(GetUnitZoneIndex("player"))
    local parentId = GetParentZoneId(zoneId)

    if parentId == 181 and ADGI.saved.zones.cyro then return true end
    if parentId == 584 and ADGI.saved.zones.ic then return true end
    if parentId ~= 181 and parentId ~= 584 and ADGI.saved.zones.pve then return true end
    return false
end

------------------------------------------------------------
-- Utility: Friends
------------------------------------------------------------
local function IsFriend(inviterDisplayName)
    local normInviter = NormalizeName(inviterDisplayName)
    local numFriends = GetNumFriends()
    for i = 1, numFriends do
        local displayName = GetFriendInfo(i)
        if NormalizeName(displayName) == normInviter then return true end
    end
    return false
end

------------------------------------------------------------
-- Utility: Guild membership
------------------------------------------------------------
local function IsInAnyGuild(inviterDisplayName)
    local normInviter = NormalizeName(inviterDisplayName)
    for guildIndex = 1, GetNumGuilds() do
        local guildId = GetGuildId(guildIndex)
        local numMembers = GetNumGuildMembers(guildId)
        for i = 1, numMembers do
            local displayName = GetGuildMemberInfo(guildId, i)
            if NormalizeName(displayName) == normInviter then return true, guildId end
        end
    end
    return false, nil
end

local function IsInSpecificGuilds(inviterDisplayName)
    local normInviter = NormalizeName(inviterDisplayName)
    local anyChecked = false
    for _, checked in pairs(ADGI.saved.guildFilters) do
        if checked then anyChecked = true; break end
    end
    if not anyChecked then return false, nil end

    for guildIndex = 1, GetNumGuilds() do
        local guildId = GetGuildId(guildIndex)
        if ADGI.saved.guildFilters[guildId] then
            local numMembers = GetNumGuildMembers(guildId)
            for i = 1, numMembers do
                local displayName = GetGuildMemberInfo(guildId, i)
                if NormalizeName(displayName) == normInviter then return true, guildId end
            end
        end
    end
    return false, nil
end

------------------------------------------------------------
-- Utility: Inviter allowed? (OR logic)
------------------------------------------------------------
local function IsInviterAllowed(inviterDisplayName)
    local f = ADGI.saved.filters

    if f.nobody then return false, nil end
    if f.anybody then return true, nil end
    if f.friends and IsFriend(inviterDisplayName) then return true, nil end
    if f.guildAny then
        local inAny, guildId = IsInAnyGuild(inviterDisplayName)
        if inAny then return true, guildId end
    end
    if f.guildSpecific then
        local inSpec, guildId = IsInSpecificGuilds(inviterDisplayName)
        if inSpec then return true, guildId end
    end
    return false, nil
end

------------------------------------------------------------
-- Event: Group invite received
------------------------------------------------------------
local function OnGroupInvite(eventCode, inviterCharacterName, inviterDisplayName)
    if not inviterDisplayName or inviterDisplayName == "" then
        Msg("Ignored invalid invite (no display name).")
        return
    end

    if not IsInAllowedZone() then
        if ADGI.saved.autoDecline then
            DeclineGroupInvite()
            Msg("Declined invite from " .. (inviterCharacterName or "Unknown") .. " (zone not allowed).")
        else
            Msg("Ignored invite from " .. (inviterCharacterName or "Unknown") .. " (zone not allowed).")
        end
        return
    end

    local allowed, guildId = IsInviterAllowed(inviterDisplayName)

    if allowed then
        if ADGI.saved.enabled then
            AcceptGroupInvite()
            local guildMsg = guildId and " (" .. GetGuildName(guildId) .. ")" or ""
            Msg("Accepted invite from " .. (inviterCharacterName or "Unknown") .. guildMsg .. ".")
        else
            Msg("Invite from " .. (inviterCharacterName or "Unknown") .. " matches filters (auto accept off).")
        end
    else
        if ADGI.saved.autoDecline then
            DeclineGroupInvite()
            Msg("Declined invite from " .. (inviterCharacterName or "Unknown") .. " (not allowed by filters).")
        else
            Msg("Ignored invite from " .. (inviterCharacterName or "Unknown") .. " (not allowed by filters).")
        end
    end
end

------------------------------------------------------------
-- Dynamic guild checkbox builder
------------------------------------------------------------
local function BuildGuildCheckboxes()
    local controls = {}

    for guildIndex = 1, GetNumGuilds() do
        local guildId = GetGuildId(guildIndex)
        local guildName = GetGuildName(guildId)

        if ADGI.saved.guildFilters[guildId] == nil then
            ADGI.saved.guildFilters[guildId] = false
        end

        table.insert(controls, {
            type = "checkbox",
            name = guildName,
            getFunc = function()
                return ADGI.saved.guildFilters[guildId]
            end,
            setFunc = function(v)
                ADGI.saved.guildFilters[guildId] = v
            end,
            disabled = function()
                return not ADGI.saved.filters.guildSpecific or ADGI.saved.filters.anybody or ADGI.saved.filters.nobody
            end,
            width = "full",
        })
    end

    return controls
end

------------------------------------------------------------
-- Settings: LibAddonMenu 2.0
------------------------------------------------------------
local function CreateSettingsMenu()
    local LAM = LibAddonMenu2
    if not LAM then return end

    local panelData = {
        type = "panel",
        name = "Accept or Decline Group Invites",
        displayName = "Accept or Decline Group Invites",
        author = "@TwinLamps (PC/NA)",
        version = "1.1",
        registerForRefresh = true,
        registerForDefaults = true,
    }

    LAM:RegisterAddonPanel(ADDON_NAME .. "Panel", panelData)

    local options = {
        {
            type = "description",
            text = "Select what restrictions to apply for auto accepting or auto declining group invites.",
            width = "full",
        },

        {
            type = "header",
            name = "General Settings",
        },
        {
            type = "checkbox",
            name = "Enable Auto Accept",
            getFunc = function() return ADGI.saved.enabled end,
            setFunc = function(v) ADGI.saved.enabled = v end,
            width = "full",
        },
        {
            type = "checkbox",
            name = "Auto Decline if Disqualified",
            getFunc = function() return ADGI.saved.autoDecline end,
            setFunc = function(v) ADGI.saved.autoDecline = v end,
            width = "full",
        },

        {
            type = "header",
            name = "Zones",
        },
        {
            type = "checkbox",
            name = "Cyrodiil",
            getFunc = function() return ADGI.saved.zones.cyro end,
            setFunc = function(v) ADGI.saved.zones.cyro = v end,
        },
        {
            type = "checkbox",
            name = "Imperial City (all areas)",
            getFunc = function() return ADGI.saved.zones.ic end,
            setFunc = function(v) ADGI.saved.zones.ic = v end,
        },
        {
            type = "checkbox",
            name = "PvE Zones (everywhere else)",
            getFunc = function() return ADGI.saved.zones.pve end,
            setFunc = function(v) ADGI.saved.zones.pve = v end,
        },

                {
            type = "header",
            name = "Invite Source Filters",
        },
        {
            type = "description",
            text = "An invite is allowed if it matches ANY checked filter below. Anybody overrides all other filters.",
            width = "full",
        },

        -- Nobody (Decline All) - highest priority, disables almost everything
        {
            type = "checkbox",
            name = "Nobody (Decline All)",
            tooltip = "Decline every group invite automatically, regardless of source or zone. Overrides all other filters.",
            getFunc = function() return ADGI.saved.filters.nobody end,
            setFunc = function(v)
                local f = ADGI.saved.filters
                if v then
                    f.nobody = true
                    f.friends = false
                    f.guildAny = false
                    f.guildSpecific = false
                    f.anybody = false
                else
                    f.nobody = false
                end
                zo_callLater(function()
                    LibAddonMenu2:RefreshPanel(ADDON_NAME .. "Panel")
                end, 50)
            end,
            width = "full",
        },

        -- Friends
        {
            type = "checkbox",
            name = "Friends",
            getFunc = function() return ADGI.saved.filters.friends end,
            setFunc = function(v) ADGI.saved.filters.friends = v end,
            disabled = function() 
                return ADGI.saved.filters.anybody 
                    or ADGI.saved.filters.nobody 
            end,
            width = "full",
        },

        -- Any Guild Member ↔ Specific Guilds are mutually exclusive
        {
            type = "checkbox",
            name = "Any Guild Member",
            getFunc = function() return ADGI.saved.filters.guildAny end,
            setFunc = function(v)
                local f = ADGI.saved.filters
                f.guildAny = v
                if v then
                    f.guildSpecific = false   -- turn off the conflicting option
                end
                zo_callLater(function()
                    LibAddonMenu2:RefreshPanel(ADDON_NAME .. "Panel")
                end, 50)
            end,
            disabled = function() 
                return ADGI.saved.filters.anybody 
                    or ADGI.saved.filters.nobody 
            end,
            width = "full",
        },

        {
            type = "checkbox",
            name = "Specific Guilds",
            getFunc = function() return ADGI.saved.filters.guildSpecific end,
            setFunc = function(v)
                local f = ADGI.saved.filters
                f.guildSpecific = v
                if v then
                    f.guildAny = false   -- turn off the conflicting option
                end
                zo_callLater(function()
                    LibAddonMenu2:RefreshPanel(ADDON_NAME .. "Panel")
                end, 50)
            end,
            disabled = function() 
                return ADGI.saved.filters.anybody 
                    or ADGI.saved.filters.nobody 
            end,
            width = "full",
        },

        -- Anybody - disables Nobody when turned on
        {
            type = "checkbox",
            name = "Anybody",
            getFunc = function() return ADGI.saved.filters.anybody end,
            setFunc = function(v)
                local f = ADGI.saved.filters
                f.anybody = v
                if v then
                    f.nobody = false   -- turn off Nobody if Anybody is selected
                end
                zo_callLater(function()
                    LibAddonMenu2:RefreshPanel(ADDON_NAME .. "Panel")
                end, 50)
            end,
            width = "full",
        },

        {
            type = "description",
            text = "Specific Guilds: if checked, only members of the selected guilds are allowed. If none are selected, no guildmates are allowed.",
            width = "full",
            disabled = function()
                return not ADGI.saved.filters.guildSpecific 
                    or ADGI.saved.filters.anybody 
                    or ADGI.saved.filters.nobody
            end,
        },
    }

    -- Append dynamic guild checkboxes
    local guildControls = BuildGuildCheckboxes()
    for _, control in ipairs(guildControls) do
        table.insert(options, control)
    end

    -- Feedback section
    table.insert(options, {
        type = "header",
        name = "Feedback",
    })
    table.insert(options, {
        type = "checkbox",
        name = "Show chat feedback",
        getFunc = function() return ADGI.saved.chatFeedback end,
        setFunc = function(v) ADGI.saved.chatFeedback = v end,
    })

    LAM:RegisterOptionControls(ADDON_NAME .. "Panel", options)
end

------------------------------------------------------------
-- Slash commands
------------------------------------------------------------
local function HandleSlashCommand(text)
    text = text or ""
    text = text:lower()
    local args = {}
    for word in text:gmatch("%S+") do
        table.insert(args, word)
    end

    local cmd = args[1]

    if cmd == "on" then
        ADGI.saved.enabled = true
        Msg("Auto accept enabled.")
        return
    elseif cmd == "off" then
        ADGI.saved.enabled = false
        Msg("Auto accept disabled.")
        return
    elseif cmd == "decline" then
        local sub = args[2]
        if sub == "on" then
            ADGI.saved.autoDecline = true
            Msg("Auto decline enabled.")
        elseif sub == "off" then
            ADGI.saved.autoDecline = false
            Msg("Auto decline disabled.")
        else
            Msg("Usage: /adgi decline on or off")
        end
        return
    elseif cmd == "friend" then
        ADGI.saved.filters = {
            friends = true,
            guildAny = false,
            guildSpecific = false,
            anybody = false,
            nobody = false,
        }
        Msg("Filter set to Friends only.")
        return
    elseif cmd == "any" then
        ADGI.saved.filters = {
            friends = false,
            guildAny = false,
            guildSpecific = false,
            anybody = true,
            nobody = false,
        }
        Msg("Filter set to Anybody.")
        return
    elseif cmd == "guilds" then
        ADGI.saved.filters = {
            friends = false,
            guildAny = false,
            guildSpecific = true,
            anybody = false,
            nobody = false,
        }

        for guildId, _ in pairs(ADGI.saved.guildFilters) do
            ADGI.saved.guildFilters[guildId] = false
        end

        if #args > 1 then
            for i = 2, #args do
                local index = tonumber(args[i]:match("g(%d)"))
                if index and index >= 1 and index <= GetNumGuilds() then
                    local guildId = GetGuildId(index)
                    if guildId and guildId ~= 0 then
                        ADGI.saved.guildFilters[guildId] = true
                    end
                end
            end
            Msg("Specific Guilds mode enabled. Selected guilds applied.")
        else
            Msg("Specific Guilds mode enabled. No guilds selected.")
        end
        return
    elseif cmd == "status" then
        Msg("Status: " .. (ADGI.saved.enabled and "Auto Accept ON" or "Auto Accept OFF"))
        Msg("Auto Decline: " .. (ADGI.saved.autoDecline and "ON" or "OFF"))

        local f = ADGI.saved.filters
        local activeFilters = {}

        if f.nobody then
            table.insert(activeFilters, "Nobody (Decline All)")
        elseif f.anybody then
            table.insert(activeFilters, "Anybody")
        else
            if f.friends then table.insert(activeFilters, "Friends") end
            if f.guildAny then table.insert(activeFilters, "Any Guild Member") end
            if f.guildSpecific then table.insert(activeFilters, "Specific Guilds") end
        end

        if #activeFilters == 0 then
            Msg("Invite filters: NONE")
        else
            Msg("Invite filters: " .. table.concat(activeFilters, ", "))
        end

        if f.guildSpecific then
            local selected = {}
            local anyChecked = false

            for guildIndex = 1, GetNumGuilds() do
                local guildId = GetGuildId(guildIndex)
                if ADGI.saved.guildFilters[guildId] then
                    table.insert(selected, GetGuildName(guildId))
                    anyChecked = true
                end
            end

            if anyChecked then
                Msg("Specific Guilds whitelist:")
                for _, name in ipairs(selected) do
                    Msg(" - " .. name)
                end
            else
                Msg("Specific Guilds whitelist: NONE")
            end
        end

        return
    elseif cmd == "help" or cmd == nil or cmd == "" then
        Msg(
            "Commands:\n" ..
            "/adgi on - Enable auto accept\n" ..
            "/adgi off - Disable auto accept\n" ..
            "/adgi decline on or off - Enable or disable auto decline\n" ..
            "/adgi friend - Only allow friends\n" ..
            "/adgi any - Allow anybody\n" ..
            "/adgi guilds [g1 g2 g3 g4 g5] - Only allow specific guilds\n" ..
            "/adgi status - Show current settings\n" ..
            "/adgi help - Show this help"
        )
        return
    else
        Msg("Unknown command. Use /adgi help.")
    end
end

------------------------------------------------------------
-- Addon loaded
------------------------------------------------------------
local function OnAddonLoaded(event, addonName)
    if addonName ~= ADDON_NAME then return end
	
	EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)

    ADGI.saved = ZO_SavedVars:NewAccountWide("ADGISavedVariables", 1, GetWorldName(), ADGI.defaults)

    ADGI.saved.autoDecline = (ADGI.saved.autoDecline ~= nil) and ADGI.saved.autoDecline or ADGI.defaults.autoDecline
    ADGI.saved.filters = ADGI.saved.filters or {}
    if ADGI.saved.filters.friends == nil then ADGI.saved.filters.friends = ADGI.defaults.filters.friends end
    if ADGI.saved.filters.guildAny == nil then ADGI.saved.filters.guildAny = ADGI.defaults.filters.guildAny end
    if ADGI.saved.filters.guildSpecific == nil then ADGI.saved.filters.guildSpecific = ADGI.defaults.filters.guildSpecific end
    if ADGI.saved.filters.anybody == nil then ADGI.saved.filters.anybody = ADGI.defaults.filters.anybody end
    if ADGI.saved.filters.nobody == nil then ADGI.saved.filters.nobody = ADGI.defaults.filters.nobody end
    ADGI.saved.guildFilters = ADGI.saved.guildFilters or {}

    CreateSettingsMenu()

    EVENT_MANAGER:RegisterForEvent(
        ADDON_NAME,
        EVENT_GROUP_INVITE_RECEIVED,
        OnGroupInvite
    )

    SLASH_COMMANDS["/adgi"] = HandleSlashCommand
end

EVENT_MANAGER:RegisterForEvent(
    ADDON_NAME,
    EVENT_ADD_ON_LOADED,
    OnAddonLoaded
)