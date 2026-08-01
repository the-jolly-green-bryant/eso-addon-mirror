local HST = HeatShockTracker

---------------------------------------------------------------------------
-- CONSOLE FLOW TEST COMMAND (ONLY FOR ME ^_^)
---------------------------------------------------------------------------
if GetDisplayName() == "@Duesentrieb" then
    SLASH_COMMANDS['/hstconsole'] = function()
        local isConsole = IsConsoleUI() and "0" or "1"
        SetCVar("ForceConsoleFlow.2", isConsole)
    end
end

---------------------------------------------------------------------------
-- INITIALIZE ADDON
---------------------------------------------------------------------------
function HST.Initialize()
    HST.isConsole = IsConsoleUI()
    HST.SV = ZO_SavedVars:NewAccountWide(HST.SVName, HST.SVVersion, GetWorldName(), HST.Default)

    HST.CreateGuiElements()
    HST.CreateSettings()

    -- RESTORE SAVED POSITION OR SET DEFAULT
    if HST.SV.offsetX ~= 0 or HST.SV.offsetY ~= -200 then
        HST.PARENT:ClearAnchors()
        HST.PARENT:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, HST.SV.offsetX, HST.SV.offsetY)
    else
        HST.SetDefaultPosition()
    end

    if HST.SV.enableAddon then HST.Enable() end

    -- INITIAL VISUAL UPDATE
    HST.UpdateVisuals()
end

---------------------------------------------------------------------------
-- REGISTER SLASH COMMANDS
---------------------------------------------------------------------------
SLASH_COMMANDS["/heatshocktracker"] = function()
    if not HST.isForceShow then
        HST.SV.isLocked = false
        HST.isForceShow = true

        HST.PARENT:SetMovable(true)
        HST.PARENT:SetMouseEnabled(true)

        HST.currentStacks = 3
        HST.Percentages[3] = 62.0
        HST.StackEndTimes[1] = GetGameTimeMilliseconds() + HST.DURATION_MS
        HST.isTrackedBoss = true
        HST.trackedBossLabel = "BOSS1"

        HST.UpdateIsEquipped()
        HST.UpdateVisuals()

        d(string.format("%s |c00FF00HeatShockTracker Unlocked - Preview activated!|r", HST.CHAT))
    else
        HST.SV.isLocked = true
        HST.isForceShow = false

        HST.PARENT:SetMovable(false)
        HST.PARENT:SetMouseEnabled(false)

        HST.currentStacks = 0
        HST.Percentages[3] = 0
        HST.StackEndTimes[1] = 0
        HST.isTrackedBoss = false

        HST.UpdateIsEquipped()
        HST.UpdateVisuals()

        d(string.format("%s |cFF0000HeatShockTracker Locked|r", HST.CHAT))
    end
end

---------------------------------------------------------------------------
-- REGISTER ADDON LOADED EVENT
---------------------------------------------------------------------------
EVENT_MANAGER:RegisterForEvent(HST.NAME, EVENT_ADD_ON_LOADED, function(eventCode, addonName)
    if addonName == HST.NAME then
        HST.Initialize()
        EVENT_MANAGER:UnregisterForEvent(HST.NAME, EVENT_ADD_ON_LOADED)
    end
end)