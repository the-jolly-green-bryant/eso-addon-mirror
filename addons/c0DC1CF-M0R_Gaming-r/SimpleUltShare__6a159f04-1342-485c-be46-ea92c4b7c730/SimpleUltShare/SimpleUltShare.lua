local function OnAddOnLoaded(event, addonName)
	if addonName ~= "SimpleUltShare" then return end
	LibGroupCombatStats.RegisterAddon("SimpleUltShare", {"ULT", "DPS"})
	EVENT_MANAGER:UnregisterForEvent("SimpleUltShare", EVENT_ADD_ON_LOADED)
end

EVENT_MANAGER:RegisterForEvent("SimpleUltShare", EVENT_ADD_ON_LOADED, OnAddOnLoaded)