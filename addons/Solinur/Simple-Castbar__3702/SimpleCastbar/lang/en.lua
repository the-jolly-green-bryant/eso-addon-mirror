local strings = {

	-- Menu --

	SCB_LANG = "en", -- "en"
	SCB_FONT = "$(MEDIUM_FONT)",

	SCB_STRING_MENU_ACCOUNTWIDE = "Account-wide Settings", -- "Account-wide Settings"
	SCB_STRING_MENU_UNLOCK = "Unlock", -- "Unlock"
	SCB_STRING_MENU_UNLOCK_TOOLTIP = "Unlock and display the cast bar so it can be moved.", -- "Unlock and display the cast bar so it can be moved."
	SCB_STRING_MENU_HIDEOUTERBG = "Hide background", -- "Hide background"
	SCB_STRING_MENU_HIDEOUTERBG_TOOLTIP = "Hides the outer frame that marks the total extend of the UI element", -- "Hides the outer frame that marks the total extend of the UI element"
	SCB_STRING_MENU_CASTBARSIZE = "Size", -- "Unlock"
	SCB_STRING_MENU_CASTBARSIZE_TOOLTIP = "Size of the castbar", -- "Unlock and display the cast bar so it can be moved."	
	SCB_STRING_MENU_WEAVE_THRESHOLD = "Weaving threshold", -- "Unlock"
	SCB_STRING_MENU_WEAVE_THRESHOLD_TOOLTIP = "Maxmimum weaving time to show a green border, indicating a successful weave. The weaving time is defined as the time wasted between subsequent skill casts." , -- "Unlock and display the cast bar so it can be moved."

	-- Keybinds --
}

for stringId, stringValue in pairs(strings) do
	ZO_CreateStringId(stringId, stringValue)
	SafeAddVersion(stringId, 1)
end