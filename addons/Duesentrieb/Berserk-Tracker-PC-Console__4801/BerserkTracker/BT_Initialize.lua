local BT = BerserkTracker

---------------------------------------------------------------------------
-- INIT ADDON / SAVED VARS
---------------------------------------------------------------------------
function BT.Initialize()
    BT.isConsole = IsConsoleUI()
    BT.SV = ZO_SavedVars:NewAccountWide(BT.SVName, BT.SVVersion, GetWorldName(), BT.Default)

    BT.CreateGuiElements()
    BT.CreateSettings()

    if BT.SV.offsetX ~= BT.Default.offsetX or BT.SV.offsetY ~= BT.Default.offsetY then
        BT.PARENT:ClearAnchors()
        BT.PARENT:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, BT.SV.offsetX, BT.SV.offsetY)
    else
        BT.SetDefaultPosition()
    end

    if BT.SV.enableAddon then
        BT.Enable()
    end
end

---------------------------------------------------------------------------
-- SLASH COMMAND
---------------------------------------------------------------------------
SLASH_COMMANDS["/berserktracker"] = function()
    if not BT.isPreview then
        BT.SV.isLocked = false
        BT.isPreview = true

        BT.PARENT:SetMovable(true)
        BT.PARENT:SetMouseEnabled(true)

        BT.PARENT:SetHidden(false)
        BT.isActive = true
        BT.endTime = GetGameTimeMilliseconds() + 10000
        BT.uptimePercentage = 62

        BT.ManageUpdateLoop()
        BT.UpdateVisibility()
        BT.UpdateVisuals()

        d(BT.CHAT .. " |c00FF00Tracker Unlocked - Preview actived!|r")
    else
        BT.SV.isLocked = true
        BT.isPreview = false

        BT.PARENT:SetMovable(false)
        BT.PARENT:SetMouseEnabled(false)

        BT.OnCombatState()

        d(BT.CHAT .. " |cFF0000Tracker Locked|r")
    end
end

---------------------------------------------------------------------------
-- LOADED
---------------------------------------------------------------------------
EVENT_MANAGER:RegisterForEvent(BT.NAME, EVENT_ADD_ON_LOADED, function(eventCode, addonName)
    if addonName == BT.NAME then
        BT.Initialize()
        EVENT_MANAGER:UnregisterForEvent(BT.NAME, EVENT_ADD_ON_LOADED)
    end
end)