local ADDON_NAME = "StickerbookPlus"
local Addon = {}
_G[ADDON_NAME] = Addon

Addon.name        = ADDON_NAME
Addon.displayName = "Stickerbook+"
Addon.version     = "1.0.0"

-- ── Constants ─────────────────────────────────────────────────────────────────

-- Button label dropdown index
Addon.MARK_ALL_LABEL_REMOVE     = 1
Addon.MARK_ALL_LABEL_CLEAR      = 2
Addon.MARK_ALL_LABEL_DONE       = 3
Addon.MARK_ALL_LABEL_SEEN       = 4

-- Antiquity coloring basis dropdown index
Addon.ANTIQUITY_COLOR_BASIS_FOUND = 1
Addon.ANTIQUITY_COLOR_BASIS_CODEX = 2

-- Tracked-tile source identifiers
Addon.SOURCE = {
    SETS                = "sets",
    OUTFITS             = "outfits",
    COLLECTIONS         = "collections",
    LORE                = "lore",
    ACHIEVEMENTS        = "achievements",
    ANTIQUITIES         = "antiquities",
    ANTIQUITY_FRAGMENTS = "antiquityFragments",
}

-- ── Defaults ──────────────────────────────────────────────────────────────────

local DEFAULTS = {
    enabled = true,

    -- Supported areas
    enableSets        = true,
    enableOutfits     = true,
    enableCollections = true,
    enableLore        = true,
    enableAchievements = true,
    enableAntiquities  = true,

    -- New overlay
    showNewBorder         = true,
    newBorderColor        = { r = 0.9804, g = 1.0,    b = 0.0,    a = 1.0    },
    newBorderThickness    = 2,
    showNewBackground     = true,
    newBackgroundColor    = { r = 0.0431, g = 1.0,    b = 0.0,    a = 0.7459 },
    hideNewIcon           = true,

    -- Missing overlay
    missingBackgroundColor  = { r = 1.0, g = 0.2118, b = 0.2118, a = 0.4016 },
    showMissingForSets        = true,
    showMissingForOutfits     = true,
    showMissingForCollections = true,
    showMissingForLore        = true,
    showMissingForAchievements = true,
    showMissingForAntiquities  = true,
    showMissingForAntiquityFragments = true,

    -- Tree progress colors, per level
    colorCategories          = true,
    colorSubcats             = true,
    colorSets                = true,
    sortMissingSets          = true,
    colorOutfits             = true,
    textOutfits              = true,
    sortMissingOutfits       = true,
    colorCollections         = true,
    textCollections          = true,
    colorLore                = true,
    textLore                 = true,
    sortMissingLore          = true,
    colorAchievements        = true,
    textAchievements         = true,
    textAchievementsCount    = true,
    textAchievementsPoints   = true,
    colorAchievementLineThumbs = true,
    sortMissingAchievements  = true,
    colorAntiquities         = true,
    colorAntiquitiesBasis    = Addon.ANTIQUITY_COLOR_BASIS_FOUND,
    textAntiquities          = true,
    textAntiquitiesFound     = true,
    textAntiquitiesCodex     = true,
    textAntiquitiesScryable  = true,
    sortMissingAntiquities   = true,

    colorCompleteEnabled     = true,
    colorComplete            = { r = 0.1961, g = 1.0,    b = 0.2078, a = 0.7843 },

    colorPartialEnabled      = true,
    colorPartial             = { r = 0.6667, g = 0.6667, b = 0.6667, a = 0.7843 },

    colorMissingEnabled      = true,
    colorMissing             = { r = 0.7451, g = 0.0118, b = 0.0,    a = 0.7843 },

    colorSelectedEnabled     = true,
    colorSelected            = { r = 0.3098, g = 0.8706, b = 1.0,    a = 1.0    },

    -- Missing piece count, per level
    textCategories           = true,
    textSubcats              = true,
    textSets                 = true,

    -- Mark-all button
    showMarkAllButton  = true,
    markAllButtonLabel = Addon.MARK_ALL_LABEL_CLEAR,

    -- Tooltip ID display
    showSetIds        = false,
    showOutfitId      = false,
    showCollectionId  = false,

    -- Crown Store
    countHiddenCollectibles = false,
    showCrownTag            = true,
    crownTagColor           = { r = 1.0, g = 0.9333, b = 0.0, a = 1.0 },

    -- Advanced
    showChatMessages = true,
}

-- ── Helpers ───────────────────────────────────────────────────────────────────

local function TryCall(fn)
    if type(fn) ~= "function" then return false end
    return pcall(fn) == true
end

local function FormatChatMessage(message)
    return string.format("|c84E291[%s]|r %s", Addon.displayName, tostring(message or ""))
end

local function Print(message)
    local text = FormatChatMessage(message)

    if CHAT_ROUTER then
        if TryCall(function() CHAT_ROUTER:AddSystemMessage(text) end) then return end
    end

    if CHAT_SYSTEM then
        if TryCall(function() CHAT_SYSTEM:AddMessage(text) end) then return end
    end

    if ZO_GetChatSystem then
        local ok, chatSystem = pcall(ZO_GetChatSystem)
        if ok and chatSystem then
            if chatSystem.primaryContainer then
                if TryCall(function() chatSystem.primaryContainer:AddMessage(text) end) then return end
            end
            if chatSystem.containers then
                for _, cc in ipairs(chatSystem.containers) do
                    if cc and cc.windows then
                        for i = 1, #cc.windows do
                            local win = cc.windows[i]
                            if win and TryCall(function() cc:AddEventMessageToWindow(win, text, CHAT_CATEGORY_SYSTEM) end) then
                                return
                            end
                        end
                    end
                end
            end
        end
    end
end

local function PrintAuto(message)
    if Addon.db and not Addon.db.showChatMessages then return end
    Print(message)
end

-- ── Slash commands ────────────────────────────────────────────────────────────

function Addon.SetEnabled(val)
    Addon.db.enabled = val
    Addon.Overlay.RefreshAll()
    if val then
        Addon.TreeProgress.Refresh()
        Addon.MarkAll.RefreshVisibility()
        Addon.Hooks.RefreshAllCrownTags()
    else
        Addon.TreeProgress.Reset()
        Addon.MarkAll.Hide(nil)
        Addon.Hooks.RefreshAllCrownTags()
    end
end

function Addon.OnSlashCommand(args)
    args = args and zo_strtrim(args) or ""
    local cmd, rest = args:match("^(%S+)%s*(.*)")
    cmd = cmd and cmd:lower() or ""

    if cmd == "on" then
        Addon.SetEnabled(true)
        Print(GetString(SBP_CMD_ENABLED))

    elseif cmd == "off" then
        Addon.SetEnabled(false)
        Print(GetString(SBP_CMD_DISABLED))

    elseif cmd == "test" then
        if not Addon.db.enabled then
            Print(GetString(SBP_CMD_ADDON_DISABLED))
            return
        end
        local subcmd, idStr = rest:match("^(%S+)%s*(.*)")
        subcmd = subcmd and subcmd:lower() or ""

        if subcmd == "item" then
            local id = tonumber(idStr)
            if not id then
                Print(GetString(SBP_CMD_USAGE_ITEM))
                return
            end
            Addon.testNewIds = Addon.testNewIds or {}
            if Addon.testNewIds[id] then
                Addon.testNewIds[id] = nil
                Print(zo_strformat(GetString(SBP_CMD_TEST_NEW_CLEARED), "ItemId", id))
            else
                Addon.testNewIds[id] = true
                Print(zo_strformat(GetString(SBP_CMD_TEST_NEW_SET), "ItemId", id))
            end
            Addon.Overlay.RefreshTrackedTiles(Addon.SOURCE.SETS)

        elseif subcmd == "style" then
            local id = tonumber(idStr)
            if not id then
                Print(GetString(SBP_CMD_USAGE_STYLE))
                return
            end
            Addon.testNewOutfitIds = Addon.testNewOutfitIds or {}
            if Addon.testNewOutfitIds[id] then
                Addon.testNewOutfitIds[id] = nil
                Print(zo_strformat(GetString(SBP_CMD_TEST_NEW_CLEARED), "StyleId", id))
            else
                Addon.testNewOutfitIds[id] = true
                Print(zo_strformat(GetString(SBP_CMD_TEST_NEW_SET), "StyleId", id))
            end
            Addon.Overlay.RefreshTrackedTiles(Addon.SOURCE.OUTFITS)

        elseif subcmd == "collection" then
            local id = tonumber(idStr)
            if not id then
                Print(GetString(SBP_CMD_USAGE_COLLECTION))
                return
            end
            Addon.testNewCollectionIds = Addon.testNewCollectionIds or {}
            if Addon.testNewCollectionIds[id] then
                Addon.testNewCollectionIds[id] = nil
                Print(zo_strformat(GetString(SBP_CMD_TEST_NEW_CLEARED), "CollectibleId", id))
            else
                Addon.testNewCollectionIds[id] = true
                Print(zo_strformat(GetString(SBP_CMD_TEST_NEW_SET), "CollectibleId", id))
            end
            Addon.Overlay.RefreshTrackedTiles(Addon.SOURCE.COLLECTIONS)
        else
            Print(GetString(SBP_CMD_UNKNOWN_TEST))
        end

    else
        Print(GetString(SBP_CMD_HELP))

    end
end

-- ── Initialization ────────────────────────────────────────────────────────────

function Addon.OnPlayerActivated()
    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_PLAYER_ACTIVATED)
    PrintAuto(GetString(STICKERBOOKPLUS_READY))
end

function Addon.OnAddOnLoaded(_, addonName)
    if addonName ~= ADDON_NAME then return end
    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)

    Addon.db = ZO_SavedVars:NewAccountWide("StickerbookPlus_Data", 1, nil, DEFAULTS, GetWorldName())

    Addon.Hooks.Initialize()
    Addon.TreeProgress.Initialize()
    Addon.MarkAll.Initialize()

    Addon.Settings.Initialize(Addon)

    SLASH_COMMANDS["/sbp"] = function(args) Addon.OnSlashCommand(args) end
    SLASH_COMMANDS["/stickerbookplus"] = function(args) Addon.OnSlashCommand(args) end

    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_PLAYER_ACTIVATED, Addon.OnPlayerActivated)
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, Addon.OnAddOnLoaded)
