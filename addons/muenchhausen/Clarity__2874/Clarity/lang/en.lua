--English language file for "Clarity" addon
local strings = {
--Addon LAM menu
	SI_CLARITY_LAM_OPTION_FORM_GRASS	= "Sets grass to:",
	SI_CLARITY_LAM_OPTION_HIDE_GRASS	= "Hide Grass",
	SI_CLARITY_LAM_OPTION_HIDE_LIGHT	= "Hide Sunlight Rays",
	SI_CLARITY_LAM_OPTION_HIDE_EFFECTS	= "Hide Additional Ally Effects",
	SI_CLARITY_LAM_OPTION_INFO			= "These options also apply when toggled manually with |cB39C7A/clarity|r or a hotkey. To re-activate the automatic function, use |cB39C7A/clarity auto|r.",
	SI_CLARITY_LAM_OPTION_AUTO			= "Toggle automatically if you get into combat",
	SI_CLARITY_LAM_OPTION_AUTO_TT		= "If OFF, Clarity can only be toggled manually.",
	SI_CLARITY_TOGGLE_ON	 			= " is ON.",
	SI_CLARITY_TOGGLE_OFF	 			= " is OFF.",
--Keybindings
	SI_BINDING_NAME_TOGGLE_GRASS 		= "Clarity Enabled/Disabled",
}
for stringId, stringValue in pairs(strings) do ZO_CreateStringId(stringId, stringValue) SafeAddVersion(stringId, 1) end