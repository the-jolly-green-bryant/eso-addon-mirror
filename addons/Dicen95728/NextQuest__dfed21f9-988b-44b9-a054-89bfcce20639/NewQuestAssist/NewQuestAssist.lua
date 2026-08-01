-- New Quest Assist
-- Jump focus to the quest you just accepted, via a dedicated keybind
-- and/or the existing Cycle Focused Quest button.

local ADDON_NAME = "NewQuestAssist"

-- ---------------------------------------------------------------------------
-- Settings (account-wide)
-- ---------------------------------------------------------------------------
local defaults = {
    overloadCycle         = true,   -- first Cycle press after a new quest jumps to it
    skipIfAlreadyAssisted = true,   -- if the new quest is already active, let Cycle behave normally
    freshnessWindowMs     = 0,      -- 0 = armed until your next Cycle press; >0 = expires after N ms
    debug                 = false,  -- set true in the SavedVariables file to see diagnostics
}
local sv

-- Runtime state
local newestIndex = nil    -- journalIndex of the most recently accepted quest
local armedAt     = nil    -- GetGameTimeMilliseconds() when that quest armed the jump

-- Binding display names (must exist when the keybind UI is built)
ZO_CreateStringId("SI_BINDING_NAME_NEWQUESTASSIST_ASSIST_NEWEST",   "Assist Newest Quest")
ZO_CreateStringId("SI_BINDING_NAME_NEWQUESTASSIST_TOGGLE_OVERLOAD", "Toggle Cycle-Button Jump")

-- ---------------------------------------------------------------------------
-- Helpers
-- ---------------------------------------------------------------------------
local function Dbg(msg)
    if sv and sv.debug then
        d("[NewQuestAssist] " .. msg)
    end
end

local function GetTracker()
    -- FOCUSED_QUEST_TRACKER on live; QUEST_TRACKER on much older builds.
    return FOCUSED_QUEST_TRACKER or QUEST_TRACKER
end

-- Make a specific journal quest the active/assisted one.
-- ForceAssist also tracks the quest if it isn't already tracked.
local function AssistIndex(index)
    local tracker = GetTracker()
    if tracker and index and tracker.ForceAssist then
        tracker:ForceAssist(index)
        return true
    end
    return false
end

local function IsArmed()
    if not newestIndex or not armedAt then return false end
    local window = sv.freshnessWindowMs or 0
    if window > 0 and (GetGameTimeMilliseconds() - armedAt) > window then
        return false
    end
    return true
end

-- ---------------------------------------------------------------------------
-- Event: a quest was just accepted
-- ---------------------------------------------------------------------------
local function OnQuestAdded(_, questIndex)
    newestIndex = questIndex
    armedAt     = GetGameTimeMilliseconds()
end

-- ---------------------------------------------------------------------------
-- Cycle Focused Quest interception.
-- Return TRUE to suppress the game's normal AssistNext(); FALSE to let it run.
-- ---------------------------------------------------------------------------
local function OnCyclePressed()
    if not sv.overloadCycle then return false end
    if not IsArmed() then return false end

    local target = newestIndex
    armedAt = nil   -- consume: only the FIRST cycle-press after a new quest jumps

    if sv.skipIfAlreadyAssisted and GetTrackedIsAssisted(TRACK_TYPE_QUEST, target) then
        return false
    end

    return AssistIndex(target)   -- true => the default cycle is skipped this once
end

local function InstallHook()
    local tracker = GetTracker()
    if tracker and tracker.AssistNext then
        ZO_PreHook(tracker, "AssistNext", function(self, ignoreSceneRestriction)
            return OnCyclePressed()
        end)
    else
        Dbg("Quest tracker AssistNext not found - cycle overload unavailable.")
    end
end

-- ---------------------------------------------------------------------------
-- Globals called by Bindings.xml
-- ---------------------------------------------------------------------------
function NewQuestAssist_AssistNewest()
    if not AssistIndex(newestIndex) then
        Dbg("No recent quest to jump to.")
    end
end

function NewQuestAssist_ToggleOverload()
    sv.overloadCycle = not sv.overloadCycle
    d("[New Quest Assist] Cycle-button jump: " .. (sv.overloadCycle and "ON" or "OFF"))
end

-- ---------------------------------------------------------------------------
-- Optional settings panel (only if LibAddonMenu-2.0 is installed)
-- ---------------------------------------------------------------------------
local function BuildSettingsPanel()
    local LAM = LibAddonMenu2
    if not LAM then return end

    LAM:RegisterAddonPanel("NewQuestAssistPanel", {
        type = "panel",
        name = "New Quest Assist",
        author = "@Dicen95728",
        version = "1.0",
        registerForRefresh = true,
    })

    LAM:RegisterOptionControls("NewQuestAssistPanel", {
        {
            type = "checkbox",
            name = "Cycle button jumps to new quest",
            tooltip = "First press of Cycle Focused Quest right after accepting a quest jumps straight to it.",
            getFunc = function() return sv.overloadCycle end,
            setFunc = function(v) sv.overloadCycle = v end,
        },
        {
            type = "checkbox",
            name = "Skip if the new quest is already active",
            getFunc = function() return sv.skipIfAlreadyAssisted end,
            setFunc = function(v) sv.skipIfAlreadyAssisted = v end,
        },
        {
            type = "slider",
            name = "Freshness window (seconds)",
            tooltip = "0 = stays armed until your next Cycle press. Otherwise the jump expires this many seconds after you accept a quest.",
            min = 0, max = 120, step = 5,
            getFunc = function() return (sv.freshnessWindowMs or 0) / 1000 end,
            setFunc = function(v) sv.freshnessWindowMs = v * 1000 end,
        },
    })
end

-- ---------------------------------------------------------------------------
-- Init
-- ---------------------------------------------------------------------------
local function OnAddOnLoaded(_, addOnName)
    if addOnName ~= ADDON_NAME then return end
    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)

    sv = ZO_SavedVars:NewAccountWide("NewQuestAssistSV", 1, nil, defaults)

    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_QUEST_ADDED, OnQuestAdded)
    InstallHook()
    BuildSettingsPanel()
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
