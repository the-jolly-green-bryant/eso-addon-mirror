local OBT = OffBalanceTracker

---------------------------------------------------------------------------
-- INIT ADDON / SAVED VARS
---------------------------------------------------------------------------
function OBT.Initialize()
    -- FETCH LOCALIZED ABILITY NAMES FROM API ONE TIME ON START
    OBT.debuffName = GetAbilityName(62988)
    OBT.immuneName = GetAbilityName(134599)
    OBT.cleanDebuffName = zo_strformat("<<1>>", OBT.debuffName)
    OBT.cleanImuneName = zo_strformat("<<1>>", OBT.immuneName)

    OBT.isConsole = IsConsoleUI()
    OBT.SV = ZO_SavedVars:NewAccountWide(OBT.SVName, OBT.SVVersion, GetWorldName(), OBT.default)

    OBT.CreateGuiElements()
    OBT.CreateSettings()

    if OBT.SV.offsetX ~= OBT.default.offsetX or OBT.SV.offsetY ~= OBT.default.offsetY then
        OBT.PARENT:ClearAnchors()
        OBT.PARENT:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, OBT.SV.offsetX, OBT.SV.offsetY)
    else
        OBT.SetDefaultPosition()
    end

    if OBT.SV.enableAddon then
        OBT.Enable()
    end
end

---------------------------------------------------------------------------
-- SLASH COMMAND
---------------------------------------------------------------------------
SLASH_COMMANDS["/offbalancetracker"] = function()
    OBT.SV.isLocked = not OBT.SV.isLocked
    OBT.PARENT:SetMovable(not OBT.SV.isLocked)
    OBT.PARENT:SetMouseEnabled(not OBT.SV.isLocked)
    d(OBT.chat .. (OBT.SV.isLocked and " |cff0000UI Locked|r" or " |c00ff00UI Unlocked|r"))
end

---------------------------------------------------------------------------
-- LOADED
---------------------------------------------------------------------------
EVENT_MANAGER:RegisterForEvent(OBT.name, EVENT_ADD_ON_LOADED, function(eventCode, addonName)
    if addonName == OBT.name then
        OBT.Initialize()
        EVENT_MANAGER:UnregisterForEvent(OBT.name, EVENT_ADD_ON_LOADED)
    end
end)