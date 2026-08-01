LibGamepad = LibGamepad or {}

function LibGamepad.Initialize(eventCode, addOnName)
	if addOnName ~= "LibGamepad" then
		return
	end
	LibGamepad.SV = ZO_SavedVars:NewAccountWide("LibGamepadVars", 1.0, nil, LibGamepad.DefaultValues, nil)

	-- Usefull keybinds
	ZO_CreateStringId("SI_BINDING_NAME_LIBGAMEPAD_RELOAD_UI", GetString(SI_ADDON_MANAGER_RELOAD)) -- Reload UI keybind
	ZO_CreateStringId("SI_BINDING_NAME_LIBGAMEPAD_LOG_OUT", GetString(SI_GAME_MENU_LOGOUT)) -- Logout keybind.
end

EVENT_MANAGER:RegisterForEvent(LibGamepad.AddonName, EVENT_ADD_ON_LOADED, LibGamepad.Initialize)
