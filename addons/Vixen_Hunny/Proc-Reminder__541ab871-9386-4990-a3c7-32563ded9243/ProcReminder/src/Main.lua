ProcReminder = ProcReminder or {}
ProcReminder.name = "ProcReminder"
ProcReminder.version = "1.0.0"
ProcReminder.author = "Vixen Hunny"
ProcReminder.Data = ProcReminder.Data or {}
ProcReminder.settings = ProcReminder.settings or {}
ProcReminder.Data.AbilityData = ProcReminder.Data.AbilityData or {}
local em = EVENT_MANAGER

ProcReminder.defaults = {
    primColor = {r = 1, g = 1, b = 1},
    secColor = {r = 1, g = 1, b = 1},
    statusBarColor = {r = 1, g = 0.5, b = 0},
}
function ProcReminder:Initialize()
    em:AddFilterForEvent(ProcReminder.name.."Effect", EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG , "player")
    em:RegisterForEvent(ProcReminder.name.."Effect", EVENT_EFFECT_CHANGED, function(...) ProcReminder:OnEffectChanged(...) end)
end
function ProcReminder:LoadSettings()
    ProcReminder.settings = ZO_SavedVars:New("ProcReminderVars", 8, nil, ProcReminder.defaults)
end
function ProcReminder:OnAddOnLoaded(event, addonName)
    if addonName ~= "ProcReminder" then return end
    em:UnregisterForEvent(ProcReminder.name, EVENT_ADD_ON_LOADED)
    ProcReminder:LoadSettings()
    ProcReminder:CreateSettingsMenu()
    ProcReminder.UI:Initialize()  -- Initialize custom UI system
    ProcReminder:Initialize()
end
em:RegisterForEvent(ProcReminder.name, EVENT_ADD_ON_LOADED, function(...) ProcReminder:OnAddOnLoaded(...) end)