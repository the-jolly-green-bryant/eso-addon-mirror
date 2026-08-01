local AO = AutoOffline

---------------------------------------------------------------------------
-- ENABLE
---------------------------------------------------------------------------
function AO.Enable()
    EVENT_MANAGER:RegisterForEvent(AO.NAME .. "EVENT_PLAYER_ACTIVATED", EVENT_PLAYER_ACTIVATED, AO.OnPlayerActivated)

    if not AO.isHooked then
        ZO_PreHook("Logout", AO.OnLogout)
        ZO_PreHook("Quit", AO.OnLogout)
        AO.isHooked = true
    end

    AO.isLoaded = true
end

---------------------------------------------------------------------------
-- DISABLE
---------------------------------------------------------------------------
function AO.Disable()
    EVENT_MANAGER:UnregisterForEvent(AO.NAME .. "EVENT_PLAYER_ACTIVATED", EVENT_PLAYER_ACTIVATED)
    EVENT_MANAGER:UnregisterForUpdate(AO.NAME .. "HOURLY_CHECK")
    AO.isLoaded = false
end

---------------------------------------------------------------------------
-- INIT
---------------------------------------------------------------------------
function AO.Initialize()
    AO.SV = ZO_SavedVars:NewAccountWide(AO.SVName, AO.SVVersion, GetWorldName(), AO.default)

    AO.RegisterDialog()
    AO.CreateSettings()

    if AO.SV.enableAddon then
        AO.Enable()
    end
end

---------------------------------------------------------------------------
-- LOADED
---------------------------------------------------------------------------
EVENT_MANAGER:RegisterForEvent(AO.NAME .. "EVENT_ADD_ON_LOADED", EVENT_ADD_ON_LOADED, function(eventCode, addonName)
    if addonName == AO.NAME then
        AO.Initialize()
        EVENT_MANAGER:UnregisterForEvent(AO.NAME .. "EVENT_ADD_ON_LOADED", EVENT_ADD_ON_LOADED)
    end
end)