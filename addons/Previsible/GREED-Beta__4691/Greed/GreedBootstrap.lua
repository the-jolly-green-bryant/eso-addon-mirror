Greed_Addon = Greed_Addon or {}
local Greed = Greed_Addon

function Greed.OnAddOnLoaded(eventCode, addonName)
    if addonName ~= Greed.name then return end

    EVENT_MANAGER:UnregisterForEvent(Greed.name, EVENT_ADD_ON_LOADED)
    Greed:Initialize()
end

EVENT_MANAGER:RegisterForEvent(Greed.name, EVENT_ADD_ON_LOADED, Greed.OnAddOnLoaded)
