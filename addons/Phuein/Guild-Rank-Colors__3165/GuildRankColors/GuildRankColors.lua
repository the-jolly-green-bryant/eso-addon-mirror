GuildRankColors = {
    name            = "GuildRankColors",            -- Matches folder and Manifest file names.
    author          = "Phuein",
    color           = "FFEE11",                     -- Used in menu titles and so on.
    menuName        = "Guild Rank Colors",          -- A UNIQUE identifier for menu object.
}

-- Default settings.
GuildRankColors.savedVars = {
    firstLoad = true,           -- First time the addon is loaded ever.
    accountWide = true,         -- Load settings from account savedVars, instead of character.
    guildRankColors = {
        [1] = {
            [1] = nil,
            [2] = nil,
            [3] = nil,
            [4] = nil,
            [5] = nil,
            [6] = nil,
            [7] = nil,
        },
        [2] = {
            [1] = nil,
            [2] = nil,
            [3] = nil,
            [4] = nil,
            [5] = nil,
            [6] = nil,
            [7] = nil,
        },
        [3] = {
            [1] = nil,
            [2] = nil,
            [3] = nil,
            [4] = nil,
            [5] = nil,
            [6] = nil,
            [7] = nil,
        },
        [4] = {
            [1] = nil,
            [2] = nil,
            [3] = nil,
            [4] = nil,
            [5] = nil,
            [6] = nil,
            [7] = nil,
        },
        [5] = {
            [1] = nil,
            [2] = nil,
            [3] = nil,
            [4] = nil,
            [5] = nil,
            [6] = nil,
            [7] = nil,
        },
    },
}

GuildRankColors.guildIdToIndex = {}

-- Wraps text with a color.
function GuildRankColors.Colorize(text, color)
    -- Default to addon's .color.
    if not color then color = GuildRankColors.color end

    text = string.format('|c%s%s|r', color, text)

    return text
end

local function updateGuildIndex()
    for i=1, GetNumGuilds() do
        GuildRankColors.guildIdToIndex[GetGuildId(i)] = i
    end
end

local function FindPlayerNameObject(control)
    for i = 1, control:GetNumChildren() do
        local child = control:GetChild(i)

        if child:GetName():find("DisplayName") then
            return child
        end
    end
end

local function UpdateNameColor(control)
    local guildIndex = GuildRankColors.guildIdToIndex[GUILD_ROSTER_MANAGER.guildId]
    local rankIndex = control.dataEntry.data.rankIndex

    if not guildIndex or not rankIndex then return end

    local color = GuildRankColors.savedVars.guildRankColors[guildIndex][rankIndex]

    if color then
        color = ZO_ColorDef:New(color)
        local displayNameControl = FindPlayerNameObject(control)

        displayNameControl:SetColor(color:UnpackRGB())
    end
end

function GuildRankColors.OnAddOnLoaded(event, addonName)
    if addonName ~= GuildRankColors.name then return end
    EVENT_MANAGER:UnregisterForEvent(GuildRankColors.name, EVENT_ADD_ON_LOADED)

    -- Load saved variables.
    GuildRankColors.characterSavedVars = ZO_SavedVars:New("GuildRankColorsSavedVariables", 1, nil, GuildRankColors.savedVars)
    GuildRankColors.accountSavedVars = ZO_SavedVars:NewAccountWide("GuildRankColorsSavedVariables", 1, nil, GuildRankColors.savedVars)

    if not GuildRankColors.characterSavedVars.accountWide then
        GuildRankColors.savedVars = GuildRankColors.characterSavedVars
    else
        GuildRankColors.savedVars = GuildRankColors.accountSavedVars
    end

    -- Settings menu in Settings.lua.
    GuildRankColors.LoadSettings()

    GUILD_ROSTER_SCENE:RegisterCallback("StateChange", function(oldState, newState)
        if newState == SCENE_SHOWING then
            updateGuildIndex()
        end
    end)

    ZO_PostHook(GUILD_ROSTER_MANAGER, "OnGuildIdChanged", function()
        updateGuildIndex()
    end)

    ZO_PostHook("ZO_SocialList_ColorRow", function(control, data, displayNameTextColor, iconColor, otherTextColor)
        UpdateNameColor(control)
    end)
end

-- When any addon is loaded, but before UI (Chat) is loaded.
EVENT_MANAGER:RegisterForEvent(GuildRankColors.name, EVENT_ADD_ON_LOADED, GuildRankColors.OnAddOnLoaded)