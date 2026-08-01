KeybindLogout = {
	name = "KeybindLogout",
}

local function OnAddOnLoaded( eventCode, addonName )
	if (addonName ~= KeybindLogout.name) then return end

	EVENT_MANAGER:UnregisterForEvent(KeybindLogout.name, EVENT_ADD_ON_LOADED)

	ZO_CreateStringId("SI_BINDING_NAME_LOG_OUT", GetString(SI_GAME_MENU_LOGOUT))
end

EVENT_MANAGER:RegisterForEvent(KeybindLogout.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
