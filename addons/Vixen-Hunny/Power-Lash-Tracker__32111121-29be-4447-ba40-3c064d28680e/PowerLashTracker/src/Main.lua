PLT = PLT or {}
PLT.UI = PLT.UI or {}
PLT.Settings = PLT.Settings or {}
PLT.isLoaded = false
wm = WINDOW_MANAGER
em = EVENT_MANAGER
function PLT:Initialize()
    if not PLT.isLoaded then
        return
    end
    PLT.savedVariables = ZO_SavedVars:NewAccountWide("PowerLashTrackerSavedVariables", 1, nil, PLT.defaultSettings)
    PLT:CreateUI()
    PLT:CreateSettings()
    em:RegisterForEvent("PowerLashTracker".. "Effect", EVENT_EFFECT_CHANGED, function (...) PLT:OnEffectChanged(...) end)
    em:RegisterForEvent("PowerLashTracker".."CE", EVENT_COMBAT_EVENT, function(...) PLT:OnCombatEvent(...) end)
end

function PLT.isAddonLoaded(_, addonName) 
    if addonName == "PowerLashTracker" then
        PLT.isLoaded = true
        PLT:Initialize()
    end
end
em:RegisterForEvent("PowerLashTracker", EVENT_ADD_ON_LOADED, PLT.isAddonLoaded)