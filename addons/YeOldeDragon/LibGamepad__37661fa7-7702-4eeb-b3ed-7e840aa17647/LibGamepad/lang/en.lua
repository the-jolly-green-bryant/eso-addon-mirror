local STRINGS = {
	-- Addons Management
	SI_LIBGAMEPAD_ADDONS_GENERAL_HEADER = "General",
	SI_LIBGAMEPAD_ADDONS_TOGGLE_TT = "Manage installed addons and their dependencies.",
	SI_LIBGAMEPAD_ADDONS_RELOADUI = "Reload UI",
	SI_LIBGAMEPAD_ADDONS_RELOADUI_TT = "Reload the user interface. Equivalent to the /reloadui command.",
	SI_LIBGAMEPAD_RELOAD_UI_WARNING = "Are you sure you want to reload the user interface?",
	SI_LIBGAMEPAD_DEBUG_SHORTCUT = "Menu shortcut",
	SI_LIBGAMEPAD_DEBUG_SHORTCUT_TT = "Shows a shortcut to this menu in the main OPTIONS menu.",
	-- Addons
	SI_LIBGAMEPAD_ADDONS_HEADER = "Addons options",
	-- LibGamepadLAM
	SI_LIBGAMEPADLAM_NOT_IMPLEMENTED = "Option unavailable in Gamepad mode.",
	SI_LIBGAMEPADLAM_EDITBOX_CURRENT_VALUE = "Current value:",
	SI_LIBGAMEPADLAM_EDITBOX_PROMPT = "Enter the new value, then press Confirm.",
	SI_LIBGAMEPADLAM_EDITBOX_FIELD_HEADER = "Value",
	SI_LIBGAMEPADLAM_EDITBOX_PLACEHOLDER = "Type here...",
	SI_LIBGAMEPADLAM_TOOLTIP_DEFAULT_VALUE = "Default value:",
}

local function OverrideString(stringIdName, value)
	local stringId = _G[stringIdName]
	if stringId ~= nil then
		SafeAddString(stringId, value, 2)
	else
		ZO_CreateStringId(stringIdName, value)
	end
end

for stringIdName, value in pairs(STRINGS) do
	OverrideString(stringIdName, value)
end