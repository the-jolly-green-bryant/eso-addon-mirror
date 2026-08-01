SUI = SUI or {}
SUI = {
	name = "ShogrinUI",
	author = "sshogrin",
	version = "1.1.5",
}

function SUI.OnAddOnLoaded(_, addonName)
    if addonName ~= SUI.name then return end
    
    EVENT_MANAGER:UnregisterForEvent(SUI.name, EVENT_ADD_ON_LOADED)

	
    -- additional code if needed
	
end

EVENT_MANAGER:RegisterForEvent(SUI.name, EVENT_ADD_ON_LOADED, SUI.OnAddOnLoaded)
