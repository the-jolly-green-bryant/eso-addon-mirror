-- AutoAbandonContracts.lua
-- Automatically abandons normal Dark Brotherhood contracts (non-Spree) after picking them up.
--
-- Quest naming conventions:
--   Normal contract  → "Contract: {location}"
--   Killing spree    → "Contract: {location} Spree"

local ADDON_NAME  = "AutoAbandonContracts"
local SAVED_VARS_VERSION = 1

-- Default settings — both options off
local DEFAULTS = {
    disabled        = false,  -- When true, addon does nothing
    inverseAbandon  = false,  -- When true, abandon Sprees instead of normal contracts
}

-- Will hold the loaded SavedVariables table
local Settings = {}

-- ─── Quest helpers ────────────────────────────────────────────────────────────

local function IsContract(questName)
    return questName and questName:match("^Contract: ") ~= nil
end

local function IsSpree(questName)
    return questName and questName:match(" Spree$") ~= nil
end

-- ─── Core logic ───────────────────────────────────────────────────────────────

local function OnQuestAdded(eventCode, questIndex)
    if Settings.disabled then return end

    local questName = GetJournalQuestName(questIndex)
    if not IsContract(questName) then return end

    -- Zone story quests share the "Contract: …" naming but are not repeatable.
    -- Never abandon those regardless of any setting.
    if GetJournalQuestRepeatType(questIndex) == QUEST_REPEAT_TYPE_NOT_REPEATABLE then
        d("|c88CCFF[" .. ADDON_NAME .. "]|r |cFFCC44" .. questName .. "|r was not abandoned — it is part of a zone story.")
        return
    end

    local spree        = IsSpree(questName)
    local shouldAbandon = Settings.inverseAbandon and spree
                       or (not Settings.inverseAbandon and not spree)

    if shouldAbandon then
        AbandonQuest(questIndex)
        d("|c88CCFF[" .. ADDON_NAME .. "]|r Abandoned: |cFFCC44" .. questName .. "|r")
    end
end

-- ─── LibAddonMenu-2.0 settings panel ─────────────────────────────────────────

local function BuildSettingsPanel()
    local LAM = LibAddonMenu2
    if not LAM then
        -- LAM not available — addon still works, just without the UI panel
        CHAT_SYSTEM:AddMessage("|cFF4444[" .. ADDON_NAME .. "]|r LibAddonMenu-2.0 not found. Settings panel unavailable.")
        return
    end

    local panelData = {
        type        = "panel",
        name        = "Auto Abandon Contracts",
        displayName = "Auto Abandon Contracts",
        author      = "",
        version     = "1.0",
        registerForRefresh = true,
    }

    local optionsData = {
        -- ── Disable toggle ─────────────────────────────────────────────────
        {
            type    = "checkbox",
            name    = "Disable auto abandoning",
            tooltip = "When enabled, the addon will not abandon any contracts automatically.",
            default = DEFAULTS.disabled,
            getFunc = function() return Settings.disabled end,
            setFunc = function(value) Settings.disabled = value end,
        },

        -- ── Inverse toggle ─────────────────────────────────────────────────
        {
            type    = "checkbox",
            name    = "Inverse abandoning",
            tooltip = "When enabled, auto abandons killing sprees. When disabled — abandons normal contracts.",
            default = DEFAULTS.inverseAbandon,
            getFunc = function() return Settings.inverseAbandon end,
            setFunc = function(value) Settings.inverseAbandon = value end,
        },
    }

    LAM:RegisterAddonPanel(ADDON_NAME .. "_Panel", panelData)
    LAM:RegisterOptionControls(ADDON_NAME .. "_Panel", optionsData)
end

-- ─── Initialisation ───────────────────────────────────────────────────────────

local function OnAddonLoaded(eventCode, addonName)
    if addonName ~= ADDON_NAME then return end

    -- Load (or create) saved variables
    AutoAbandonContractsSavedVars = ZO_SavedVars:NewAccountWide(
        "AutoAbandonContractsSavedVars",
        SAVED_VARS_VERSION,
        nil,
        DEFAULTS
    )
    Settings = AutoAbandonContractsSavedVars

    BuildSettingsPanel()

    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_QUEST_ADDED, OnQuestAdded)
    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddonLoaded)