TamrielRaces = TamrielRaces or {}
local TR = TamrielRaces

local function OnAddonLoaded(_, addonName)
    if addonName ~= TR.Config.addonName then return end

    EVENT_MANAGER:UnregisterForEvent(TR.Config.addonName, EVENT_ADD_ON_LOADED)
    TR.Controller:Initialize()

    if EVENT_PLAYER_ACTIVATED then
        TR.Events:Register("PlayerActivated", EVENT_PLAYER_ACTIVATED, function()
            TR.Controller:OnPlayerActivated()
        end)
    end
end

EVENT_MANAGER:RegisterForEvent(TR.Config.addonName, EVENT_ADD_ON_LOADED, OnAddonLoaded)
