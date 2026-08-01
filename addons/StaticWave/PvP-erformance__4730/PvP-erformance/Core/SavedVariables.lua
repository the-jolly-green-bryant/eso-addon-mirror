local PvPerformance = PvPerformance
local Dueling = PvPerformance.Modules.Dueling
local Private = PvPerformance.Private
local DEFAULTS = Private.DEFAULTS
local SAVED_VARIABLES_VERSION = Private.SAVED_VARIABLES_VERSION

PvPerformance.Core.SavedVariables = PvPerformance.Core.SavedVariables or {}

function PvPerformance.Core.SavedVariables:Initialize()
    local worldName = type(GetWorldName) == "function" and GetWorldName() or "Default"
    return ZO_SavedVars:NewAccountWide(
        "PvPerformanceSavedVars",
        SAVED_VARIABLES_VERSION,
        worldName,
        DEFAULTS
    )
end