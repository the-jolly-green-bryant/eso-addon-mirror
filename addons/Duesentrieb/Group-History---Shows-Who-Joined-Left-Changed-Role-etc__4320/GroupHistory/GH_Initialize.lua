local GH = GroupHistory

----------------------------------------------------------------------------------------------------
-- INIT
----------------------------------------------------------------------------------------------------
function GH.Initialize()
    GH.SV = ZO_SavedVars:NewAccountWide(GH.SVName, GH.SVVersion, GetWorldName(), GH.Default)
    GH.CreateSettingsWindow()
    GH.Enable()
    GH.isLoaded = true
end

----------------------------------------------------------------------------------------------------
-- SLASH - PRINTS CURRENT GROUP MEMBERS TO CHAT
----------------------------------------------------------------------------------------------------
SLASH_COMMANDS[GH.SLASH] = GH.PrintGroupMembers

----------------------------------------------------------------------------------------------------
-- ADDON LOADED
----------------------------------------------------------------------------------------------------
function GH.OnAddOnLoaded(_, name)
    if name == GH.NAME then
        GH.Initialize()
        EVENT_MANAGER:UnregisterForEvent(GH.NAME, EVENT_ADD_ON_LOADED)
    end
end

EVENT_MANAGER:RegisterForEvent(GH.NAME, EVENT_ADD_ON_LOADED, GH.OnAddOnLoaded)