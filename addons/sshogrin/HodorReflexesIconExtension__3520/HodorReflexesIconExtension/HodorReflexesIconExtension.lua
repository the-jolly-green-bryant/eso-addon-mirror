HRIE = HRIE or {}
HRIE.name = "HodorReflexesIconExtension"
HRIE.version = "1.4.1"


function HRIE.OnAddOnLoaded(_, addonName)
    if addonName ~= HRIE.name then return end
    
    EVENT_MANAGER:UnregisterForEvent(HRIE.name, EVENT_ADD_ON_LOADED)

	HRIE.savedVariables = ZO_SavedVars:NewCharacterIdSettings("HodorReflexesIconExtensionSavedVariables", 1, GetWorldName(), {}) --Instead of nil you can also use GetWorldName() to save the SV server dependent

    
    -- additional code if needed
	
end

EVENT_MANAGER:RegisterForEvent(HRIE.name, EVENT_ADD_ON_LOADED, HRIE.OnAddOnLoaded)
