PvPerformance = PvPerformance or {}
PvPerformance.Core = PvPerformance.Core or {}
PvPerformance.UI = PvPerformance.UI or {}
PvPerformance.Modules = PvPerformance.Modules or {}
PvPerformance.Modules.Dueling = PvPerformance.Modules.Dueling or {}
PvPerformance.Modules.Analytics = PvPerformance.Modules.Analytics or {}
PvPerformance.Private = PvPerformance.Private or {}

PvPerformance.ADDON_NAME = "PvP-erformance"
PvPerformance.DISPLAY_NAME = "PvP-erformance"
PvPerformance.EVENT_NAMESPACE = "PvPerformance"

function PvPerformance:Initialize()
    local Dueling = self.Modules.Dueling
    local Analytics = self.Modules.Analytics
    Dueling.savedVars = self.Core.SavedVariables:Initialize()
    Dueling:Initialize()
    Analytics.savedVars = Dueling.savedVars
    Analytics:Initialize()
end

local function OnAddOnLoaded(_, addonName)
    if addonName ~= PvPerformance.ADDON_NAME then
        return
    end

    EVENT_MANAGER:UnregisterForEvent(PvPerformance.EVENT_NAMESPACE, EVENT_ADD_ON_LOADED)
    PvPerformance:Initialize()
end

EVENT_MANAGER:RegisterForEvent(PvPerformance.EVENT_NAMESPACE, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
