local function OnAddonLoaded(event, addonName)
    if addonName == "StatColours" then
        EVENT_MANAGER:UnregisterForEvent("StatColours", EVENT_ADD_ON_LOADED)
        -- nothing more is needed; lang files already run SafeAddString
    end
end

EVENT_MANAGER:RegisterForEvent("StatColours", EVENT_ADD_ON_LOADED, OnAddonLoaded)
