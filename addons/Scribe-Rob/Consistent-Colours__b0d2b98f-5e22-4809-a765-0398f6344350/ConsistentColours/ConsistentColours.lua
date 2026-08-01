ConsistentColours = ConsistentColours or {}
ConsistentColours.name = "ConsistentColours"
ConsistentColours.svName = "ConsistentColoursSV"
ConsistentColours.svVersion = 1

local DEFAULTS = {
    autoApply = true,
    guildColours = {
        [1] = { r=1, g=1, b=1 },
        [2] = { r=1, g=1, b=1 },
        [3] = { r=1, g=1, b=1 },
        [4] = { r=1, g=1, b=1 },
        [5] = { r=1, g=1, b=1 },
        [6] = { r=1, g=1, b=1 },
        [7] = { r=1, g=1, b=1 },
    },
}

local GUILD_CATEGORIES = {
    [1] = CHAT_CATEGORY_SAY,
    [2] = CHAT_CATEGORY_GROUP,
    [3] = CHAT_CATEGORY_GUILD_1,
    [4] = CHAT_CATEGORY_GUILD_2,
    [5] = CHAT_CATEGORY_GUILD_3,
    [6] = CHAT_CATEGORY_GUILD_4,
    [7] = CHAT_CATEGORY_GUILD_5,
}

local function EnsureDefaults()
    if not ConsistentColours.sv then return false end

    if ConsistentColours.sv.autoApply == nil then
        ConsistentColours.sv.autoApply = DEFAULTS.autoApply
    end

    if type(ConsistentColours.sv.guildColours) ~= "table" then
        ConsistentColours.sv.guildColours = {}
    end

    for i = 1, 7 do
        if type(ConsistentColours.sv.guildColours[i]) ~= "table" then
            local r, g, b

            -- Prefer the player's current chat colour for that category
            local cat = GUILD_CATEGORIES[i]
            if cat and GetChatCategoryColor then
                r, g, b = GetChatCategoryColor(cat)
            end

            -- Fallback to your hard defaults
            if r == nil or g == nil or b == nil then
                local d = DEFAULTS.guildColours[i]
                r, g, b = d.r, d.g, d.b
            end

            ConsistentColours.sv.guildColours[i] = { r = r, g = g, b = b }
        end
    end

    return true
end

local function ApplyGuildColoursFromSV()
    if not SetChatCategoryColor then return false end
    if not EnsureDefaults() then return false end

    for i = 1, 7 do
        local cat = GUILD_CATEGORIES[i]
        local c = ConsistentColours.sv.guildColours[i]
        if cat and c then
            SetChatCategoryColor(cat, c.r, c.g, c.b)
        end
    end

    return true
end

-- Forward declare so RegisterForEvent never receives nil as callback
local OnPlayerActivated
OnPlayerActivated = function()
    EVENT_MANAGER:UnregisterForEvent(ConsistentColours.name, EVENT_PLAYER_ACTIVATED)

    if ConsistentColours.sv and ConsistentColours.sv.autoApply then
        ApplyGuildColoursFromSV()
    end
end

local function OnAddonLoaded(_, addonName)
    if addonName ~= ConsistentColours.name then return end
    EVENT_MANAGER:UnregisterForEvent(ConsistentColours.name, EVENT_ADD_ON_LOADED)

    ConsistentColours.sv = ZO_SavedVars:NewAccountWide(
        ConsistentColours.svName,
        ConsistentColours.svVersion,
        nil,
        DEFAULTS
    )

    EnsureDefaults()
    if LibAddonMenu2 and ConsistentColours and ConsistentColours.InitLAM then
        ConsistentColours:InitLAM()
    end

    EVENT_MANAGER:RegisterForEvent(ConsistentColours.name, EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
end

EVENT_MANAGER:RegisterForEvent(ConsistentColours.name, EVENT_ADD_ON_LOADED, OnAddonLoaded)