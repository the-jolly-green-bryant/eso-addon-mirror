-- CooldownTrackerState.lua
-- Single state tree for the addon (runtime + savedvars wiring).

local CooldownTracker = _G["CooldownTracker"]

---@type CooldownTrackerState
local State = CooldownTracker.State or {}
CooldownTracker.State = State

State.savedVars = State.savedVars or nil
State.playerName = State.playerName or ""
State.refreshHandle = State.refreshHandle or nil
State.previewActive = State.previewActive == true

State.tracking = State.tracking or {
    trackerDefinitions = {},
    activeCooldowns = {},
    recentProcs = {},
    equippedSets = {},
    equippedSetIconPriority = {},
    registeredEvents = {},
    discoveryActive = false,
    combatDiscoveryActive = false,
    combatDiscoveryAutoStopCallLaterId = nil,
    hasNonStandardTrackerIds = false,
}

State.frames = State.frames or {
    activeFrames = {},
}

State.settings = State.settings or {
    initialized = false,
    addonSettings = nil,
    selectedTrackerId = nil,
    returnSelectionKey = nil,
    pendingSelectionKey = nil,
    rebuildPending = false,
}

--- Get default savedvars (schema root).
---@return CooldownTrackerSavedVars
function CooldownTracker.GetDefaults()
    return {
        version = CooldownTracker.savedVarsVersion,
        frames = {
            main = {
                id = "main",
                name = "Cooldowns",
                point = TOPLEFT,
                x = 50,
                y = 350,
                scale = 2.0,
                alpha = 1.0,
                iconSize = 32,
                rowHeight = 36,
                maxRows = 10,
                stackDisplayMode = "overlay",
                showTitle = false,
                locked = true,
            },
        },
        trackers = {
            -- User-configured trackers will be stored here
            -- Format: trackerId -> TrackerDefinition
        },
        settings = {
            showPreviewInSettings = true,
        },
    }
end

