---------------------------------------------------------------------------
-- Thresholds - initialization and slash commands
---------------------------------------------------------------------------

local THR = Thresholds

function THR.ToggleFrameLock()
    local locked = not THR.SV.frame.locked
    THR.SetFrameLocked(locked)
    if locked then
        d("|c66CCFFThresholds:|r tracker frame and alert text locked.")
    else
        d("|c66CCFFThresholds:|r tracker frame and alert text unlocked - drag them to a new position.")
    end
end

function THR.Initialize()
    THR.SV = ZO_SavedVars:NewAccountWide(THR.SVName, THR.SVVersion, GetWorldName(), THR.default)

    -- Cache the client language once; it never changes without a reloadui.
    THR.clientLang = GetCVar("Language.2")

    -- One-time rename alerts.csa -> alerts.text (pre-1.1 saves).
    if THR.SV.alerts.csa ~= nil then
        THR.SV.alerts.text = THR.SV.alerts.csa
        THR.SV.alerts.csa = nil
    end

    -- Seed the initial global thresholds exactly once. They cannot sit in
    -- the ZO_SavedVars defaults table: the game re-merges missing array
    -- indices on every load, refilling a list the user shortened.
    if not THR.SV.globalSeeded then
        THR.SV.globalSeeded = true
        if #THR.SV.globalThresholds == 0 then
            for i = 1, #THR.DEFAULT_GLOBAL_THRESHOLDS do
                THR.SV.globalThresholds[i] = THR.DEFAULT_GLOBAL_THRESHOLDS[i]
            end
        end
    end

    THR.CreateDisplay()
    THR.CreateAlertDisplay()
    THR.CreateSettingsMenu()

    SLASH_COMMANDS["/thresholds"] = THR.ToggleFrameLock
    SLASH_COMMANDS["/thr"] = THR.ToggleFrameLock

    if THR.SV.enabled then
        THR.Enable()
    end
end

local function OnAddOnLoaded(_, addonName)
    if addonName ~= THR.name then return end
    EVENT_MANAGER:UnregisterForEvent(THR.name, EVENT_ADD_ON_LOADED)
    THR.Initialize()
end

EVENT_MANAGER:RegisterForEvent(THR.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
