local function OnAddOnLoaded(_, addonName)
    if (addonName == "SatiatedHunger") then
        EVENT_MANAGER:UnregisterForEvent("SatiatedHunger", EVENT_ADD_ON_LOADED)
        
        EVENT_MANAGER:RegisterForEvent("SatiatedHungerActivated", EVENT_PLAYER_ACTIVATED, function()
            SetSynergyPriorityOverride(33208, 10)
        end)
    end
end
 
EVENT_MANAGER:RegisterForEvent("SatiatedHunger", EVENT_ADD_ON_LOADED, OnAddOnLoaded)
