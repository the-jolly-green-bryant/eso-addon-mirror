ProcReminder = ProcReminder or {}
ProcReminder.name = "ProcReminder"
ProcReminder.version = "1.0.0"
ProcReminder.author = "Vixen Hunny"
ProcReminder.Data = ProcReminder.Data or {}
ProcReminder.Data.AbilityData = ProcReminder.Data.AbilityData or {}
local em = EVENT_MANAGER

function ProcReminder:ShowProc(abilityData, icon)
    -- Use new custom UI system instead of CENTER_SCREEN_ANNOUNCE
    if ProcReminder.UI then
        ProcReminder.UI:ShowProc(abilityData, icon, 4.0)  -- Display for 4 seconds
    end
end
