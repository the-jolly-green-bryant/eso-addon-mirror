local allStrings = {
	RM_CHAT_DISPLAY_LABEL		= "Display changes in chat box",
	RM_CHAT_DISPLAY_TOOLTIP		= "Show which mount you switched to in the chat box.",
	RM_FREQ_LABEL				= "Frequency",
	RM_FREQ_TOOLTIP				= "How often you want your mount to swap",
	RM_FREQ_ON_LOGIN			= "On Login",
	RM_FREQ_ON_LOAD_SCREEN		= "Every Load Screen",
	RM_FREQ_NEVER				= "Never",
	RM_FREQ_WARNING				= "Needs UI reload.",
	RM_RELOAD_UI_LABEL			= "Reload UI",
	RM_MOUNT_CHAT_LOG			= "Mount changed to ",
}

for id, value in pairs(allStrings) do
	ZO_CreateStringId(id, value)
	SafeAddVersion(id, 1)
end
