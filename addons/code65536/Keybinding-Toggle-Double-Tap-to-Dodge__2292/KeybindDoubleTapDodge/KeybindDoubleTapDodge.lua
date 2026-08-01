KeybindDoubleTapDodge = {
	name = "KeybindDoubleTapDodge",
}

local function OnAddOnLoaded( eventCode, addonName )
	if (addonName ~= KeybindDoubleTapDodge.name) then return end

	EVENT_MANAGER:UnregisterForEvent(KeybindDoubleTapDodge.name, EVENT_ADD_ON_LOADED)

	ZO_CreateStringId("SI_BINDING_NAME_TOGGLE_DOUBLE_TAP_DODGE", string.format("%s %s", GetString(SI_GAMEPAD_TOGGLE_OPTION), GetString(SI_INTERFACE_OPTIONS_COMBAT_ROLL_DODGE_ENABLED)))
end

function KeybindDoubleTapDodge.Toggle( )
	local setting = GetSetting(SETTING_TYPE_COMBAT, COMBAT_SETTING_ROLL_DODGE_DOUBLE_TAP)
	setting = (setting == "1") and "0" or "1"

	SetSetting(SETTING_TYPE_COMBAT, COMBAT_SETTING_ROLL_DODGE_DOUBLE_TAP, setting)

	CHAT_ROUTER:AddSystemMessage(string.format(
		"%s: %s",
		GetString(SI_INTERFACE_OPTIONS_COMBAT_ROLL_DODGE_ENABLED),
		GetString((setting == "1") and SI_CHECK_BUTTON_ON or SI_CHECK_BUTTON_OFF)
	))
end

EVENT_MANAGER:RegisterForEvent(KeybindDoubleTapDodge.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
