KeyBinder = {
	name = "KeyBinder!",
};

local function OnAddOnLoaded(eventCode, addOnName)
    if (addOnName ~= "KeyBinder!") then return end

    EVENT_MANAGER:UnregisterForEvent("KeyBinder!", EVENT_ADD_ON_LOADED)

	ZO_CreateStringId("SI_BINDING_NAME_LEAVE_PARTY", "Leave Party")
	ZO_CreateStringId("SI_BINDING_NAME_RELOAD_UI", "Reload UI")
	ZO_CreateStringId("SI_BINDING_NAME_LOG_OUT", "Log Out")
        
	EVENT_MANAGER:UnregisterForEvent("KeyBinder!", EVENT_ADD_ON_LOADED)
end

local function ReloadUIBinding()
	ReloadUI()
end

local function GroupLeave()
	ReloadUI()
end

local function Logout()
	ReloadUI()
end


EVENT_MANAGER:RegisterForEvent("KeyBinder!", EVENT_ADD_ON_LOADED, OnAddOnLoaded)