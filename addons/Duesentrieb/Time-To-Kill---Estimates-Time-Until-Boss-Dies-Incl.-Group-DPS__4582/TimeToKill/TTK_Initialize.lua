local TTK = TimeToKill

---------------------------------------------------------------------------
-- TOGGLE UI LOCK
---------------------------------------------------------------------------
function TTK.TogglePreview()
    TTK.isPreview = not TTK.isPreview

    if TTK.isPreview then
        TTK.PARENT:SetMovable(true)
        TTK.PARENT:SetMouseEnabled(true)
        d(string.format("%s |c00ff00Preview Mode: ON|r", TTK.chat))
    else
        TTK.PARENT:SetMovable(not TTK.SV.isLocked)
        TTK.PARENT:SetMouseEnabled(not TTK.SV.isLocked)
        d(string.format("%s |cff0000Preview Mode: OFF|r", TTK.chat))
    end

    TTK.UpdateVisibility()
end

---------------------------------------------------------------------------
-- SCENE CHANGE (HIDE ADDON WHEN IN MENU ETC)
---------------------------------------------------------------------------
function TTK.OnStateChange(oldState, newState)
    if newState == SCENE_SHOWN or newState == SCENE_HIDING then
        TTK.UpdateVisibility()
    end
end

---------------------------------------------------------------------------
-- UPDATE TIMER
---------------------------------------------------------------------------
function TTK.ApplyUpdateInterval()
    EVENT_MANAGER:UnregisterForUpdate(TTK.name .. "Update")
    if TTK.SV.isEnabledAddon then
        EVENT_MANAGER:RegisterForUpdate(TTK.name .. "Update", TTK.SV.updateIntervalMs, TTK.OnUpdateHandler)
    end
end

---------------------------------------------------------------------------
-- ENABLE ADDON
---------------------------------------------------------------------------
function TTK.Enable()
    SCENE_MANAGER:GetScene("hud"):RegisterCallback("StateChange", TTK.OnStateChange)
    SCENE_MANAGER:GetScene("hudui"):RegisterCallback("StateChange", TTK.OnStateChange)

    EVENT_MANAGER:RegisterForEvent(TTK.name, EVENT_PLAYER_COMBAT_STATE, TTK.OnCombatState)
    TTK.ApplyUpdateInterval()

    TTK.UpdateVisibility()
    TTK.isLoaded = true
end

---------------------------------------------------------------------------
-- DISABLE ADDON
---------------------------------------------------------------------------
function TTK.Disable()
    SCENE_MANAGER:GetScene("hud"):UnregisterCallback("StateChange", TTK.OnStateChange)
    SCENE_MANAGER:GetScene("hudui"):UnregisterCallback("StateChange", TTK.OnStateChange)

    EVENT_MANAGER:UnregisterForEvent(TTK.name, EVENT_PLAYER_COMBAT_STATE)
    EVENT_MANAGER:UnregisterForUpdate(TTK.name .. "Update")

    TTK.PARENT:SetHidden(true)
    TTK.isLoaded = false
end

---------------------------------------------------------------------------
-- INIT
---------------------------------------------------------------------------
function TTK.Initialize()
    TTK.isConsole = IsConsoleUI()
    TTK.SV = ZO_SavedVars:NewAccountWide(TTK.SVName, TTK.SVVersion, GetWorldName(), TTK.default)

    TTK.CreateGuiElements()
    TTK.CreateSettings()

    -- RESTORE SAVED POSITION
    if TTK.SV.offsetX ~= 0 or TTK.SV.offsetY ~= -200 then
        TTK.PARENT:ClearAnchors()
        TTK.PARENT:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, TTK.SV.offsetX, TTK.SV.offsetY)
    else
        TTK.PARENT:ClearAnchors()
        TTK.PARENT:SetAnchor(CENTER, GuiRoot, CENTER, 0, TTK.default.offsetY)
    end

    if TTK.SV.isEnabledAddon then
        TTK.Enable()
    end
end

---------------------------------------------------------------------------
-- SLASH COMMAND
---------------------------------------------------------------------------
SLASH_COMMANDS["/timetokill"] = function()
    TTK.TogglePreview()
end

---------------------------------------------------------------------------
-- ADDON LOADED
---------------------------------------------------------------------------
EVENT_MANAGER:RegisterForEvent(TTK.name, EVENT_ADD_ON_LOADED, function(eventCode, addonName)
    if addonName == TTK.name then
        TTK.Initialize()
        EVENT_MANAGER:UnregisterForEvent(TTK.name, EVENT_ADD_ON_LOADED)
    end
end)