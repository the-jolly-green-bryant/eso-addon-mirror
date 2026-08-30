-- My Little Journal — core: saved vars, chat prefix styles, slash
-- commands, keybind label, and the optional LibAddonMenu settings panel.

MyLittleJournal = MyLittleJournal or {}
local TJ = MyLittleJournal

local ADDON = "MyLittleJournal"
local VERSION = "1.0.0"
local SAVED_VARS_VERSION = 1

-- Scalars only — nested tables (notes, customBosses, customInstances) are
-- created on demand so ZO_SavedVars never owns them.
local defaults = {
    fontSize        = 18,
    defaultChannel  = "party",  -- "party","say","zone","whisper","guild1".."guild5"
    prefixStyle     = "boss",   -- "minimal","boss","full"
    readMode        = false,
}

local SV

-- =========================
-- Chat prefix styles
-- =========================
-- Returns prefixFn(partIndex, totalParts) for the chunker. bossName may be
-- nil (Overview entries), in which case the instance name is used instead.
function TJ.BuildPrefixFn(instanceName, bossName)
    local style = (SV and SV.prefixStyle) or "boss"
    local label
    if style == "minimal" then
        label = nil
    elseif style == "full" and bossName then
        label = instanceName .. " — " .. bossName
    else -- "boss" (and "full" without a boss)
        label = bossName or instanceName
    end

    return function(partIndex, totalParts)
        if totalParts <= 1 then
            if label then
                return "[" .. label .. "] "
            end
            return ""
        end
        if label then
            return string.format("[%s %d/%d] ", label, partIndex, totalParts)
        end
        return string.format("[%d/%d] ", partIndex, totalParts)
    end
end

-- =========================
-- Settings (LibAddonMenu-2.0, optional)
-- =========================
local PREFIX_STYLE_LABELS = { "Minimal — [1/3]", "Boss name — [Kra'gh 1/3]", "Full — [Fungal Grotto I — Kra'gh 1/3]" }
local PREFIX_STYLE_VALUES = { "minimal", "boss", "full" }

local CHANNEL_LABELS = { "Group", "Say", "Zone", "Whisper", "Guild 1", "Guild 2", "Guild 3", "Guild 4", "Guild 5" }
local CHANNEL_VALUES = { "party", "say", "zone", "whisper", "guild1", "guild2", "guild3", "guild4", "guild5" }

local function buildSettings()
    local LAM = LibAddonMenu2
    if not LAM then
        return -- settings are a nice-to-have; the journal works without them
    end

    local panel = {
        type = "panel",
        name = "My Little Journal",
        author = "You",
        version = VERSION,
        registerForRefresh = true,
    }

    local options = {
        { type = "description",
          text = "A personal strategy journal for dungeons, trials, and arenas. Open it with /mlj (or bind a key under Controls). Notes are saved account-wide. Sending to chat pre-fills the chat box — press Enter for each part; the next part is filled in automatically. The Share button opens a menu: with LibGroupBroadcast, a page or a whole dungeon's notes go to your group silently (nothing in chat) and other My Little Journal users get an import prompt; alternatively it sends clickable [Journal] links (requires LibChatMessage on both ends) that import the note with one click.",
          width = "full" },

        { type = "header", name = "Sending to chat" },
        { type = "dropdown", name = "Default channel",
          tooltip = "Channel pre-selected in the journal's Send dropdown. Guild slots follow your guild list order.",
          choices = CHANNEL_LABELS,
          choicesValues = CHANNEL_VALUES,
          getFunc = function() return SV.defaultChannel or defaults.defaultChannel end,
          setFunc = function(v) SV.defaultChannel = v end,
          default = defaults.defaultChannel, width = "full" },

        { type = "dropdown", name = "Message prefix style",
          tooltip = "How each chat part is labelled so people can follow along.",
          choices = PREFIX_STYLE_LABELS,
          choicesValues = PREFIX_STYLE_VALUES,
          getFunc = function() return SV.prefixStyle or defaults.prefixStyle end,
          setFunc = function(v) SV.prefixStyle = v end,
          default = defaults.prefixStyle, width = "full" },

        { type = "header", name = "Auto-discovery" },
        { type = "description",
          text = "New dungeons and trials are added to the journal automatically at login (from LibSets when installed, otherwise the Activity Finder). Bosses are never added automatically — use the '+ Add boss entry' row on an instance's page to add your own.",
          width = "full" },

        { type = "header", name = "Journal appearance" },
        { type = "slider", name = "Note text size",
          min = 14, max = 26, step = 1,
          getFunc = function() return SV.fontSize or defaults.fontSize end,
          setFunc = function(v)
              SV.fontSize = v
              if TJ.UI and TJ.UI.RefreshFonts then TJ.UI.RefreshFonts() end
          end,
          default = defaults.fontSize, width = "full" },
    }

    LAM:RegisterAddonPanel(ADDON .. "Options", panel)
    LAM:RegisterOptionControls(ADDON .. "Options", options)
end

-- =========================
-- Init
-- =========================
local function applyScalarDefaults()
    for key, value in pairs(defaults) do
        if SV[key] == nil then SV[key] = value end
    end
end

local function ensureStructure()
    if not SV.notes then SV.notes = {} end
    if not SV.customBosses then SV.customBosses = {} end
    if not SV.customInstances then SV.customInstances = {} end
end

local function registerSlashCommands()
    SLASH_COMMANDS["/mlj"] = function()
        TJ.UI.Toggle()
    end
    SLASH_COMMANDS["/mylittlejournal"] = SLASH_COMMANDS["/mlj"]
end

local function onAddOnLoaded(_, name)
    if name ~= ADDON then return end
    EVENT_MANAGER:UnregisterForEvent(ADDON, EVENT_ADD_ON_LOADED)

    SV = ZO_SavedVars:NewAccountWide("MyLittleJournal_SavedVariables", SAVED_VARS_VERSION, nil, defaults)
    applyScalarDefaults()
    ensureStructure()

    TJ.Chat.Init(SV)
    TJ.Share.Init(SV)
    TJ.UI.Init(SV)
    TJ.Discovery.Init(SV)
    buildSettings()
    registerSlashCommands()
end

ZO_CreateStringId("SI_BINDING_NAME_MLJ_TOGGLE_JOURNAL", "Toggle My Little Journal")

EVENT_MANAGER:RegisterForEvent(ADDON, EVENT_ADD_ON_LOADED, onAddOnLoaded)
