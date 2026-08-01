local ST = SlayerTracker

---------------------------------------------------------------------------
-- INIT ADDON / SAVED VARS
---------------------------------------------------------------------------
function ST.Initialize()
    ST.isConsole = IsConsoleUI()
    ST.SV = ZO_SavedVars:NewAccountWide(ST.SVName, ST.SVVersion, GetWorldName(), ST.Default)

    ST.CreateGuiElements()
    ST.CreateSettings()

    if ST.SV.offsetX ~= ST.Default.offsetX or ST.SV.offsetY ~= ST.Default.offsetY then
        ST.PARENT:ClearAnchors()
        ST.PARENT:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, ST.SV.offsetX, ST.SV.offsetY)
    else
        ST.SetDefaultPosition()
    end

    if ST.SV.enableAddon then
        ST.Enable()
    end
end

---------------------------------------------------------------------------
-- SLASH COMMAND
---------------------------------------------------------------------------
SLASH_COMMANDS["/slayertracker"] = function()
    if not ST.isPreview then
        ST.SV.isLocked = false
        ST.isPreview = true

        ST.PARENT:SetMovable(true)
        ST.PARENT:SetMouseEnabled(true)

        ST.PARENT:SetHidden(false)
        ST.isActive = true
        ST.endTime = GetGameTimeMilliseconds() + 15000
        ST.uptimePercentage = 62
        ST.expSec = 50

        ST.ManageUpdateLoop()
        ST.UpdateVisibility()
        ST.UpdateVisuals()

        d(ST.CHAT .. " |c00FF00Tracker Unlocked - Preview actived!|r")
    else
        ST.SV.isLocked = true
        ST.isPreview = false

        ST.PARENT:SetMovable(false)
        ST.PARENT:SetMouseEnabled(false)

        ST.OnCombatState()

        d(ST.CHAT .. " |cFF0000Tracker Locked|r")
    end
end

---------------------------------------------------------------------------
-- LOADED
---------------------------------------------------------------------------
EVENT_MANAGER:RegisterForEvent(ST.NAME, EVENT_ADD_ON_LOADED, function(eventCode, addonName)
    if addonName == ST.NAME then
        ST.Initialize()
        EVENT_MANAGER:UnregisterForEvent(ST.NAME, EVENT_ADD_ON_LOADED)
    end
end)